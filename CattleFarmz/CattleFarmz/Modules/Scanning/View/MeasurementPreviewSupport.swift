import CoreGraphics
import Foundation

//#if DEBUG
/// Camera-free fixtures for SwiftUI previews. All geometry lives in upright
/// portrait coordinates so landmarks, the photo, and the depth map agree.
enum MeasurementPreviewStage {
    case inspection
    case point(Int)
    case results
}

enum PreviewCattle {
    /// Portrait pixel size of the synthetic photo.
    static let photoSize = CGSize(width: 320, height: 240)
    /// Region (normalized portrait) whose depth samples are usable.
    static let bodyRect = CGRect(x: 0.08, y: 0.35, width: 0.74, height: 0.45)

    static let shoulder = Point2(0.22, 0.53)
    static let pin = Point2(0.72, 0.52)
    static let chestTop = Point2(0.34, 0.44)
    static let chestBottom = Point2(0.34, 0.72)

    static var landmarks: [String: Point2] {
        [
            "shoulder": shoulder,
            "pin": pin,
            "chestTop": chestTop,
            "chestBottom": chestBottom,
        ]
    }

    static let result = MeasurementResult(
        lengthCM: 142.0,
        girth: GirthEstimate(
            centimeters: 178.0,
            semiHeightMeters: 0.42,
            semiWidthMeters: 0.28,
            residualMeters: 0.006,
            validSamples: 28,
            method: "visible-depth-mls-rbf-mirror-v1"
        ),
        weightKG: 416.0,
        warning: nil,
        formulaVersion: "Winter-cm-10815.15-v1"
    )

    static let capture: Capture = Capture(
        image: photo,
        metadata: CaptureMetadata(
            date: Date(timeIntervalSinceReferenceDate: 0),
            depth: depthFrame,
            smoothedDepth: nil,
            previewCrop: .full
        )
    )

    /// Simple side-view scene: sky, ground, and a brown cow silhouette.
    private static let photo: CGImage = {
        let width = Int(photoSize.width), height = Int(photoSize.height)
        let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        // CGContext's origin is bottom-left; flip y for portrait top-left drawing.
        func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: x, y: photoSize.height - y - h, width: w, height: h)
        }
        context.setFillColor(CGColor(red: 0.75, green: 0.89, blue: 0.95, alpha: 1))
        context.fill(rect(0, 0, photoSize.width, 170))
        context.setFillColor(CGColor(red: 0.56, green: 0.75, blue: 0.42, alpha: 1))
        context.fill(rect(0, 170, photoSize.width, 70))

        context.setFillColor(CGColor(red: 0.43, green: 0.33, blue: 0.25, alpha: 1))
        for x: CGFloat in [92, 118, 172, 198] {
            context.fill(rect(x, 150, 11, 52))
        }
        context.setFillColor(CGColor(red: 0.54, green: 0.42, blue: 0.31, alpha: 1))
        context.fillEllipse(in: rect(40, 97, 185, 76))
        context.fillEllipse(in: rect(222, 92, 40, 40))
        return context.makeImage()!
    }()

    /// Raw landscape buffer (240×320) matching the 320×240 portrait photo.
    /// Depth rises gently left-to-right so the visualization shows a gradient.
    private static let depthFrame: DepthFrame = {
        let rawWidth = 240, rawHeight = 320
        var meters = [Float](
            repeating: Float.nan, count: rawWidth * rawHeight
        )
        let confidence = [UInt8](
            repeating: 0, count: rawWidth * rawHeight
        )
        for rawY in 0..<rawHeight {
            for rawX in 0..<rawWidth {
                let portraitX = Double(rawHeight - 1 - rawY) / Double(rawHeight)
                let portraitY = Double(rawX) / Double(rawWidth)
                guard bodyRect.contains(
                    CGPoint(x: portraitX, y: portraitY)
                ) else { continue }
                let index = rawY * rawWidth + rawX
                let fraction = (portraitX - bodyRect.minX) / bodyRect.width
                meters[index] = Float(2.0 + 0.15 * fraction)
            }
        }
        // Confidence is rebuilt so usable samples read as valid (>= 1).
        var usableConfidence = confidence
        for index in meters.indices where meters[index].isFinite {
            usableConfidence[index] = 2
        }
        return DepthFrame(
            width: rawWidth, height: rawHeight,
            meters: meters.map { $0.isFinite ? $0 : 0 },
            confidence: usableConfidence,
            calibration: CameraCalibration(
                fx: 600, fy: 600, cx: 120, cy: 160,
                width: rawWidth, height: rawHeight
            )
        )
    }()

    /// Deterministic depth preview built without a render queue, so preview
    /// view models can prepare synchronously.
    static let depthPreview: DepthPreview = {
        let visualization = try! DepthVisualization(frame: depthFrame)
        let data = Data(visualization.rgba) as CFData
        let provider = CGDataProvider(data: data)!
        let image = CGImage(
            width: visualization.width,
            height: visualization.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: visualization.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(
                rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
                    | CGBitmapInfo.byteOrder32Big.rawValue
            ),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
        return DepthPreview(image: image, visualization: visualization)
    }()
}

/// Completes synchronously so `MeasurementViewModel.prepare()` is usable in
/// previews, where no render queue can deliver a result.
struct MockDepthRenderer: DepthRendering {
    func render(
        _ frame: DepthFrame,
        completion: @escaping (Result<DepthPreview, Error>) -> Void
    ) {
        completion(.success(PreviewCattle.depthPreview))
    }
}
//#endif
