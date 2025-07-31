import Foundation
import AVFoundation
import Speech

class SubtitleManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var translatedText: String = ""
    @Published var selectedLocaleIdentifier: String = Locale.current.identifier
    @Published var isListening: Bool = false
    @Published var permissionGranted: Bool = false

    private var recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    static var supportedLocales: [Locale] {
        SFSpeechRecognizer.supportedLocales().map { Locale(identifier: $0.identifier) }.sorted { $0.identifier < $1.identifier }
    }

    var selectedLanguageName: String {
        Locale.current.localizedString(forIdentifier: selectedLocaleIdentifier) ?? selectedLocaleIdentifier
    }

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.permissionGranted = status == .authorized
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.permissionGranted = self.permissionGranted && granted
            }
        }
    }

    func start() {
        guard permissionGranted else { return }
        translatedText = ""
        isListening = true
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: selectedLocaleIdentifier))
        request = SFSpeechAudioBufferRecognitionRequest()
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request?.append(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
        task = recognizer?.recognitionTask(with: request!) { result, error in
            if let text = result?.bestTranscription.formattedString {
                DispatchQueue.main.async {
                    // Placeholder for translation step
                    self.translatedText = text
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stop()
            }
        }
    }

    func stop() {
        isListening = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
    }
}
