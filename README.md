# LiveSubtitles

This repository contains the beginnings of an iOS application that captures Greek speech and eventually translates it into English.

## Speech Recognition

The initial approach relies on Apple's `Speech` framework. The `SpeechRecognizer` class under `LiveSubtitles/SpeechRecognizer.swift` demonstrates how to start recording microphone audio and obtain live Greek transcriptions.

For improved accuracy and offline capabilities, the project can later integrate OpenAI's [Whisper](https://github.com/openai/whisper) model. A popular approach is to compile `whisper.cpp` for iOS and bridge it to Swift. This repository currently focuses on the simpler `Speech` framework setup while leaving room to swap in Whisper in the future.

## Usage

1. Open `LiveSubtitles.xcodeproj` in Xcode.
2. Add `SpeechRecognizer.swift` to your target.
3. Request microphone and speech recognition permissions in your app's Info.plist.
4. Use the `SpeechRecognizer` class to start and stop recognition.

The recognized Greek text can later be fed into a machine translation component.
