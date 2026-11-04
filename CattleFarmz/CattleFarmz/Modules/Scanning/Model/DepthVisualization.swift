import Foundation

public enum DepthVisualizationError: Error {
    case invalidDimensions
}

/// Top-left-origin RGBA8 image, already rotated to match the portrait RGB photo.
/// Gray checkerboard denotes samples rejected by the measurement-depth policy.
public struct DepthVisualization: Sendable {
    public let width: Int
    public let height: Int
    public let rgba: [UInt8]
    public let nearMeters: Double?
    public let farMeters: Double?
    public let validCount: Int
    public let totalCount: Int
    public var validFraction: Double { Double(validCount) / Double(max(1, totalCount)) }

    public init(frame: DepthFrame) throws {
        guard frame.width > 0, frame.height > 0,
              frame.width <= 8192, frame.height <= 8192,
              frame.meters.count == frame.width * frame.height,
              frame.confidence.count == frame.meters.count else {
            throw DepthVisualizationError.invalidDimensions
        }
        width = frame.height
        height = frame.width
        totalCount = frame.meters.count
        let values = frame.meters.indices.compactMap { index -> Double? in
            let value = Double(frame.meters[index])
            return DepthFrame.isUsableDepth(value, confidence: frame.confidence[index]) ? value : nil
        }
        validCount = values.count
        // Ignore extreme valid values when assigning display colors. They
        // remain valid depth; only the legend's color scale is clipped.
        let sorted = values.sorted()
        if sorted.count >= 20 {
            nearMeters = sorted[Int(Double(sorted.count - 1) * 0.05)]
            farMeters = sorted[Int(Double(sorted.count - 1) * 0.95)]
        } else {
            nearMeters = sorted.first
            farMeters = sorted.last
        }
        let near = nearMeters ?? 0
        let far = farMeters ?? 0
        let span = far - near
        var pixels = [UInt8](repeating: 255, count: totalCount * 4)
        for rawY in 0..<frame.height {
            for rawX in 0..<frame.width {
                let source = rawY * frame.width + rawX
                // Clockwise rotation: (x, y) -> (rawHeight - 1 - y, x).
                // This agrees with DepthFrame.portraitToRaw, including pixel centers.
                let portraitX = frame.height - 1 - rawY
                let portraitY = rawX
                let destination = (portraitY * width + portraitX) * 4
                let value = Double(frame.meters[source])
                let color: (UInt8, UInt8, UInt8)
                if DepthFrame.isUsableDepth(value, confidence: frame.confidence[source]) {
                    color = Self.color(at: span > 0 ? (value - near) / span : 0.5)
                } else {
                    let gray: UInt8 = ((portraitX / 4 + portraitY / 4) % 2 == 0) ? 55 : 88
                    color = (gray, gray, gray)
                }
                pixels[destination] = color.0
                pixels[destination + 1] = color.1
                pixels[destination + 2] = color.2
            }
        }
        rgba = pixels
    }

    /// Near = yellow; middle = teal; far = blue. Exact same stops drive the legend.
    public static func color(at fraction: Double) -> (UInt8, UInt8, UInt8) {
        let t = fraction.isFinite ? min(1, max(0, fraction)) : 0.5
        let near = (Double(248), Double(207), Double(67))
        let middle = (Double(39), Double(177), Double(153))
        let far = (Double(62), Double(77), Double(180))
        let a = t <= 0.5 ? near : middle
        let b = t <= 0.5 ? middle : far
        let local = t <= 0.5 ? t * 2 : (t - 0.5) * 2
        return (UInt8((a.0 + (b.0 - a.0) * local).rounded()),
                UInt8((a.1 + (b.1 - a.1) * local).rounded()),
                UInt8((a.2 + (b.2 - a.2) * local).rounded()))
    }
}
