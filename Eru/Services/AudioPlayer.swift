import AVFoundation
import Observation

@Observable
final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var isPlaying = false
    private(set) var currentSessionId: UUID?
    private var player: AVAudioPlayer?

    func toggle(session: PracticeSession) {
        if currentSessionId == session.id && isPlaying {
            stop()
        } else {
            play(session: session)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentSessionId = nil
    }

    private func play(session: PracticeSession) {
        guard let url = session.audioURL else { return }
        stop()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            currentSessionId = session.id
        } catch {
            isPlaying = false
            currentSessionId = nil
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentSessionId = nil
        self.player = nil
    }
}
