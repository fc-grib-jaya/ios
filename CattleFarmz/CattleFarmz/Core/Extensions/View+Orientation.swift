//
//  View+Orientation.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

extension View {
    /// Locks the app to landscape right while this view is on screen.
    ///
    /// The lock is app-wide. The flow that opened the view restores portrait
    /// when it ends; see `AppCoordinator.dismissCover()`.
    func forceLandscape() -> some View {
        modifier(OrientationLockModifier(mask: .landscapeRight))
    }

    /// Locks the app back to portrait while this view is on screen.
    ///
    /// Use on the screen that owns a portrait flow so switching back to it
    /// always restores the default orientation.
    func forcePortrait() -> some View {
        modifier(OrientationLockModifier(mask: .portrait))
    }
}

private struct OrientationLockModifier: ViewModifier {
    let mask: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content.onAppear {
            OrientationController.shared.lock(to: mask)
        }
    }
}
