import SwiftUI

struct CaptureSelectionView: View {
    @EnvironmentObject var store: ContentStore
    @State private var showCamera = false
    @State private var showAlbum = false
    @State private var showTyping = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection

                Spacer()

                captureButtonsSection

                Spacer()

                recentPreviewSection
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                showCamera = false
                Task { await processImage(image, method: .camera) }
            } onCancel: {
                showCamera = false
            }
        }
        .sheet(isPresented: $showAlbum) {
            AlbumPickerView { image in
                showAlbum = false
                Task { await processImage(image, method: .album) }
            }
        }
        .sheet(isPresented: $showTyping) {
            TypingInputView { text in
                showTyping = false
                let content = CapturedContent(rawText: text, captureMethod: .typing)
                store.add(content)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundStyle(.indigo)
                .padding(.top, 24)

            Text("What did you study today?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Capture text from your study materials")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 32)
    }

    private var captureButtonsSection: some View {
        VStack(spacing: 16) {
            CaptureButton(
                icon: "camera.fill",
                title: "Take a Photo",
                subtitle: "Point at your textbook or worksheet",
                color: .indigo
            ) { showCamera = true }

            CaptureButton(
                icon: "photo.fill",
                title: "Choose from Album",
                subtitle: "Import a screenshot or saved image",
                color: .purple
            ) { showAlbum = true }

            CaptureButton(
                icon: "keyboard.fill",
                title: "Type It In",
                subtitle: "Enter a word, phrase, or sentence",
                color: .teal
            ) { showTyping = true }
        }
        .padding(.horizontal, 24)
    }

    private var recentPreviewSection: some View {
        Group {
            if !store.items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recently Captured")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.items.prefix(5)) { item in
                                RecentItemChip(item: item)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func processImage(_ image: UIImage, method: CaptureMethod) async {
        do {
            let text = try await VisionOCRProcessor.recognize(image: image)
            let imageData = image.jpegData(compressionQuality: 0.7)
            let content = CapturedContent(rawText: text, captureMethod: method, sourceImageData: imageData)
            store.add(content)
        } catch OCRError.noTextFound {
            // TODO: show alert
            print("No text found in image")
        } catch {
            print("OCR error: \(error)")
        }
    }
}

struct CaptureButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct RecentItemChip: View {
    let item: CapturedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: item.captureMethod.systemImage)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(item.title)
                .font(.caption)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
        .frame(width: 120, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CaptureSelectionView()
        .environmentObject(ContentStore())
}
