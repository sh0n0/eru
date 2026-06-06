import SwiftUI

struct SessionRowView: View {
    let session: PracticeSession
    let audioPlayer: AudioPlayer
    let onDelete: () -> Void

    private var isPlaying: Bool {
        audioPlayer.isPlaying && audioPlayer.currentSessionId == session.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Text(formatDuration(session.duration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let wpm = session.wpm {
                            Text("\(wpm) WPM")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                if session.audioURL != nil {
                    Button {
                        audioPlayer.toggle(session: session)
                    } label: {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isPlaying ? .red : .accentColor)
                            .symbolEffect(.pulse, isActive: isPlaying)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(session.transcript)
                .font(.callout)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
