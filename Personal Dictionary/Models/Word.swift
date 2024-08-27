import Foundation

struct Word: Identifiable, Codable {
    var id: UUID
    let term: String
    let definition: String
    let dateAdded: Date
    
    init(id: UUID = UUID(), term: String, definition: String, dateAdded: Date = Date()) {
        self.id = id
        self.term = term
        self.definition = definition
        self.dateAdded = dateAdded
    }
}
