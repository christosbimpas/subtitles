import Foundation
import AVFoundation
import Speech

enum SpeechRecognizerError: Error {
    case speechPermissionDenied
    case microphonePermissionDenied
    case recognizerUnavailable
}

/// Handles live speech recognition using Apple's Speech framework.
/// This version transcribes Greek audio from the microphone.
@MainActor
class SpeechRecognizer {
    private let speechRecognizer: SFSpeechRecognizer? =
        SFSpeechRecognizer(locale: Locale(identifier: "el-GR"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Requests speech and microphone permissions.
    func requestAuthorization() async throws {
        try await withCheckedThrowingContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .authorized:
                    continuation.resume()
                default:
                    continuation.resume(throwing: SpeechRecognizerError.speechPermissionDenied)
                }
            }
        }

        try await withCheckedThrowingContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: SpeechRecognizerError.microphonePermissionDenied)
                }
            }
        }
    }

    private func configureSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    /// Starts recording audio and delivering transcription results via the handler.
    func startRecording(resultHandler: @escaping (String) -> Void) throws {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw SpeechRecognizerError.recognizerUnavailable
        }

        try configureSession()

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                resultHandler(result.bestTranscription.formattedString)
            }
            if error != nil {
                self.stopRecording()
            }
        }
    }

    /// Stops recording and ends the current recognition task.
    func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
