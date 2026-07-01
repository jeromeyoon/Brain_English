import Foundation
import Combine

@MainActor
class ContentStore: ObservableObject {
    @Published var items: [CapturedContent] = []

    private let saveURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("captured_content.json")
    }()

    init() {
        load()
    }

    func add(_ content: CapturedContent) {
        items.insert(content, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CapturedContent) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("ContentStore save error: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
        do {
            let data = try Data(contentsOf: saveURL)
            items = try JSONDecoder().decode([CapturedContent].self, from: data)
        } catch {
            print("ContentStore load error: \(error)")
        }
    }
}
