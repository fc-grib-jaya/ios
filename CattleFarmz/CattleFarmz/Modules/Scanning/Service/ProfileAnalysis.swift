import Foundation

nonisolated enum ProfileAnalysis {
    static func step(_ point: Point2, dx: Int, dy: Int, depth: DepthFrame, crop: ImageCrop) -> Point2? {
        let width = depth.orientation.swapsDimensions ? depth.height : depth.width
        let height = depth.orientation.swapsDimensions ? depth.width : depth.height
        let next = Point2(point.x + Double(dx) / Double(width), point.y + Double(dy) / Double(height))
        guard next.x >= crop.x, next.x <= crop.x + crop.width,
              next.y >= crop.y, next.y <= crop.y + crop.height else { return nil }
        return next
    }

    static func segments(_ profile: ChestDepthProfile) -> [[Vector3]] {
        var segments: [[Vector3]] = []
        for sample in profile.samples {
            guard let point = sample.point else { continue }
            if !sample.connectedToPrevious || segments.isEmpty { segments.append([]) }
            segments[segments.count - 1].append(point)
        }
        return segments
    }

    static func length(_ points: [Vector3]) -> Double {
        zip(points, points.dropFirst()).reduce(0) { $0 + ($1.1 - $1.0).norm * 100 }
    }

    static func complete(_ profile: ChestDepthProfile) -> Bool {
        profile.samples.count > 1 && profile.samples.allSatisfy { $0.point != nil }
            && profile.samples.dropFirst().allSatisfy(\.connectedToPrevious)
    }

    static func report(top: Point2, bottom: Point2, depth: DepthFrame, crop: ImageCrop) throws -> String {
        let original = try MeasurementEngine.chestProfile(top: top, bottom: bottom, depth: depth)
        let segments = segments(original)
        var lines = ["Panjang profil sisi terlihat (bukan lingkar dada penuh)"]
        for stride in 1...3 {
            let selected = segments.map { segment in
                var points = Swift.stride(from: 0, to: segment.count, by: stride).map { segment[$0] }
                if segment.count > 1 && (segment.count - 1) % stride != 0 { points.append(segment.last!) }
                return points
            }
            let lengthText = original.lengthCM == nil ? "tidak tersedia" : String(format: "%.2f cm", selected.reduce(0.0) { $0 + length($1) })
            lines.append("Stride \(stride): \(selected.reduce(0) { $0 + $1.count }) sampel · \(lengthText) · \(complete(original) ? "lengkap" : "parsial/terputus")")
        }
        lines.append("Perubahan panjang dapat berasal dari bentuk permukaan maupun noise. Sampel lebih banyak belum tentu lebih akurat.")
        lines.append("Sensitivitas terhadap pergeseran titik 1 piksel depth.")
        var comparable: [Double] = []
        var valid = 0, partial = 0, failed = 0
        for endpoint in 0...1 {
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                guard let shifted = step(endpoint == 0 ? top : bottom, dx: dx, dy: dy, depth: depth, crop: crop),
                      let variation = try? MeasurementEngine.chestProfile(top: endpoint == 0 ? shifted : top, bottom: endpoint == 1 ? shifted : bottom, depth: depth),
                      let value = variation.lengthCM else { failed += 1; continue }
                if complete(variation) {
                    valid += 1
                    if complete(original) { comparable.append(value) }
                } else { partial += 1 }
            }
        }
        lines.append("Asli: \(original.lengthCM.map { String(format: "%.2f cm", $0) } ?? "tidak tersedia") · \(complete(original) ? "lengkap" : "parsial/terputus")")
        lines.append("Variasi lengkap: \(valid) · terputus: \(partial) · gagal/di batas: \(failed)")
        if let baseline = original.lengthCM, let low = comparable.min(), let high = comparable.max() {
            lines.append(String(format: "Rentang lengkap: %.2f–%.2f cm · perubahan maksimum %.2f cm", low, high, comparable.map { abs($0 - baseline) }.max()!))
        } else { lines.append("Rentang tidak tersedia: hanya profil lengkap dibandingkan dengan profil asli lengkap.") }
        return lines.joined(separator: "\n\n")
    }
}
