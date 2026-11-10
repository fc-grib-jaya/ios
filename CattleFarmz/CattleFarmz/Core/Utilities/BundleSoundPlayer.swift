//
//  BundleSoundPlayer.swift
//  CattleFarmz
//

import AVFoundation

/// Live `SoundPlaying` backed by bundled audio files.
@MainActor
final class BundleSoundPlayer: SoundPlaying {
    private let bundle: Bundle
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var isSessionConfigured = false

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func prepare() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true

        // Ambient + mixWithOthers: the effect never interrupts other audio and
        // follows the ringer switch, like the haptics it accompanies.
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient,
            mode: .default,
            options: [.mixWithOthers]
        )
    }

    func play(_ effect: SoundEffect) {
        prepare()

        let player: AVAudioPlayer
        if let cached = players[effect] {
            player = cached
        } else {
            guard let url = bundle.url(
                forResource: effect.resourceName,
                withExtension: effect.fileExtension
            ),
            let created = try? AVAudioPlayer(contentsOf: url)
            else { return }

            created.prepareToPlay()
            players[effect] = created
            player = created
        }

        // Restart from the top so overlapping toasts retrigger the bell.
        player.currentTime = 0
        player.play()
    }
}
