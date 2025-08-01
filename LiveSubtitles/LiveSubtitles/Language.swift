import Foundation

struct Language: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
}

extension Language {
    static let supported: [Language] = [
        Language(code: "en", name: "English"),
        Language(code: "es", name: "Spanish"),
        Language(code: "fr", name: "French"),
        Language(code: "de", name: "German"),
        Language(code: "it", name: "Italian"),
        Language(code: "pt", name: "Portuguese"),
        Language(code: "ru", name: "Russian"),
        Language(code: "zh", name: "Chinese")
    ]
}
