//
//  ScanCapture.swift
//  CattleFarmz
//

import CoreGraphics
import Foundation

/// A measurement landmark placed on the captured photo.
struct Landmark: Identifiable {
    let id: String
    let label: String
    var point: Point2
}

struct CaptureMetadata {
    let date: Date
    /// Raw depth is kept for measurements on the captured frame.
    let depth: DepthFrame
    /// ARKit's smoothed map is for visual inspection only, when available.
    let smoothedDepth: DepthFrame?
    let previewCrop: ImageCrop
}

/// One RGB image and the matching depth map from the same AR frame.
struct Capture: Identifiable {
    let id = UUID()
    let image: CGImage
    let metadata: CaptureMetadata
}

/// User-facing failure raised by the capture pipeline.
enum AppFailure: LocalizedError {
    case message(String)

    var errorDescription: String? {
        if case let .message(text) = self { return text }
        return nil
    }
}
