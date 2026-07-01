import Foundation

enum CaptureMethod: String, Codable, CaseIterable {
    case camera = "camera"
    case album = "album"
    case typing = "typing"

    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .album: return "Album"
        case .typing: return "Typed"
        }
    }

    var systemImage: String {
        switch self {
        case .camera: return "camera.fill"
        case .album: return "photo.fill"
        case .typing: return "keyboard.fill"
        }
    }
}

struct CapturedContent: Identifiable, Codable {
    var id: UUID = UUID()
    var rawText: String
    var sentences: [String]
    var captureMethod: CaptureMethod
    var captureDate: Date = Date()
    var sourceImageData: Data?
    var title: String

    init(rawText: String, captureMethod: CaptureMethod, sourceImageData: Data? = nil) {
        self.rawText = rawText
        self.captureMethod = captureMethod
        self.sourceImageData = sourceImageData
        self.sentences = CapturedContent.extractSentences(from: rawText)
        // Use first sentence fragment as title
        self.title = sentences.first.map { String($0.prefix(50)) } ?? String(rawText.prefix(50))
    }

    static func extractSentences(from text: String) -> [String] {
        let cleaned = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        var sentences: [String] = []
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(cleaned.startIndex..., in: cleaned)

        // Use NLTokenizer for sentence segmentation
        let tokenizer = cleaned.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count > 3 }

        return tokenizer.isEmpty ? [cleaned] : tokenizer
    }
}
