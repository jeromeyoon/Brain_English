import SwiftUI

@main
struct BrainEnglishApp: App {
    @StateObject private var store = ContentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
