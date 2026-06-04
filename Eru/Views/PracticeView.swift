import SwiftUI

struct PracticeView: View {
    let question: Question
    @State private var speechService = SpeechRecognitionService()
    @State private var showHint = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                questionSection
                Divider()
                transcriptSection
            }
            .padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            recordButton
        }
        .navigationTitle("Practice")
        .task {
            await speechService.requestPermissions()
        }
        .onDisappear {
            speechService.stopRecording()
        }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUESTION")
                .font(.caption)
                .foregroundStyle(.secondary)
                .kerning(1)

            Text(question.text)
                .font(.title2)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            if let hint = question.hint {
                DisclosureGroup(isExpanded: $showHint) {
                    Text(hint)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                        .fixedSize(horizontal: false, vertical: true)
                } label: {
                    Label("Hint", systemImage: "lightbulb")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("YOUR ANSWER")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .kerning(1)

                Spacer()

                if !speechService.transcript.isEmpty {
                    Button("Clear") {
                        speechService.transcript = ""
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary)
                    .frame(minHeight: 120)

                if speechService.transcript.isEmpty {
                    Text(speechService.isRecording ? "Listening…" : "Tap the microphone button to start recording.")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(12)
                } else {
                    Text(speechService.transcript)
                        .font(.body)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if let error = speechService.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var recordButton: some View {
        HStack {
            Spacer()
            Button {
                if speechService.isRecording {
                    speechService.stopRecording()
                } else {
                    speechService.startRecording()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                        .symbolEffect(.pulse, isActive: speechService.isRecording)
                    Text(speechService.isRecording ? "Stop" : "Record")
                }
                .font(.headline)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(speechService.isRecording ? .red : .accentColor)
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }
}
