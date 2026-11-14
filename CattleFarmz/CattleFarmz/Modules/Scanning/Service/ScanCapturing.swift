//
//  ScanCapturing.swift
//  CattleFarmz
//

import ARKit
import CoreGraphics

/// Camera and LiDAR capture abstraction.
///
/// Keeps view models testable and lets previews run without LiDAR hardware.
/// Implementations must call `completion` on the main actor.
@MainActor
protocol ScanCapturing: AnyObject {
    /// Session backing the camera preview. Created lazily; mocks return `nil`.
    var session: ARSession? { get }
    /// Human-readable state shown under the camera preview.
    var status: String { get }
    /// `true` once a LiDAR depth frame is available.
    var isReady: Bool { get }
    /// `true` while a capture is being processed.
    var isBusy: Bool { get }
    /// Requests camera permission if needed and starts the AR session.
    /// Calls `onAccessDenied` when the user declines camera access.
    func start(onAccessDenied: @escaping () -> Void)
    /// Pauses the AR session and releases rendering resources.
    func stop()
    /// Copies the current RGB image and depth map into a `Capture`.
    func capture(viewportSize: CGSize, completion: @escaping (Result<Capture, Error>) -> Void)
}
