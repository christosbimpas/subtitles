import SwiftUI

struct ContentView: View {
    @StateObject private var manager = SubtitleManager()
    @State private var showLanguages = false

    var body: some View {
        VStack(spacing: 24) {
            Button(manager.selectedLanguageName) {
                showLanguages = true
            }
            .sheet(isPresented: $showLanguages) {
                LanguageSelectionView(selected: $manager.selectedLocaleIdentifier)
            }

            ScrollView {
                Text(manager.translatedText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            .frame(maxHeight: 200)

            Button(action: {
                if manager.isListening {
                    manager.stop()
                } else {
                    manager.start()
                }
            }) {
                Text(manager.isListening ? "Stop" : "Start")
                    .font(.title)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!manager.permissionGranted)
        }
        .padding()
        .onAppear {
            manager.requestPermission()
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var selected: String

    var body: some View {
        NavigationView {
            List {
                ForEach(SubtitleManager.supportedLocales, id: \.identifier) { locale in
                    Button(action: {
                        selected = locale.identifier
                    }) {
                        HStack {
                            Text(locale.localizedString(forLanguageCode: locale.languageCode ?? locale.identifier) ?? locale.identifier)
                            if selected == locale.identifier {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Language")
        }
    }
}

#Preview {
    ContentView()
}
