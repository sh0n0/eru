import SwiftUI
import SwiftData

struct PracticeView: View {
    let question: Question
    @State private var speechService = SpeechRecognitionService()
    @State private var audioPlayer = AudioPlayer()
    @State private var showHint = false
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [PracticeSession]

    init(question: Question) {
        self.question = question
        let id = question.id
        _sessions = Query(
            filter: #Predicate<PracticeSession> { $0.questionId == id },
            sort: \.createdAt,
            order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                questionSection
                Divider()
                currentRecordingSection
                if !sessions.isEmpty {
                    Divider()
                    pastSessionsSection
                }
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
            if speechService.isRecording {
                speechService.transcript = ""
            }
            speechService.stopRecording()
            audioPlayer.stop()
        }
        .onChange(of: speechService.isRecording) { wasRecording, isRecording in
            if wasRecording && !isRecording {
                savePendingSession()
            }
        }
    }

    // MARK: - Sections

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

    private var currentRecordingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CURRENT RECORDING")
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
                    .frame(minHeight: 100)

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

    private var pastSessionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PAST RECORDINGS (\(sessions.count))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .kerning(1)

            VStack(spacing: 0) {
                ForEach(sessions) { session in
                    SessionRowView(session: session, audioPlayer: audioPlayer) {
                        deleteSession(session)
                    }
                    if session.id != sessions.last?.id {
                        Divider().padding(.vertical, 4)
                    }
                }
            }
            .padding(12)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
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

    // MARK: - Actions

    private func savePendingSession() {
        guard !speechService.transcript.isEmpty else { return }
        let session = PracticeSession(
            questionId: question.id,
            questionText: question.text,
            transcript: speechService.transcript,
            audioFilename: speechService.lastAudioFilename,
            duration: speechService.lastRecordingDuration
        )
        modelContext.insert(session)
        speechService.transcript = ""
    }

    private func deleteSession(_ session: PracticeSession) {
        if audioPlayer.currentSessionId == session.id {
            audioPlayer.stop()
        }
        if let url = session.audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        modelContext.delete(session)
    }
}
