import Foundation

struct Language: Identifiable, Hashable {
    let id = UUID()
    /// Two letter translation code used by the translation API.
    let code: String
    /// Display name for the language.
    let name: String
    /// Optional locale identifier used for speech recognition.
    let speechCode: String?

    var locale: Locale? {
        guard let speechCode else { return nil }
        return Locale(identifier: speechCode)
    }
}

extension Language {
    /// Special value used when the input language should be detected
    /// automatically.
    static let automatic = Language(code: "auto", name: "Automatic", speechCode: nil)

    /// Languages supported for both speech recognition and translation.
    static let supported: [Language] = [
        Language(code: "en", name: "English", speechCode: "en-US"),
        Language(code: "es", name: "Spanish", speechCode: "es-ES"),
        Language(code: "fr", name: "French", speechCode: "fr-FR"),
        Language(code: "de", name: "German", speechCode: "de-DE"),
        Language(code: "it", name: "Italian", speechCode: "it-IT"),
        Language(code: "pt", name: "Portuguese", speechCode: "pt-PT"),
        Language(code: "ru", name: "Russian", speechCode: "ru-RU"),
        Language(code: "zh", name: "Chinese", speechCode: "zh-CN"),
        Language(code: "el", name: "Greek", speechCode: "el-GR")
    ]

    /// Available choices for the input language selector. The first entry
    /// enables automatic detection using the translator.
    static let inputChoices: [Language] = [automatic] + supported
}
