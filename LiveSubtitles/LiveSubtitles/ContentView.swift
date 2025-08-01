import SwiftUI
import AVFoundation
import Speech

@MainActor
final class SubtitlesViewModel: ObservableObject {
    @Published var inputLanguage: Language = .automatic
    @Published var outputLanguage: Language = Language.supported.first ?? .automatic
    @Published var isRecording = false
    @Published var translatedText = ""
    @Published var showInputSelector = false
    @Published var showOutputSelector = false

    private let recognizer = SpeechRecognizer()
    private let translator = Translator()

    func toggleRecording() {
        if isRecording {
            recognizer.stop()
            isRecording = false
        } else {
            translatedText = ""
            Task {
                let audioGranted = await withCheckedContinuation { cont in
                    AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                        cont.resume(returning: allowed)
                    }
                }
                guard audioGranted else { return }
            }
            SFSpeechRecognizer.requestAuthorization { _ in }
            isRecording = true
            let locale = inputLanguage.locale
            try? recognizer.start(locale: locale) { [weak self] text in
                guard let self = self else { return }
                Task {
                    let target = self.outputLanguage.code
                    let source = self.inputLanguage.code == "auto" ? nil : self.inputLanguage.code
                    let translated = await self.translator.translate(text, from: source, to: target)
                    await MainActor.run {
                        self.translatedText = translated
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var model = SubtitlesViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack {
                    Text("Input")
                    Button(model.inputLanguage.name) {
                        model.showInputSelector = true
                    }
                }
                VStack {
                    Text("Output")
                    Button(model.outputLanguage.name) {
                        model.showOutputSelector = true
                    }
                }
                Button(model.isRecording ? "Stop" : "Listen") {
                    model.toggleRecording()
                }
            }
            ScrollView {
                Text(model.translatedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .sheet(isPresented: $model.showInputSelector) {
            LanguageSelectionView(languages: Language.inputChoices, selected: $model.inputLanguage)
        }
        .sheet(isPresented: $model.showOutputSelector) {
            LanguageSelectionView(languages: Language.supported, selected: $model.outputLanguage)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
