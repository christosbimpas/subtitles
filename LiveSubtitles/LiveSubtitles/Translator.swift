import Foundation
import NaturalLanguage

class Translator {
    private func detectLanguage(of text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue
    }

    func translate(_ text: String, to target: String) async -> String {
        let source = detectLanguage(of: text) ?? "auto"
        guard let url = URL(string: "https://libretranslate.de/translate") else { return text }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let query = "q=" + (text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") + "&source=\(source)&target=\(target)&format=text"
        request.httpBody = query.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translated = json["translatedText"] as? String {
                return translated
            }
        } catch {
            print("Translation error", error)
        }
        return text
    }
}
