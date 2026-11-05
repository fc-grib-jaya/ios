//
//  ScanGeometry.swift
//  CattleFarmz
//

import CoreGraphics
import Foundation
import ImageIO

/// Orientation of the displayed image relative to the raw AR frame buffer.
///
/// ARKit delivers a landscape buffer regardless of how the device is held.
/// Storing the correction with the capture keeps landmark coordinates, depth
/// lookups, and the depth visualization in the same displayed frame.
nonisolated enum CaptureOrientation: Codable, Sendable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight

    /// EXIF rotation that turns the raw buffer into an upright display image.
    var exifOrientation: CGImagePropertyOrientation {
        switch self {
        case .portrait: .right
        case .portraitUpsideDown: .left
        case .landscapeLeft: .down
        case .landscapeRight: .up
        }
    }

    /// `true` when the display image is taller than it is wide.
    var swapsDimensions: Bool {
        switch self {
        case .portrait, .portraitUpsideDown: true
        case .landscapeLeft, .landscapeRight: false
        }
    }

    /// Inverse of rawPoint, used to display actual sampled pixel centers.
    func displayPoint(fromRaw point: Point2) -> Point2 {
        switch self {
        case .portrait: Point2(1 - point.y, point.x)
        case .portraitUpsideDown: Point2(point.y, 1 - point.x)
        case .landscapeLeft: Point2(1 - point.x, 1 - point.y)
        case .landscapeRight: point
        }
    }

    /// Maps a normalized point in the displayed image to the raw depth buffer.
    func rawPoint(fromDisplay point: Point2) -> Point2 {
        switch self {
        case .portrait:
            Point2(point.y, 1 - point.x)
        case .portraitUpsideDown:
            Point2(1 - point.y, point.x)
        case .landscapeLeft:
            Point2(1 - point.x, 1 - point.y)
        case .landscapeRight:
            point
        }
    }
}

/// Normalized point in the displayed capture image, top-left origin.
nonisolated struct Point2: Codable, Equatable, Sendable {
    var x: Double
    var y: Double

    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    var isValid: Bool {
        x.isFinite && y.isFinite && (0...1).contains(x) && (0...1).contains(y)
    }
}

nonisolated struct Vector3: Codable, Sendable {
    var x: Double
    var y: Double
    var z: Double

    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func +(a: Self, b: Self) -> Self { .init(a.x + b.x, a.y + b.y, a.z + b.z) }
    static func -(a: Self, b: Self) -> Self { .init(a.x - b.x, a.y - b.y, a.z - b.z) }
    static func *(a: Self, b: Double) -> Self { .init(a.x * b, a.y * b, a.z * b) }

    func dot(_ b: Self) -> Double { x * b.x + y * b.y + z * b.z }
    var norm: Double { sqrt(dot(self)) }
}

nonisolated struct CameraCalibration: Codable, Sendable {
    var fx: Double
    var fy: Double
    var cx: Double
    var cy: Double
    var width: Int
    var height: Int

    init(fx: Double, fy: Double, cx: Double, cy: Double, width: Int, height: Int) {
        self.fx = fx
        self.fy = fy
        self.cx = cx
        self.cy = cy
        self.width = width
        self.height = height
    }
}

/// A display crop in upright image coordinates. Depth and calibration stay full frame.
nonisolated struct ImageCrop: Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    static let full = ImageCrop(x: 0, y: 0, width: 1, height: 1)

    static func matchingPreview(imageSize: CGSize, viewportSize: CGSize) -> ImageCrop {
        guard imageSize.width > 0, imageSize.height > 0,
              viewportSize.width > 0, viewportSize.height > 0 else { return .full }
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewportSize.width / viewportSize.height
        if imageAspect > viewAspect {
            let width = Double(viewAspect / imageAspect)
            return ImageCrop(x: (1 - width) / 2, y: 0, width: width, height: 1)
        }
        let height = Double(imageAspect / viewAspect)
        return ImageCrop(x: 0, y: (1 - height) / 2, width: 1, height: height)
    }
}

/// Depth map plus intrinsics captured from one AR frame.
///
/// Image points passed to this type are normalized in the displayed capture
/// image, top-left origin. `orientation` maps them back to the raw AR buffer,
/// whose native layout is landscape. RGB is baked with the same EXIF rotation.
nonisolated struct DepthFrame: Codable, Sendable {
    var width: Int
    var height: Int
    var meters: [Float]
    var confidence: [UInt8]
    var calibration: CameraCalibration
    /// Orientation that turns this raw buffer into the displayed image.
    var orientation: CaptureOrientation

    nonisolated init(
        width: Int,
        height: Int,
        meters: [Float],
        confidence: [UInt8],
        calibration: CameraCalibration,
        orientation: CaptureOrientation = .portrait
    ) {
        self.width = width
        self.height = height
        self.meters = meters
        self.confidence = confidence
        self.calibration = calibration
        self.orientation = orientation
    }

    static func isUsableDepth(_ meters: Double, confidence: UInt8) -> Bool {
        confidence >= 1 && meters.isFinite && (0.25...5.0).contains(meters)
    }

    /// Samples depth at a point in the displayed image.
    func point(at displayPoint: Point2) throws -> Vector3 {
        guard displayPoint.isValid, width > 2, height > 2, meters.count == width * height,
              confidence.count == width * height,
              calibration.fx > 0, calibration.fy > 0 else {
            throw MeasurementError.invalidDepth
        }
        let uv = orientation.rawPoint(fromDisplay: displayPoint)
        let x = min(width - 1, max(0, Int(uv.x * Double(width))))
        let y = min(height - 1, max(0, Int(uv.y * Double(height))))
        let index = y * width + x
        let z = Double(meters[index])
        guard Self.isUsableDepth(z, confidence: confidence[index]) else {
            throw MeasurementError.invalidDepth
        }
        // Use exactly the selected sensor pixel and its center, never a median.
        return .init(
            ((Double(x) + 0.5) * Double(calibration.width) / Double(width) - calibration.cx) * z / calibration.fx,
            ((Double(y) + 0.5) * Double(calibration.height) / Double(height) - calibration.cy) * z / calibration.fy, z)
    }
}
