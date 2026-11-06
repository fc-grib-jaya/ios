//
//  CameraPreview.swift
//  CattleFarmz
//

import ARKit
import RealityKit
import SwiftUI

/// Hosts the capture service's `ARSession` in an `ARView`.
///
/// The preview and the depth capture share one session, so the frame the user
/// sees is the frame that gets measured. Sessions are never started here;
/// `CaptureService` owns the lifecycle.
struct CameraPreview: UIViewRepresentable {
    let session: ARSession?

    func makeUIView(context: Context) -> UIView {
        guard let session else {
            // Mocks and previews have no camera; keep the layout stable.
            let view = UIView()
            view.backgroundColor = .black
            return view
        }
        let view = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )
        view.session = session
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {}
}
