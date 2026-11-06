//
//  OrientationController.swift
//  CattleFarmz
//

import UIKit

/// App-wide interface orientation lock.
///
/// `AppDelegate` reports `mask` to UIKit; `lock(to:)` asks the active window
/// scene to rotate. One owner avoids per-view orientation state and keeps
/// rotation deterministic when a flow changes screens.
@MainActor
final class OrientationController {
    static let shared = OrientationController()

    /// Mask UIKit is currently allowed to rotate to.
    private(set) var mask: UIInterfaceOrientationMask = .portrait

    private init() {}

    /// Restricts supported orientations and asks the active scene to rotate.
    ///
    /// Idempotent: when the mask and the scene's orientation already match,
    /// no new geometry update is requested. Calling this from every appearing
    /// view would otherwise restart the rotation animation repeatedly.
    func lock(to mask: UIInterfaceOrientationMask) {
        let maskChanged = self.mask != mask
        self.mask = mask
        guard let scene = activeScene else { return }

        if currentOrientationSatisfies(mask, in: scene) {
            // The window is already where it should be; only notify UIKit if
            // the supported set changed.
            if maskChanged {
                scene.keyWindow?.rootViewController?
                    .setNeedsUpdateOfSupportedInterfaceOrientations()
            }
            return
        }

        scene.keyWindow?.rootViewController?
            .setNeedsUpdateOfSupportedInterfaceOrientations()
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
    }

    /// Waits until the active scene reports an orientation contained in `mask`.
    ///
    /// `requestGeometryUpdate` is asynchronous. Presenting a cover or a heavy
    /// view in the same run loop builds that view at the old size, then
    /// rebuilds it at the new size and snapshots it while the window rotates.
    /// Waiting for the scene geometry first makes the new view build once.
    /// Returns immediately when the orientation already matches, and gives up
    /// after `timeout` so a scene that cannot rotate never blocks the flow.
    func waitForOrientation(
        _ mask: UIInterfaceOrientationMask,
        timeout: Duration = .seconds(1)
    ) async {
        guard let scene = activeScene else { return }
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while clock.now < deadline {
            if currentOrientationSatisfies(mask, in: scene) { return }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func currentOrientationSatisfies(
        _ mask: UIInterfaceOrientationMask,
        in scene: UIWindowScene
    ) -> Bool {
        mask.contains(scene.effectiveGeometry.interfaceOrientation.mask)
    }

    /// Waits until the key window no longer presents a modal controller.
    ///
    /// SwiftUI clears `presentedViewController` only after a dismissal
    /// transition finishes. Rotating the window while that transition runs
    /// snapshots and rebuilds the cover mid-dismissal, which is the same
    /// glitch as presenting during a rotation.
    func waitForCoverDismissal(timeout: Duration = .seconds(1)) async {
        guard let scene = activeScene,
              let root = scene.keyWindow?.rootViewController else { return }
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        while clock.now < deadline {
            if !Self.isPresentingModal(from: root) { return }
            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private static func isPresentingModal(from controller: UIViewController) -> Bool {
        if controller.presentedViewController != nil { return true }
        for child in controller.children where isPresentingModal(from: child) {
            return true
        }
        return false
    }

    private var activeScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first
    }
}

private extension UIInterfaceOrientation {
    var mask: UIInterfaceOrientationMask {
        switch self {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeLeft
        case .landscapeRight: .landscapeRight
        case .unknown: .all
        @unknown default: .all
        }
    }
}
