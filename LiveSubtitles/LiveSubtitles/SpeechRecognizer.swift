import Foundation
import Speech
import AVFoundation

class SpeechRecognizer {
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start(locale: Locale = Locale(identifier: "en-US"), onResult: @escaping (String) -> Void) throws {
        stop()
        let recognizer = SFSpeechRecognizer(locale: locale)
        guard let recognizer = recognizer, recognizer.isAvailable else { return }

        audioEngine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request, let audioEngine = audioEngine else { return }
        request.shouldReportPartialResults = true

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                onResult(result.bestTranscription.formattedString)
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stop() {
        audioEngine?.stop()
        request?.endAudio()
        task?.cancel()
        audioEngine = nil
        request = nil
        task = nil
    }
}
