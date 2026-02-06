"""
Multilingual Voice Agent Backend
Supports: Auto-detection of Hindi, English, Bengali, Urdu, Telugu, Kannada, Tamil, Marathi, Punjabi, Gujarati
"""

import os
import io
import base64
import tempfile
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI
from groq import Groq

load_dotenv()

app = FastAPI(title="Multilingual Voice Agent")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Language configurations (for reference/mapping)
LANGUAGES = {
    "en": "English",
    "hi": "Hindi",
    "bn": "Bengali",
    "ur": "Urdu",
    "te": "Telugu",
    "kn": "Kannada",
    "ta": "Tamil",
    "mr": "Marathi",
    "pa": "Punjabi",
    "gu": "Gujarati"
}

# API clients
openai_client = None
groq_clients = []

# Initialize OpenAI client
openai_key = os.getenv("OPENAI_API_KEY")
if openai_key:
    openai_client = OpenAI(api_key=openai_key)

# Initialize Groq clients
groq_key_1 = os.getenv("GROQ_API_KEY_1")
groq_key_2 = os.getenv("GROQ_API_KEY_2")
if groq_key_1:
    groq_clients.append(Groq(api_key=groq_key_1))
if groq_key_2:
    groq_clients.append(Groq(api_key=groq_key_2))


# In-memory chat history store
CHAT_HISTORY = {}


class ChatResponse(BaseModel):
    text: str
    audio_base64: str | None = None
    language: str
    detected_language: str | None = None


def transcribe_audio(audio_file) -> tuple[str, str]:
    """
    Transcribe audio using Groq Whisper or OpenAI Whisper.
    Returns (transcribed_text, detected_language_code)
    """
    # Save temp file for the APIs
    with tempfile.NamedTemporaryFile(delete=False, suffix=".webm") as temp_audio:
        temp_audio.write(audio_file.read())
        temp_path = temp_audio.name

    try:
        # Try Groq Whisper (Fastest)
        for client in groq_clients:
            try:
                with open(temp_path, "rb") as file:
                    # Groq translation/transcription
                    response = client.audio.transcriptions.create(
                        file=(temp_path, file.read()),
                        model="whisper-large-v3",
                        response_format="verbose_json"
                    )
                    # verbose_json usually includes language
                    text = response.text
                    language = getattr(response, 'language', 'en') # Fallback if property missing
                    return text, language
            except Exception as e:
                print(f"Groq Whisper failed: {e}")
                continue
        
        # Fallback to OpenAI Whisper
        if openai_client:
            try:
                with open(temp_path, "rb") as file:
                    response = openai_client.audio.transcriptions.create(
                        file=file,
                        model="whisper-1",
                        response_format="verbose_json"
                    )
                    return response.text, response.language
            except Exception as e:
                print(f"OpenAI Whisper failed: {e}")
        
        raise Exception("All transcription services failed")
        
    finally:
        # Cleanup
        if os.path.exists(temp_path):
            os.remove(temp_path)


def get_ai_response(message: str, language_code: str, session_id: str) -> str:
    """Get AI response using Groq or OpenAI with conversation history."""
    
    # Map code to name if possible, else generic
    lang_name = LANGUAGES.get(language_code, "the same language as the user")
    
    # Initialize history for new session
    if session_id not in CHAT_HISTORY:
        CHAT_HISTORY[session_id] = []
    
    # Prune history
    if len(CHAT_HISTORY[session_id]) > 20:
        CHAT_HISTORY[session_id] = CHAT_HISTORY[session_id][-20:]

    system_prompt = f"""You are a helpful voice assistant.
STRICT INSTRUCTION: You must respond ONLY in {lang_name}.
If the user speaks {lang_name}, reply in {lang_name}.
Do not switch to English unless explicitly asked.
Keep responses concise, conversational, and suitable for voice output.
No markdown or special characters."""

    messages = [{"role": "system", "content": system_prompt}] + CHAT_HISTORY[session_id] + [{"role": "user", "content": message}]

    response_text = ""
    provider_success = False

    # Try Groq clients
    for i, client in enumerate(groq_clients):
        try:
            response = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            response_text = response.choices[0].message.content
            provider_success = True
            break
        except Exception as e:
            print(f"Groq Chat client {i+1} failed: {e}")
            continue

    # Fallback to OpenAI
    if not provider_success and openai_client:
        try:
            response = openai_client.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            response_text = response.choices[0].message.content
            provider_success = True
        except Exception as e:
            print(f"OpenAI Chat failed: {e}")

    if not provider_success:
        raise HTTPException(status_code=500, detail="All AI providers failed")

    # Update history
    CHAT_HISTORY[session_id].append({"role": "user", "content": message})
    CHAT_HISTORY[session_id].append({"role": "assistant", "content": response_text})

    return response_text


def generate_speech(text: str) -> str | None:
    """Generate speech using OpenAI TTS."""
    if not openai_client:
        return None

    try:
        response = openai_client.audio.speech.create(
            model="tts-1",
            voice="alloy",
            input=text,
            response_format="mp3"
        )
        return base64.b64encode(response.content).decode('utf-8')
    except Exception as e:
        print(f"TTS failed: {e}")
        return None


@app.get("/health")
async def health_check():
    return {"status": "healthy", "mode": "voice-only"}


@app.post("/voice-chat", response_model=ChatResponse)
async def voice_chat(
    file: UploadFile = File(...),
    session_id: str = Form(...),
    language: str = Form(...) # Explicit language selection
):
    """Process voice audio, transcribe, think, and speak back in selected language."""
    
    # 1. Transcribe (Auto-detect language for transcription, but we ignore it for response)
    try:
        text_input, detected_lang_code = transcribe_audio(file.file)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    
    if not text_input.strip():
        raise HTTPException(status_code=400, detail="No speech detected")

    print(f"User said: {text_input} ({detected_lang_code}) -> Response requested in: {language}")

    # 2. Get AI Response (Strictly in requested language)
    # We pass the requested 'language' code, not the detected one
    response_text = get_ai_response(text_input, language, session_id)
    
    # 3. Generate Speech (Disabled due to quota/access issues, falling back to client-side TTS)
    # audio_base64 = generate_speech(response_text)
    audio_base64 = None
    
    return ChatResponse(
        text=response_text,
        audio_base64=audio_base64,
        language=language, # Return the requested language
        detected_language=language 
    )


# Serve static files
@app.get("/")
async def serve_index():
    return FileResponse("index.html")

@app.get("/{filename}")
async def serve_static(filename: str):
    if filename in ["styles.css", "script.js"]:
        return FileResponse(filename)
    raise HTTPException(status_code=404, detail="File not found")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
