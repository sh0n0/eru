import Foundation

struct QuestionsLoader {
    static func load() throws -> [QuestionCategory] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(QuestionsData.self, from: data).categories
    }
}
