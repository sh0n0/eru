import SwiftUI

struct QuestionListView: View {
    let category: QuestionCategory
    @Binding var selection: Question?

    var body: some View {
        List(category.questions, selection: $selection) { question in
            VStack(alignment: .leading, spacing: 4) {
                Text(question.text)
                    .font(.body)
                    .lineLimit(2)
                if let hint = question.hint {
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 2)
            .tag(question)
        }
        .navigationTitle(category.name)
    }
}
