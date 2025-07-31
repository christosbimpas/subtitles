# subtitles

## Live Subtitles App

This repository now includes a minimal SwiftUI project demonstrating live subtitle capture on iOS.

### Features
* Select the subtitle language
* Start/stop listening with a single button
* Request microphone permissions with an explanation
* Display recognized speech live on screen (ready for translation)

### Choosing a Speech Recognition Model
For iOS, consider these options:
1. **Apple Speech framework**: Built-in and easy to integrate; performs speech recognition on device when supported or via Apple's servers.
2. **OpenAI Whisper**: High accuracy open-source model. A "faster-whisper" variant can run on-device with Metal or CPU acceleration. Requires bundling the model and bridging C/C++ code to Swift.
3. **Other SDKs**: Services like Google Cloud Speech-to-Text or Azure Speech also provide iOS SDKs, but require network connectivity.

If you prefer on-device processing with good speed, using Apple's built-in framework is simplest. Whisper provides strong accuracy but needs integration work.

### Building the project
The Swift package can be opened directly in Xcode 15 or later:

```bash
xed .
```

Once opened, build and run the `LiveSubtitlesApp` target on an iOS device or simulator.

The project requests microphone access via the `NSMicrophoneUsageDescription` key in `Info.plist`:

```
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone to capture audio for live subtitles.</string>
```

The live transcription is handled by `SubtitleManager` using `SFSpeechRecognizer`. Translation logic can be added in the same class if desired.

