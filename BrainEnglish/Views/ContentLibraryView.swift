import SwiftUI

struct ContentLibraryView: View {
    @EnvironmentObject var store: ContentStore
    @State private var searchText = ""

    private var filteredItems: [CapturedContent] {
        if searchText.isEmpty { return store.items }
        return store.items.filter {
            $0.rawText.localizedCaseInsensitiveContains(searchText) ||
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("My Library")
            .searchable(text: $searchText, prompt: "Search captured content")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 52))
                .foregroundStyle(.quaternary)
            Text("Nothing here yet")
                .font(.title3)
                .fontWeight(.medium)
            Text("Capture text from your study materials\nto start building your library.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var itemList: some View {
        List {
            ForEach(filteredItems) { item in
                NavigationLink(destination: ContentDetailView(item: item)) {
                    ContentRowView(item: item)
                }
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ContentRowView: View {
    let item: CapturedContent

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(methodColor(item.captureMethod).opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: item.captureMethod.systemImage)
                    .font(.system(size: 16))
                    .foregroundStyle(methodColor(item.captureMethod))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body)
                    .lineLimit(1)
                Text("\(item.sentences.count) sentence\(item.sentences.count == 1 ? "" : "s") · \(item.captureDate.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func methodColor(_ method: CaptureMethod) -> Color {
        switch method {
        case .camera: return .indigo
        case .album: return .purple
        case .typing: return .teal
        }
    }
}

struct ContentDetailView: View {
    let item: CapturedContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Source image if available
                if let data = item.sourceImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Sentences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Captured Text")
                        .font(.headline)

                    ForEach(Array(item.sentences.enumerated()), id: \.offset) { index, sentence in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.indigo)
                                .clipShape(Circle())
                            Text(sentence)
                                .font(.body)
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Raw text toggle
                DisclosureGroup("Raw Text") {
                    Text(item.rawText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentLibraryView()
        .environmentObject(ContentStore())
}
