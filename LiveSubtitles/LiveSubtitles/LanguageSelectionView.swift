import SwiftUI

struct LanguageSelectionView: View {
    let languages: [Language]
    @Binding var selected: Language
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(languages, id: \.self) { language in
                Button(language.name) {
                    selected = language
                    dismiss()
                }
            }
            .navigationTitle("Choose Language")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
