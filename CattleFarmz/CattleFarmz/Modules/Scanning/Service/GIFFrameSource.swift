import CoreGraphics
import Foundation
import ImageIO

/// Decodes only the requested, downsampled frame off the main actor.
actor GIFFrameSource {
    struct Frame: Sendable {
        let image: CGImage
        let duration: Double
    }

    private let source: CGImageSource
    nonisolated let frameCount: Int

    init?(url: URL) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else { return nil }
        self.source = source
        frameCount = CGImageSourceGetCount(source)
    }

    func frame(at index: Int) -> Frame? {
        guard (0..<frameCount).contains(index) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 512,
            kCGImageSourceShouldCache: false
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary) else { return nil }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
        let gif = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        let delay = gif?[kCGImagePropertyGIFUnclampedDelayTime] as? Double
            ?? gif?[kCGImagePropertyGIFDelayTime] as? Double
            ?? 0.1
        return Frame(image: image, duration: max(0.02, delay))
    }
}
