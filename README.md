# LiveSubtitles

This repository contains the beginnings of an iOS application that captures Greek speech and eventually translates it into English.

## Speech Recognition

The initial approach relies on Apple's `Speech` framework. The `SpeechRecognizer` class under `LiveSubtitles/LiveSubtitles/SpeechRecognizer.swift` demonstrates how to start recording microphone audio and obtain live Greek transcriptions.

For improved accuracy and offline capabilities, the project can later integrate OpenAI's [Whisper](https://github.com/openai/whisper) model. A popular approach is to compile `whisper.cpp` for iOS and bridge it to Swift. This repository currently focuses on the simpler `Speech` framework setup while leaving room to swap in Whisper in the future.

## Usage

1. Open `LiveSubtitles.xcodeproj` in Xcode.
2. Drag `SpeechRecognizer.swift` into your app target.
3. Add `Privacy - Speech Recognition Usage Description` and `Privacy - Microphone Usage Description` to `Info.plist`.
4. Call `requestAuthorization()` once and use `startRecording` and `stopRecording` as needed.

The recognized Greek text can later be fed into a machine translation component.
