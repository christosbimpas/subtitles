//
//  ContentView.swift
//  LiveSubtitles
//
//  Created by Christos Bimpas on 01/08/2025.
//

import SwiftUI

/// View model that handles microphone recording using ``WhisperRecognizer`` and
/// exposes the transcribed text.
@MainActor
final class RecognizerViewModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false

    private var recognizer: WhisperRecognizer?

    init() {
        // Attempt to locate a whisper model bundled with the app. The model is
        // expected to be added to the application's resources by the developer.
        if let path = Bundle.main.path(forResource: "ggml-base.en", ofType: "bin") {
            recognizer = WhisperRecognizer(modelPath: path)
        }
    }

    /// Toggle microphone recording. When stopping the recording the recognised
    /// text is returned by `WhisperRecognizer` and published via `transcript`.
    func toggleRecording() {
        guard let recognizer else { return }

        if isRecording {
            // Stop and transcribe.
            if let text = recognizer.stopRecording() {
                transcript = text
            }
            isRecording = false
        } else {
            do {
                try recognizer.startRecording()
                isRecording = true
            } catch {
                // In a real application you might want to surface this error to the user.
                print("Failed to start recording: \(error)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = RecognizerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Text(viewModel.transcript.isEmpty ? "" : viewModel.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            Button(action: {
                viewModel.toggleRecording()
            }) {
                Text(viewModel.isRecording ? "Stop Listening" : "Start Listening")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(viewModel.isRecording ? Color.red : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
