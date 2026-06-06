import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = KeychainService.load() ?? ""
    @State private var saved = false

    var body: some View {
        Form {
            Section("OpenAI") {
                SecureField("API Key", text: $apiKey)
                    .textContentType(.password)

                HStack {
                    Spacer()
                    Button("Save") {
                        KeychainService.save(apiKey)
                        saved = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if saved {
                Label("Saved", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 400)
        .onChange(of: apiKey) { saved = false }
    }
}
