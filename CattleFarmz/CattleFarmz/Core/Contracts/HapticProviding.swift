//
//  HapticProviding.swift
//  CattleFarmz
//

/// Haptic patterns the app can play.
enum HapticPattern {
    case scanStart, scanTick, scanComplete, error
}

/// Abstraction over Core Haptics so views and view models stay testable.
@MainActor
protocol HapticProviding: AnyObject {
    /// Warms up the haptic engine so the first playback has no latency.
    func prepare()
    /// Plays the given pattern, no-op if haptics are unsupported.
    func play(_ pattern: HapticPattern)
}
