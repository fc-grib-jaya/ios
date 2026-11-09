//
//  ToastManager.swift
//  CattleFarmz
//

import Foundation
import Observation
import SwiftUI

/// Owns the toast presentation queue.
///
/// One instance is shared app-wide (see `DIContainer.toastManager`) and attached
/// once to the root container through `View.toast(manager:)`. The manager never
/// animates: it exposes the active item and an exit request, while `ToastView`
/// runs the timeline and reports back through `finish(_:)`.
///
/// Queue rules:
/// 1. A new request is appended to a FIFO queue.
/// 2. If no toast is active, it becomes active immediately.
/// 3. The view performs entrance and visible phases, then the exit animation.
/// 4. `finish(_:)` clears the active toast and presents the next queued one.
@Observable
@MainActor
final class ToastManager {
    /// The toast currently on screen, if any.
    private(set) var current: ToastItem?

    /// Identifier of the active toast whose exit animation was requested.
    ///
    /// The view compares this with `current?.id`, so a stale request can never
    /// dismiss a newer toast.
    private(set) var exitRequestID: UUID?

    private var queue: [ToastItem] = []
    private let haptics: any HapticProviding

    init(haptics: any HapticProviding) {
        self.haptics = haptics
    }

    /// Silent haptics, used by previews and tests.
    convenience init() {
        self.init(haptics: NoopHaptics())
    }

    /// Plays the tick that answers an overshoot of the entrance animation.
    ///
    /// The view calls this when the circle reaches an overshoot extreme, so the
    /// feedback is tied to the animation rather than to the request.
    func playOvershootFeedback() {
        haptics.play(.scanTick)
    }

    /// Enqueues a toast and presents it when no other toast is active.
    func show(
        _ message: String,
        icon: String = "checkmark",
        color: Color = .green,
        duration: Duration = .seconds(3)
    ) {
        queue.append(
            ToastItem(
                message: message,
                icon: icon,
                accentColor: color,
                duration: duration
            )
        )
        presentNextIfIdle()
    }

    /// Requests the exit animation of the active toast. Idempotent.
    func dismissCurrent() {
        guard let id = current?.id else { return }
        exitRequestID = id
    }

    /// Drops every queued toast and requests the exit of the active one.
    ///
    /// Queued items cannot reappear afterwards because the queue is cleared
    /// before the active toast finishes.
    func dismissAll() {
        queue.removeAll()
        dismissCurrent()
    }

    /// Reports that the exit animation of `id` completed.
    ///
    /// Stale or duplicate callbacks are ignored, so the queue advances once per
    /// toast. The next queued toast is presented only after this call, which
    /// guarantees the previous exit animation has already finished.
    func finish(_ id: UUID) {
        guard current?.id == id else { return }
        current = nil
        exitRequestID = nil
        presentNextIfIdle()
    }

    private func presentNextIfIdle() {
        guard current == nil, !queue.isEmpty else { return }
        let next = queue.removeFirst()
        exitRequestID = nil
        current = next
    }
}
