//
//  HapticPattern.swift
//  CattleFarmz
//

import CoreHaptics

extension HapticPattern {
    func makeCHPattern() throws -> CHHapticPattern {
        switch self {
        case .scanTick:
            return try CHHapticPattern(events: [transient(intensity: 0.4, sharpness: 0.6)],
                                       parameters: [])
        case .scanComplete:
            return try CHHapticPattern(events: [
                transient(intensity: 0.7, sharpness: 0.5, at: 0),
                transient(intensity: 1.0, sharpness: 0.8, at: 0.12)
            ], parameters: [])
        case .scanStart, .error:
            return try CHHapticPattern(events: [transient(intensity: 0.6, sharpness: 0.5)],
                                       parameters: [])
        }
    }

    private func transient(intensity: Float, sharpness: Float,
                           at time: TimeInterval = 0) -> CHHapticEvent {
        CHHapticEvent(eventType: .hapticTransient, parameters: [
            .init(parameterID: .hapticIntensity, value: intensity),
            .init(parameterID: .hapticSharpness, value: sharpness)
        ], relativeTime: time)
    }
}
