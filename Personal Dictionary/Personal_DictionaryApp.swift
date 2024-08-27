import SwiftUI

@main
struct YourAppApp: App {
    @StateObject private var bookmarkManager = BookmarkManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarkManager)
        }
    }
}
