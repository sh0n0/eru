import SwiftUI

struct CategoryListView: View {
    let categories: [QuestionCategory]
    @Binding var selection: QuestionCategory?

    var body: some View {
        List(categories, selection: $selection) { category in
            Label(category.name, systemImage: category.icon)
                .tag(category)
        }
        .navigationTitle("Eru")
    }
}
