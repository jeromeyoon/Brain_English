import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CaptureSelectionView()
                .tabItem {
                    Label("Capture", systemImage: "plus.circle.fill")
                }

            ContentLibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
        }
        .tint(.indigo)
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentStore())
}
