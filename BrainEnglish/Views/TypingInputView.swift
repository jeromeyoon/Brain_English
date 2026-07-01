import SwiftUI

struct TypingInputView: View {
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    private var isValid: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter what you studied")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $inputText)
                        .focused($isFocused)
                        .frame(minHeight: 160)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isFocused ? Color.indigo : Color.clear, lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Examples")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    ForEach(examples, id: \.self) { example in
                        Button {
                            inputText = example
                        } label: {
                            Text(example)
                                .font(.caption)
                                .foregroundStyle(.indigo)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.indigo.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                Button {
                    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onSave(trimmed)
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Color.indigo : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isValid)
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Type It In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isFocused = true }
        }
    }

    private let examples = [
        "The cat sat on the mat.",
        "She sells seashells by the seashore.",
        "photosynthesis"
    ]
}

#Preview {
    TypingInputView { text in
        print("Saved: \(text)")
    }
}
