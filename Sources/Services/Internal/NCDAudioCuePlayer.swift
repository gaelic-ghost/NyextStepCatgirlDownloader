import AVFAudio
import Foundation

@MainActor
final class NCDAudioCuePlayer {
    private let player: AVAudioPlayer?

    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "nyaa", withExtension: "m4a") else {
            player = nil
            return
        }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }

    func playReveal() {
        player?.currentTime = 0
        player?.play()
    }
}
