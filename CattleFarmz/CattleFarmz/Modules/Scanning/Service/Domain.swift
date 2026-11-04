import CoreGraphics
import Foundation

struct Landmark: Identifiable {
    let id: String
    let label: String
    var point: Point2
}

/// A display crop in upright image coordinates. Depth and calibration stay full frame.
struct ImageCrop {
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

struct CaptureMetadata {
    let date: Date
    /// Raw depth is kept for measurements on the captured frame.
    let depth: DepthFrame
    /// ARKit's smoothed map is for visual inspection only, when available.
    let smoothedDepth: DepthFrame?
    let previewCrop: ImageCrop
}

struct Capture: Identifiable {
    let id = UUID()
    let image: CGImage
    let metadata: CaptureMetadata
}

enum AppFailure: LocalizedError {
    case message(String)
    var errorDescription: String? {
        if case let .message(text) = self { return text }
        return nil
    }
}
