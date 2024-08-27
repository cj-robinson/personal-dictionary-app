import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var sortOption = SortOption.dateAdded
    @State private var isImporting = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingExportSuccessAlert = false
    @State private var exportFilePath = ""
    
    enum SortOption {
        case dateAdded
        case alphabetical
    }
    
    var sortedBookmarks: [Word] {
        switch sortOption {
        case .dateAdded:
            return bookmarkManager.bookmarks.sorted { $0.dateAdded > $1.dateAdded }
        case .alphabetical:
            return bookmarkManager.bookmarks.sorted { $0.term.lowercased() < $1.term.lowercased() }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedBookmarks) { word in
                    VStack(alignment: .leading) {
                        Text(word.term)
                            .font(.headline)
                        Text(word.definition)
                            .font(.subheadline)
                        Text("Added: \(word.dateAdded, formatter: itemFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort by", selection: $sortOption) {
                            Text("Date Added").tag(SortOption.dateAdded)
                            Text("Alphabetical").tag(SortOption.alphabetical)
                        }
                        
                        Button("Export Bookmarks") {
                            print("Export button tapped")
                            switch bookmarkManager.exportBookmarks() {
                            case .success(let url):
                                print("Export success, URL: \(url)")
                                exportFilePath = url.path
                                showingExportSuccessAlert = true
                                saveFileToFilesApp(url: url)
                            case .failure(let error):
                                print("Export failure: \(error)")
                                errorMessage = error.localizedDescription
                                showingErrorAlert = true
                            }
                        }

                        
                        Button("Import Bookmarks") {
                            isImporting = true
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    bookmarkManager.importBookmarks(from: url)
                case .failure(let error):
                    print("Import error: \(error)")
                }
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Export Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showingExportSuccessAlert) {
                Alert(title: Text("Export Successful"), message: Text("Bookmarks have been exported successfully to: \(exportFilePath)"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveFileToFilesApp(url: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
    }

    func deleteBookmarks(at offsets: IndexSet) {
        for index in offsets {
            let wordToDelete = sortedBookmarks[index]
            if let indexInOriginal = bookmarkManager.bookmarks.firstIndex(where: { $0.id == wordToDelete.id }) {
                bookmarkManager.bookmarks.remove(at: indexInOriginal)
            }
        }
        bookmarkManager.saveBookmarks()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
