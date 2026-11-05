//
//  AppDelegate.swift
//  CattleFarmz
//

import UIKit

/// Delegates the app instance so SwiftUI can constrain supported orientations.
///
/// UIKit asks for this mask before honoring a rotation request, including
/// `UIWindowScene.requestGeometryUpdate`, so the value must stay in sync with
/// `OrientationController`.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationController.shared.mask
    }
}
