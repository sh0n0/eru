import Foundation
import SwiftData

@Model
final class PracticeSession {
    @Attribute(.unique) var id: UUID
    var questionId: String
    var questionText: String
    var transcript: String
    var audioFilename: String?
    var createdAt: Date
    var duration: TimeInterval

    init(questionId: String, questionText: String, transcript: String, audioFilename: String?, duration: TimeInterval) {
        self.id = UUID()
        self.questionId = questionId
        self.questionText = questionText
        self.transcript = transcript
        self.audioFilename = audioFilename
        self.createdAt = Date()
        self.duration = duration
    }

    var audioURL: URL? {
        guard let filename = audioFilename else { return nil }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(filename)
    }
}
