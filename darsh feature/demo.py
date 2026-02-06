import pyttsx3
import os
from groq import Groq

# Using working Groq keys from .env
GROQ_API_KEY = "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"
client = Groq(api_key=GROQ_API_KEY)

# Hardcoded translations for "Hi, how can I help you?" for reliability
PHRASE_TRANSLATIONS = {
    "1": ("English", "Hi, how can I help you?"),
    "2": ("Hindi", "नमस्ते, मैं आपकी क्या मदद कर सकता हूँ?"),
    "3": ("Marathi", "नमस्कार, मी तुम्हाला कशी मदत करू शकतो?"),
    "4": ("Tamil", "வணக்கம், நான் உங்களுக்கு எப்படி உதவ முடியும்?"),
    "5": ("Telugu", "నమస్కారం, నేను మీకు ఎలా సహాయం చేయగలను?"),
    "6": ("Bengali", "নমস্কার, আমি আপনাকে কীভাবে সাহায্য করতে পারি?"),
    "7": ("Gujarati", "નમસ્તે, હું તમને કેવી રીતે મદદ કરી શકું?"),
    "8": ("Kannada", "ನಮಸ್ಕಾರ, ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?"),
    "9": ("Urdu", "ہیلو، میں آپ کی کیا مدد کر سکتا ہوں؟")
}

# TTS Setup
engine = pyttsx3.init()
engine.setProperty("rate", 160)

def speak(text):
    print(f"AI Speaking: {text}")
    engine.say(text)
    engine.runAndWait()

def get_ai_translation(text, target_language):
    """Fallback translation using Groq if needed for other phrases."""
    try:
        print(f"Translating to {target_language} using Groq...")
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {
                    "role": "system",
                    "content": f"Translate the following phrase into {target_language}. Return ONLY the translated text. No explanation."
                },
                {
                    "role": "user",
                    "content": text
                }
            ]
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        print(f"Groq translation failed: {e}")
        return None

print("\n🔊 Instant Translation Speech Player")
print("Target Phrase: 'Hi, how can I help you?'")

while True:
    print("\n🌐 Select Language to hear:")
    for k, v in PHRASE_TRANSLATIONS.items():
        print(f"{k}. {v[0]}")
    print("q. Quit")

    choice = input("\nEnter choice: ")
    
    if choice.lower() == 'q':
        print("Goodbye!")
        break
        
    entry = PHRASE_TRANSLATIONS.get(choice)
    if entry:
        lang_name, translated_text = entry
        speak(translated_text)
    else:
        print("Invalid choice. Please try again.")
