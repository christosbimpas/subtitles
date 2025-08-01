import SwiftUI
import AVFoundation
import Speech

@MainActor
final class SubtitlesViewModel: ObservableObject {
    @Published var selectedLanguage: Language? = nil
    @Published var isRecording = false
    @Published var translatedText = ""
    @Published var showSelector = false

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
            try? recognizer.start { [weak self] text in
                guard let self = self else { return }
                Task {
                    let target = self.selectedLanguage?.code ?? "en"
                    let translated = await self.translator.translate(text, to: target)
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
                Button(model.selectedLanguage?.name ?? "Select Language") {
                    model.showSelector = true
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
        .sheet(isPresented: $model.showSelector) {
            LanguageSelectionView(languages: Language.supported, selected: $model.selectedLanguage)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
