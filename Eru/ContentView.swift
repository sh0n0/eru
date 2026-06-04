import SwiftUI

struct ContentView: View {
    @State private var categories: [QuestionCategory] = []
    @State private var selectedCategory: QuestionCategory?
    @State private var selectedQuestion: Question?

    var body: some View {
        NavigationSplitView {
            CategoryListView(categories: categories, selection: $selectedCategory)
        } content: {
            if let category = selectedCategory {
                QuestionListView(category: category, selection: $selectedQuestion)
            } else {
                ContentUnavailableView("Select a Category", systemImage: "list.bullet")
            }
        } detail: {
            if let question = selectedQuestion {
                PracticeView(question: question)
                    .id(question.id)
            } else {
                ContentUnavailableView(
                    "Select a Question",
                    systemImage: "mic",
                    description: Text("Choose a question from the list to start practicing.")
                )
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            selectedQuestion = nil
        }
        .onAppear {
            categories = (try? QuestionsLoader.load()) ?? []
        }
    }
}
