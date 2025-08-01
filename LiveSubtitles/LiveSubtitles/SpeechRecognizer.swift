import Foundation
import Speech
import AVFoundation

class SpeechRecognizer {
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    /// Starts listening using the provided locale. If no locale is supplied the
    /// device's current locale is used.
    func start(locale: Locale? = nil, onResult: @escaping (String) -> Void) throws {
        stop()
        let recognizer = SFSpeechRecognizer(locale: locale ?? Locale.current)
        guard let recognizer = recognizer, recognizer.isAvailable else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

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
