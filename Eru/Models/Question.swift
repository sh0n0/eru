import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let hint: String?
}
