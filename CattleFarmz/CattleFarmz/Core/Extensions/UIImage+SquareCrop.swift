//
//  UIImage+SquareCrop.swift
//  CattleFarmz
//

import UIKit

extension UIImage {
    /// Returns a centered square image with a stable `.up` orientation.
    ///
    /// LiDAR captures arrive as a CGImage-backed UIImage. Cropping the CGImage
    /// directly also removes any transient orientation metadata before the
    /// image is passed between forms or persisted.
    func cattleSquareCropped() -> UIImage? {
        guard let cgImage else { return nil }

        let side = min(cgImage.width, cgImage.height)
        let cropRect = CGRect(
            x: (cgImage.width - side) / 2,
            y: (cgImage.height - side) / 2,
            width: side,
            height: side
        )

        guard let croppedImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedImage, scale: scale, orientation: .up)
    }
}
