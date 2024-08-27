import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var definitions: [String] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedDefinitionIndex: Int?
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        VStack {
            TextField("Search for a word", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                searchWord()
            }
            .disabled(searchText.isEmpty || isSearching)
            
            if isSearching {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if !definitions.isEmpty {
                List {
                    ForEach(definitions.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(definitions[index])
                            
                            Button("Bookmark this definition") {
                                bookmarkManager.addBookmark(word: searchText, definition: definitions[index])
                                selectedDefinitionIndex = index
                            }
                            .disabled(selectedDefinitionIndex == index)
                        }
                    }
                }
            }
            
            if !networkMonitor.isConnected {
                Text("No internet connection")
                    .foregroundColor(.red)
            }
        }
    }
    
    func searchWord() {
        guard networkMonitor.isConnected else {
            errorMessage = "No internet connection"
            return
        }
        
        isSearching = true
        errorMessage = nil
        selectedDefinitionIndex = nil
        
        Task {
            do {
                definitions = try await DictionaryService.fetchDefinitions(for: searchText)
            } catch {
                print("Error details: \(error)")
                errorMessage = "Error: \(error.localizedDescription)"
                definitions = []
            }
            isSearching = false
        }
    }
}
