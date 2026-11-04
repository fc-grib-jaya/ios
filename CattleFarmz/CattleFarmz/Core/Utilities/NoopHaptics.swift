//
//  NoopHaptics.swift
//  CattleFarmz
//

/// No-op `HapticProviding` for previews and tests.
@MainActor
final class NoopHaptics: HapticProviding {
    func prepare() {}
    func play(_ pattern: HapticPattern) {}
}
