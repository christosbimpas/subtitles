import Foundation
import NaturalLanguage

class Translator {
    private struct TranslateResult: Decodable {
        let translatedText: String
    }
    private func detectLanguage(of text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue
    }

    /// Translates the provided text. A specific source language can be
    /// supplied; otherwise automatic detection will be used.
    func translate(_ text: String, from source: String?, to target: String) async -> String {
        let source = source ?? detectLanguage(of: text) ?? "auto"
        guard let url = URL(string: "https://libretranslate.de/translate") else { return text }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let query = "q=" + (text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") + "&source=\(source)&target=\(target)&format=text"
        request.httpBody = query.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let result = try? JSONDecoder().decode(TranslateResult.self, from: data) {
                return result.translatedText
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("Unexpected translation response", raw)
            }
        } catch {
            print("Translation error", error)
        }
        return text
    }
}
