//
//  CoreHapticsService.swift
//  CattleFarmz
//

import CoreHaptics

/// Live `HapticProviding` backed by a `CHHapticEngine`.
@MainActor
final class CoreHapticsService: HapticProviding {
    private var engine: CHHapticEngine?
    private let isSupported = CHHapticEngine.capabilitiesForHardware().supportsHaptics

    init() {}   // Cheap: engine is created in prepare()

    func prepare() {
        guard isSupported, engine == nil else { return }
        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = true
            engine.resetHandler = { [weak self] in
                Task { @MainActor in
                    self?.engine = nil
                    self?.prepare()
                }
            }
            try engine.start()
            self.engine = engine
        } catch {
            self.engine = nil
        }
    }

    func play(_ pattern: HapticPattern) {
        guard isSupported else { return }
        if engine == nil { prepare() }
        guard let engine else { return }
        do {
            let player = try engine.makePlayer(with: pattern.makeCHPattern())
            try engine.start()   // Restart if auto-shutdown kicked in
            try player.start(atTime: CHHapticTimeImmediate)
        } catch { }
    }
}
