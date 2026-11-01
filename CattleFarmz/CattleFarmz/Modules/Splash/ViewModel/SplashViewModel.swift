//
//  SplashViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Drives the splash screen: exposes the displayed name and reports when the
/// startup delay has elapsed.
@Observable
@MainActor
final class SplashViewModel {
    /// Name shown while the splash screen is visible.
    let appName: String

    /// Invoked once the splash delay elapses. The `App` layer wires it to the
    /// coordinator's splash-to-main transition.
    var onFinished: () -> Void

    /// Time the splash screen stays visible.
    private let displayDuration: Duration

    init(
        appName: String = "CattleFarmz",
        displayDuration: Duration = .seconds(1.5),
        onFinished: @escaping () -> Void = {}
    ) {
        self.appName = appName
        self.displayDuration = displayDuration
        self.onFinished = onFinished
    }

    /// Waits for the splash delay, then notifies the caller. Cancellation (for
    /// example when the view disappears early) skips the notification.
    func start() async {
        do {
            try await Task.sleep(for: displayDuration)
        } catch {
            return
        }
        onFinished()
    }
}
