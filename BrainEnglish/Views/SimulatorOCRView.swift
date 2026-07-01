import SwiftUI
import UIKit

// Simulator-only: generates a rendered text image to test Vision OCR pipeline
struct SimulatorOCRView: View {
    let onCapture: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSample = 0

    private let samples = [
        Sample(
            label: "Textbook sentence",
            text: "The water cycle describes how water evaporates from the surface of the earth, rises into the atmosphere, cools and condenses into rain or snow in clouds, and falls again to the surface."
        ),
        Sample(
            label: "Vocabulary list",
            text: "photosynthesis\nchlorophyll\nevaporation\ncondensation\nprecipitation"
        ),
        Sample(
            label: "Story passage",
            text: "Once upon a time, a little girl named Alice followed a white rabbit down a hole into a strange and wonderful world. She met many curious creatures along the way."
        ),
        Sample(
            label: "Spelling words",
            text: "beautiful\nfriend\nbecause\ntogether\ndifferent\npeople\nthrough\nschool"
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Simulator Mode")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())

                Text("Choose a sample to test Vision OCR")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Preview of rendered image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                    Text(samples[selectedSample].text)
                        .font(.system(size: 14, design: .serif))
                        .padding(16)
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 140)
                .padding(.horizontal, 24)

                // Sample picker
                VStack(spacing: 10) {
                    ForEach(Array(samples.enumerated()), id: \.offset) { index, sample in
                        Button {
                            selectedSample = index
                        } label: {
                            HStack {
                                Image(systemName: selectedSample == index ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedSample == index ? .indigo : .secondary)
                                Text(sample.label)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    let image = renderTextToImage(samples[selectedSample].text)
                    onCapture(image)
                } label: {
                    Label("Run OCR on This Sample", systemImage: "text.viewfinder")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Test with Sample")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func renderTextToImage(_ text: String) -> UIImage {
        let size = CGSize(width: 600, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            let inset = CGRect(x: 24, y: 24, width: size.width - 48, height: size.height - 48)
            text.draw(in: inset, withAttributes: attrs)
        }
    }

    struct Sample {
        let label: String
        let text: String
    }
}

#Preview {
    SimulatorOCRView { _ in }
}
