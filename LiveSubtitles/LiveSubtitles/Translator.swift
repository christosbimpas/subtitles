import Foundation
import NaturalLanguage

class Translator {
    /// Expected JSON response from LibreTranslate
    private struct TranslateResult: Decodable {
        let translatedText: String
    }
    /// Possible error returned by LibreTranslate
    private struct TranslateError: Decodable {
        let error: String
    }

    /// Base endpoint for the translation service. Can be overridden at
    /// runtime using the `LIBRETRANSLATE_URL` environment variable.
    private let endpoint: URL = {
        if let value = ProcessInfo.processInfo.environment["LIBRETRANSLATE_URL"],
           let url = URL(string: value) {
            return url
        }
        return URL(string: "https://translate.argosopentech.com/translate")!
    }()

    private func detectLanguage(of text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue
    }

    /// Translates the provided text. A specific source language can be
    /// supplied; otherwise automatic detection will be used.
    func translate(_ text: String, from source: String?, to target: String) async -> String {
        let source = source ?? detectLanguage(of: text) ?? "auto"
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let parameters = [
            "q": text,
            "source": source,
            "target": target,
            "format": "text"
        ]
        let body = parameters.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let result = try? JSONDecoder().decode(TranslateResult.self, from: data) {
                return result.translatedText
            }
            if let err = try? JSONDecoder().decode(TranslateError.self, from: data) {
                print("Translation error", err.error)
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
