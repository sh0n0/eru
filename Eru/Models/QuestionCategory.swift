import Foundation

struct QuestionCategory: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let questions: [Question]
}

struct QuestionsData: Codable {
    let categories: [QuestionCategory]
}
