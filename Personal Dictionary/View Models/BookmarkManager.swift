//
//  BookmarkManager.swift
//  Personal Dictionary
//
//  Created by CJ Robinson on 7/28/24.
//

import Foundation

class BookmarkManager: ObservableObject {
    @Published var bookmarks: [Word] = []
    
    func addBookmark(word: String, definition: String) {
        if !bookmarks.contains(where: { $0.term == word && $0.definition == definition }) {
            let newWord = Word(term: word, definition: definition, dateAdded: Date())
            bookmarks.append(newWord)
            saveBookmarks()
        }
    }
    
    func removeBookmark(word: Word) {
        bookmarks.removeAll { $0.term == word.term }
        saveBookmarks()
    }
    
    func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: "SavedBookmarks")
        }
    }
    
    init() {
        if let savedBookmarks = UserDefaults.standard.data(forKey: "SavedBookmarks") {
            if let decodedBookmarks = try? JSONDecoder().decode([Word].self, from: savedBookmarks) {
                bookmarks = decodedBookmarks
                return
            }
        }
        bookmarks = []
    }
    
    func exportBookmarks() -> Result<URL, Error> {
        let fileName = "bookmarks.json"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(bookmarks)
            try data.write(to: fileURL)
            print("Export successful. File URL: \(fileURL)")
            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }
    func importBookmarks(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access the security-scoped resource.")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedBookmarks = try JSONDecoder().decode([Word].self, from: data)
            DispatchQueue.main.async {
                self.bookmarks = decodedBookmarks
                self.saveBookmarks()
            }
            print("Successfully imported bookmarks")
        } catch {
            print("Error importing bookmarks: \(error)")
        }
    }
}
