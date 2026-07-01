import Vision
import UIKit

enum OCRError: LocalizedError {
    case noTextFound
    case processingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noTextFound:
            return "No text was found in the image."
        case .processingFailed(let error):
            return "OCR processing failed: \(error.localizedDescription)"
        }
    }
}

struct VisionOCRProcessor {
    static func recognize(image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.noTextFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.processingFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                let recognizedText = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                if recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: recognizedText)
                }
            }

            // Use accurate recognition (slower but better for educational text)
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.processingFailed(error))
            }
        }
    }
}
