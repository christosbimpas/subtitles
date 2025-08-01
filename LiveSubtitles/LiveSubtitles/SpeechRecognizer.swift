import Foundation
import AVFoundation
import Speech

/// Handles live speech recognition using Apple's Speech framework.
/// This version transcribes Greek audio from the microphone.
class SpeechRecognizer {
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "el-GR"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Starts recording audio and delivering transcription results via the handler.
    func startRecording(resultHandler: @escaping (String) -> Void) throws {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer unavailable"]) 
        }

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
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
