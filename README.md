# LiveSubtitles

This repository holds a tiny prototype of an iOS application that listens to Greek speech and translates it into English.

## Speech Recognition with Whisper

The project now uses OpenAI's [Whisper](https://github.com/openai/whisper) model for offline transcription. Build the C++ implementation [`whisper.cpp`](https://github.com/ggerganov/whisper.cpp) as a static library for iOS and link it in your Xcode project. `WhisperRecognizer.swift` demonstrates a minimal wrapper around that library to capture microphone audio and run the model locally.

### Setup

1. Clone `whisper.cpp` and run `make ios` to produce `libwhisper.a` and its headers.
2. Add the library and headers to `LiveSubtitles.xcodeproj`.
3. Drag `WhisperRecognizer.swift` into your target.
4. Include `Privacy - Microphone Usage Description` in `Info.plist`.

`WhisperRecognizer` provides `startRecording()` and `stopRecording()` methods. After `stopRecording()` completes it returns the transcribed and translated text.

## Usage

Open the project in Xcode, integrate the compiled Whisper library, and use `WhisperRecognizer` to start and stop recognition as needed. The resulting English text can be fed into further translation or subtitle display logic.
