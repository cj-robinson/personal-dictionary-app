import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            
            WordQuizView()
                .tabItem {
                    Label("Quiz", systemImage: "gamecontroller")
                }
        }
    }
}
