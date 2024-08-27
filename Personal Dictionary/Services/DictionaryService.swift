//
//  DictionaryService.swift
//  Personal Dictionary
//
//  Created by CJ Robinson on 7/28/24.
//

import Foundation

struct DictionaryService {
    static func fetchDefinitions(for word: String) async throws -> [String] {
        let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? word
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(encodedWord)"
        print("Attempting to access URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let entries = try decoder.decode([DictionaryEntry].self, from: data)
        
        var definitions: [String] = []
        for entry in entries {
            for meaning in entry.meanings {
                definitions.append(contentsOf: meaning.definitions.map { $0.definition })
            }
        }
        
        guard !definitions.isEmpty else {
            throw NSError(domain: "DictionaryService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No definitions found"])
        }
        
        return definitions
    }
}
struct DictionaryEntry: Codable {
    let meanings: [Meaning]
}

struct Meaning: Codable {
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
}
