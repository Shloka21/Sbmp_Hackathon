/**
 * Multilingual Voice Agent - Frontend Script
 * Manual Language Selection + Voice Interaction
 */

const API_BASE = '';
const SESSION_ID = 'session_' + Math.random().toString(36).substr(2, 9);

// DOM Elements
const recordBtn = document.getElementById('recordBtn');
const recordingIndicator = document.getElementById('recordingIndicator');
const chatContainer = document.getElementById('chatContainer');
const statusDiv = document.getElementById('status');
const audioPlayer = document.getElementById('audioPlayer');
const languageSelect = document.getElementById('language');

// State
let isRecording = false;
let mediaRecorder = null;
let audioChunks = [];
let currentAudioBase64 = null;
let isSpeaking = false;

// Initialize MediaRecorder
async function initMediaRecorder() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        mediaRecorder = new MediaRecorder(stream);

        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                audioChunks.push(event.data);
            }
        };

        mediaRecorder.onstop = () => {
            const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
            processAudio(audioBlob);
            audioChunks = [];
        };

        return true;
    } catch (err) {
        console.error("Error accessing microphone:", err);
        showStatus("Microphone access denied or error.", "error");
        return false;
    }
}

async function startRecording() {
    if (!mediaRecorder) {
        const success = await initMediaRecorder();
        if (!success) return;
    }

    stopAudio(); // Stop any playback
    audioChunks = [];
    mediaRecorder.start();
    isRecording = true;

    recordBtn.classList.add('recording');
    recordingIndicator.classList.remove('hidden');
    showStatus('Listening...', 'loading');
}

function stopRecording() {
    if (mediaRecorder && isRecording) {
        mediaRecorder.stop();
        isRecording = false;

        recordBtn.classList.remove('recording');
        recordingIndicator.classList.add('hidden');
        showStatus('Thinking...', 'loading');
    }
}

function addMessage(text, sender) {
    const div = document.createElement('div');
    div.className = `message ${sender}`;
    div.textContent = text;

    const welcome = chatContainer.querySelector('.welcome-message');
    if (welcome) welcome.remove();

    chatContainer.appendChild(div);
    chatContainer.scrollTop = chatContainer.scrollHeight;
}

async function processAudio(audioBlob) {
    // Add temporary user message
    const userMsgDiv = document.createElement('div');
    userMsgDiv.className = 'message user typing';
    userMsgDiv.textContent = '🎤 ...';
    chatContainer.appendChild(userMsgDiv);

    // Add placeholder bot message
    const botMsgDiv = document.createElement('div');
    botMsgDiv.className = 'message bot typing';
    botMsgDiv.textContent = '...';
    chatContainer.appendChild(botMsgDiv);
    chatContainer.scrollTop = chatContainer.scrollHeight;

    const formData = new FormData();
    formData.append('file', audioBlob, 'voice.webm');
    formData.append('session_id', SESSION_ID);
    formData.append('language', languageSelect.value); // Send selected language

    try {
        const response = await fetch(`${API_BASE}/voice-chat`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.detail || 'Failed to get response');
        }

        const data = await response.json();

        // Update messages
        userMsgDiv.textContent = "🎤 Voice Input";
        userMsgDiv.classList.remove('typing');

        botMsgDiv.classList.remove('typing');
        botMsgDiv.textContent = data.text;

        showStatus(`Speaking...`, 'success');

        // Handle audio
        if (data.audio_base64) {
            currentAudioBase64 = data.audio_base64;
            await playAudio(true);
        } else {
            // Fallback TTS
            speakText(data.text, languageSelect.value);
        }

    } catch (error) {
        console.error('Error:', error);
        userMsgDiv.textContent = "Error";
        botMsgDiv.textContent = `Error: ${error.message}`;
        botMsgDiv.style.color = 'var(--error)';
        showStatus('Error getting response', 'error');
    }
}

function stopAudio() {
    audioPlayer.pause();
    audioPlayer.currentTime = 0;
    window.speechSynthesis.cancel();
    isSpeaking = false;
}

async function playAudio(isBackendAudio) {
    stopAudio();

    if (isBackendAudio && currentAudioBase64) {
        const audioSrc = `data:audio/mp3;base64,${currentAudioBase64}`;
        audioPlayer.src = audioSrc;
        isSpeaking = true;

        try {
            await audioPlayer.play();
            audioPlayer.onended = () => {
                isSpeaking = false;
                showStatus('Tap microphone to reply', '');
            };
        } catch (e) {
            console.error('Auto-play failed:', e);
            showStatus('Tap to play audio', 'error');
        }
    }
}

function speakText(text, langCode) {
    stopAudio();
    if (!window.speechSynthesis) {
        showStatus('Browser TTS not supported', 'error');
        return;
    }

    // Wait for voices to load
    const voices = window.speechSynthesis.getVoices();
    if (voices.length === 0) {
        window.speechSynthesis.onvoiceschanged = () => speakText(text, langCode);
        return;
    }

    const utterance = new SpeechSynthesisUtterance(text);

    // Better Language Mapping
    const langMap = {
        'en': 'en-US',
        'hi': 'hi-IN',
        'gu': 'gu-IN',
        'bn': 'bn-IN',
        'te': 'te-IN',
        'kn': 'kn-IN',
        'ta': 'ta-IN',
        'mr': 'mr-IN',
        'pa': 'pa-IN',
        'ur': 'ur-PK'
    };
    const targetLang = langMap[langCode] || langCode;
    utterance.lang = targetLang;

    // Try to find a specific voice for the language
    const voice = voices.find(v => v.lang.includes(targetLang) || v.lang.includes(langCode));
    if (voice) {
        utterance.voice = voice;
        console.log(`Using voice: ${voice.name} for ${targetLang}`);
    } else {
        console.warn(`No specific voice found for ${targetLang}, using default`);
    }

    utterance.onstart = () => {
        isSpeaking = true;
        showStatus('Speaking (Browser)...', 'success');
    };

    utterance.onend = () => {
        isSpeaking = false;
        showStatus('Tap microphone to reply', '');
    };

    utterance.onerror = (e) => {
        console.error("TTS Error:", e);
        if (e.error !== 'interrupted') {
            showStatus(`TTS Error: ${e.error}`, 'error');
        }
    };

    window.speechSynthesis.speak(utterance);
}

// Event Listeners
recordBtn.addEventListener('click', () => {
    if (isRecording) stopRecording();
    else startRecording();
});

// Spacebar shortcut
document.addEventListener('keydown', (e) => {
    if (e.code === 'Space' && e.target.tagName !== 'SELECT' && !isSpeaking) {
        e.preventDefault();
        if (isRecording) stopRecording();
        else startRecording();
    }
});
