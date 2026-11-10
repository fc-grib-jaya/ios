//
//  SoundPlaying.swift
//  CattleFarmz
//

/// Sound effects the app can play.
nonisolated enum SoundEffect: Hashable {
    /// Cow bell that accompanies the toast haptic.
    case cowBell

    /// File name inside the app bundle, without the extension.
    var resourceName: String {
        switch self {
        case .cowBell: "CowBell"
        }
    }

    var fileExtension: String {
        switch self {
        case .cowBell: "mp3"
        }
    }
}

/// Abstraction over audio playback so views and view models stay testable.
@MainActor
protocol SoundPlaying: AnyObject {
    /// Configures the audio session ahead of playback.
    func prepare()
    /// Plays the given effect, restarting it if it is already playing.
    func play(_ effect: SoundEffect)
}
