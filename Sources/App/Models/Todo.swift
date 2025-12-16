import Foundation

struct Todo: Codable, Identifiable {
    let id: String
    let text: String
    let desc: String
    let position: Int
    let isCompleted: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case desc
        case position
        case isCompleted = "is_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TodosResponse: Codable {
    let todos: [Todo]
}
