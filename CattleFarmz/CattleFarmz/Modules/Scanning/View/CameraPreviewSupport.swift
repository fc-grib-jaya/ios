//
//  CameraPreviewSupport.swift
//  CattleFarmz
//

//#if DEBUG
import ARKit
import CoreGraphics

/// Camera-free `ScanCapturing` for SwiftUI previews.
///
/// No AR session is created, so previews never touch LiDAR hardware; capture
/// returns the synthetic fixture from `PreviewCattle`.
@MainActor
final class MockScanCapturing: ScanCapturing {
    var session: ARSession? { nil }
    var status = "Pratinjau kamera"
    var isReady = true
    var isBusy = false

    func start() {}
    func stop() {}

    func capture(
        viewportSize: CGSize,
        completion: @escaping (Result<Capture, Error>) -> Void
    ) {
        completion(.success(PreviewCattle.capture))
    }
}
//#endif
