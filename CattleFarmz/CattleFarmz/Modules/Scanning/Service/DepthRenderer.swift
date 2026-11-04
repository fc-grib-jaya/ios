import CoreGraphics
import RealityKit
import SwiftUI

struct DepthPreview {
    let image: CGImage
    let visualization: DepthVisualization
}

final class DepthRenderer {
    private let queue = DispatchQueue(label: "capture.depthPreview", qos: .userInitiated)

    func render(_ frame: DepthFrame, completion: @escaping (Result<DepthPreview, Error>) -> Void) {
        queue.async {
            let outcome: Result<DepthPreview, Error> = Result {
                let pixels = try DepthVisualization(frame: frame)
                let data = Data(pixels.rgba) as CFData
                guard let provider = CGDataProvider(data: data),
                      let cg = CGImage(width: pixels.width, height: pixels.height,
                                       bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: pixels.width * 4,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
                                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
                    throw AppFailure.message("Visualisasi depth gagal dibuat. Coba ambil ulang.")
                }
                return DepthPreview(image: cg, visualization: pixels)
            }
            DispatchQueue.main.async { completion(outcome) }
        }
    }
}
