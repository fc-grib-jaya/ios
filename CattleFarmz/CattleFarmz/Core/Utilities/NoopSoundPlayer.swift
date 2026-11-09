//
//  NoopSoundPlayer.swift
//  CattleFarmz
//

/// No-op `SoundPlaying` for previews and tests.
@MainActor
final class NoopSoundPlayer: SoundPlaying {
    func prepare() {}
    func play(_ effect: SoundEffect) {}
}
