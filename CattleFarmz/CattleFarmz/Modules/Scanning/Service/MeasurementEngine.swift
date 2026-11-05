//
//  MeasurementEngine.swift
//  CattleFarmz
//

import Foundation

/// Stateless measurement math: 3D landmark distance, chest girth fit, and the
/// Winter weight formula.
enum MeasurementEngine {
    /// Position along the marked chest height, and observed 3D bulge in meters.
    struct SectionSample {
        let t: Double
        let radius: Double
    }

    static func distance(_ a: Point2, _ b: Point2, in depth: DepthFrame) throws -> Double {
        let distance = try (depth.point(at: a) - depth.point(at: b)).norm * 100
        guard distance.isFinite, distance > 1, distance < 500 else {
            throw MeasurementError.invalidLength
        }
        return distance
    }

    static func winter(lengthCM: Double, girthCM: Double) -> Double? {
        guard lengthCM.isFinite, girthCM.isFinite, lengthCM > 0, girthCM > 0 else { return nil }
        return girthCM * girthCM * lengthCM / 10815.15
    }

    /// MLS → multiquadric RBF → mirrored 3D curve length. The depth map
    /// observes only one side; symmetry is an explicit, unvalidated prior.
    static func girth(top: Point2, bottom: Point2, in depth: DepthFrame) throws -> GirthEstimate {
        guard top.isValid, bottom.isValid, abs(top.y - bottom.y) > 0.05,
              abs(top.x - bottom.x) < 0.10 else { throw MeasurementError.invalidSection }
        func location(_ t: Double, _ offset: Double = 0) -> Point2 {
            .init(top.x + (bottom.x - top.x) * t + offset, top.y + (bottom.y - top.y) * t)
        }
        // Silhouette pixels are often mixed with background. Anchor the axis
        // just inside the body, then extrapolate back to the marked boundaries.
        let starts = [0.08, 0.12, 0.16]
        let ends = [0.92, 0.88, 0.84]
        guard let start = starts.compactMap({ t -> (Double, Vector3)? in
            guard let q = try? depth.point(at: location(t)) else { return nil }
            return (t, q)
        }).first,
            let end = ends.compactMap({ t -> (Double, Vector3)? in
                guard let q = try? depth.point(at: location(t)) else { return nil }
                return (t, q)
            }).first else { throw MeasurementError.insufficientSection(0) }
        let slope = (end.1 - start.1) * (1 / (end.0 - start.0))
        let upper = start.1 - slope * start.0
        let lower = start.1 + slope * (1 - start.0)
        let axis = lower - upper
        let height = axis.norm
        let b = height / 2
        guard height > 0.15, height < 2.2 else { throw MeasurementError.invalidSection }
        let unit = axis * (1 / height)
        let center = (upper + lower) * 0.5
        let towardCamera = Vector3(0, 0, -1)
        let radial = towardCamera - unit * towardCamera.dot(unit)
        guard radial.norm > 0.3 else { throw MeasurementError.invalidSection }
        let radialUnit = radial * (1 / radial.norm)
        var samples = [SectionSample]()
        for i in 0...30 {
            let t = 0.10 + 0.80 * Double(i) / 30
            let offsets = [-2.0, -1.0, 0.0, 1.0, 2.0].map { $0 / Double(depth.height) }
            let values = offsets.compactMap { offset -> Double? in
                guard let q = try? depth.point(at: location(t, offset)) else { return nil }
                let relative = q - center
                let axial = relative.dot(unit) / b
                guard abs(axial) < 0.98 else { return nil }
                return relative.dot(radialUnit)
            }.sorted()
            guard values.count >= 2 else { continue }
            let bulge = values[values.count / 2]
            let q = start.1 + slope * (t - start.0)
            // Axial parameter is determined from the section axis, not the
            // depth of an occluding leg at the same image row.
            let relative = q - center
            let axial = relative.dot(unit) / b
            guard abs(axial) < 0.98 else { continue }
            if bulge > -0.04 { samples.append(.init(t: t, radius: bulge)) }
        }
        guard samples.count >= 15, samples.first!.t < 0.28, samples.last!.t > 0.72
        else { throw MeasurementError.insufficientSection(samples.count) }
        let smoothed = mlsSmooth(samples)
        // The two boundary markers represent radius zero. They are constraints
        // for closing the mirrored loop, not invented depth observations.
        let controls = [SectionSample(t: 0, radius: 0)] + smoothed + [SectionSample(t: 1, radius: 0)]
        guard let coefficients = rbfCoefficients(controls) else { throw MeasurementError.badFit(.infinity) }
        func radius(_ t: Double) -> Double {
            if t <= 0 || t >= 1 { return 0 }
            return max(0, rbfValue(t, controls: controls, coefficients: coefficients))
        }
        let squaredError = samples.reduce(0.0) { sum, sample in
            sum + pow(sample.radius - radius(sample.t), 2)
        }
        let residual = sqrt(squaredError / Double(samples.count))
        let a = (0...80).map { radius(Double($0) / 80) }.max() ?? 0
        guard a.isFinite, a > 0.04, a / b > 0.12, a / b < 1.5,
              residual.isFinite, residual < 0.075
        else { throw MeasurementError.badFit(residual) }
        var visibleLength = 0.0
        var previous = upper
        for i in 1...80 {
            let t = Double(i) / 80
            let q = upper + axis * t + radialUnit * radius(t)
            visibleLength += (q - previous).norm
            previous = q
        }
        // The hidden side is mirrored about the chord through Chest1/Chest2.
        let circumference = visibleLength * 2
        guard circumference.isFinite, circumference > 0.3, circumference < 6
        else { throw MeasurementError.badFit(residual) }
        return .init(
            centimeters: circumference * 100,
            semiHeightMeters: b,
            semiWidthMeters: a,
            residualMeters: residual,
            validSamples: samples.count,
            method: "visible-depth-mls-rbf-mirror-v1"
        )
    }

    /// Linear moving least squares with a Gaussian spatial window.
    /// At each observed t, solve for the local intercept and slope.
    static func mlsSmooth(_ samples: [SectionSample]) -> [SectionSample] {
        let bandwidth = 0.10
        return samples.map { center in
            var s0 = 0.0, s1 = 0.0, s2 = 0.0, y0 = 0.0, y1 = 0.0
            for sample in samples {
                let d = sample.t - center.t
                let weight = exp(-0.5 * pow(d / bandwidth, 2))
                s0 += weight
                s1 += weight * d
                s2 += weight * d * d
                y0 += weight * sample.radius
                y1 += weight * d * sample.radius
            }
            let determinant = s0 * s2 - s1 * s1
            let fitted = determinant > 1e-10 ? (y0 * s2 - y1 * s1) / determinant : center.radius
            return SectionSample(t: center.t, radius: fitted)
        }
    }

    /// Multiquadric RBF plus affine polynomial; a small diagonal term smooths
    /// depth noise. Solve the augmented interpolation system with pivoting.
    static func rbfCoefficients(_ points: [SectionSample]) -> [Double]? {
        let count = points.count
        let size = count + 2
        guard count >= 3 else { return nil }
        func kernel(_ a: Double, _ b: Double) -> Double {
            sqrt(1 + pow((a - b) / 0.12, 2))
        }
        var matrix = [[Double]](
            repeating: [Double](repeating: 0, count: size + 1),
            count: size
        )
        for i in 0..<count {
            for j in 0..<count { matrix[i][j] = kernel(points[i].t, points[j].t) }
            matrix[i][i] += 0.001
            matrix[i][count] = 1
            matrix[i][count + 1] = points[i].t
            matrix[i][size] = points[i].radius
            matrix[count][i] = 1
            matrix[count + 1][i] = points[i].t
        }
        for column in 0..<size {
            var pivot = column
            for row in column..<size {
                if abs(matrix[row][column]) > abs(matrix[pivot][column]) { pivot = row }
            }
            guard abs(matrix[pivot][column]) > 1e-10 else { return nil }
            if pivot != column { matrix.swapAt(pivot, column) }
            let divisor = matrix[column][column]
            for j in column...size { matrix[column][j] /= divisor }
            for row in 0..<size where row != column {
                let factor = matrix[row][column]
                if factor == 0 { continue }
                for j in column...size { matrix[row][j] -= factor * matrix[column][j] }
            }
        }
        let solution = matrix.map { $0[size] }
        return solution.allSatisfy(\.isFinite) ? solution : nil
    }

    static func rbfValue(_ t: Double, controls: [SectionSample], coefficients: [Double]) -> Double {
        let count = controls.count
        var value = coefficients[count] + coefficients[count + 1] * t
        for i in 0..<count {
            value += coefficients[i] * sqrt(1 + pow((t - controls[i].t) / 0.12, 2))
        }
        return value
    }

    static func cattle(
        shoulder: Point2,
        pin: Point2,
        top: Point2,
        bottom: Point2,
        depth: DepthFrame
    ) throws -> MeasurementResult {
        let length = try distance(shoulder, pin, in: depth)
        let profile = try chestProfile(top: top, bottom: bottom, depth: depth)
        return .init(lengthCM: length, girth: nil, weightKG: nil,
                     warning: profile.lengthCM == nil ? "Profil dada: belum ada pasangan piksel tersambung." : nil,
                     formulaVersion: "raw-depth-profile-v1", profile: profile)
    }

    static func chestProfile(top: Point2, bottom: Point2, depth: DepthFrame) throws -> ChestDepthProfile {
        guard top.isValid, bottom.isValid, depth.width > 0, depth.height > 0,
              depth.meters.count == depth.width * depth.height,
              depth.confidence.count == depth.meters.count,
              depth.calibration.fx > 0, depth.calibration.fy > 0 else {
            throw MeasurementError.invalidDepth
        }
        let a = depth.orientation.rawPoint(fromDisplay: top)
        let b = depth.orientation.rawPoint(fromDisplay: bottom)
        func pixel(_ p: Point2) -> (Int, Int) {
            (min(depth.width - 1, Int(p.x * Double(depth.width))),
             min(depth.height - 1, Int(p.y * Double(depth.height))))
        }
        var (x, y) = pixel(a)
        let (endX, endY) = pixel(b)
        let dx = abs(endX - x), dy = -abs(endY - y)
        let sx = x < endX ? 1 : -1, sy = y < endY ? 1 : -1
        var error = dx + dy
        var samples: [ChestDepthProfile.Sample] = []
        var lengths: [Double] = []
        var previous: Vector3?
        var activeSegment = false
        let c = depth.calibration
        while true {
            let index = y * depth.width + x
            let z = Double(depth.meters[index])
            let confidence = depth.confidence[index]
            var status = "Terbaca"
            var point: Vector3?
            if !z.isFinite || z <= 0 { status = "Depth kosong/tidak valid" }
            else if confidence < 1 { status = "Confidence rendah" }
            else if !(0.25...5).contains(z) { status = "Di luar 0,25–5 m" }
            else {
                point = Vector3(
                    ((Double(x) + 0.5) * Double(c.width) / Double(depth.width) - c.cx) * z / c.fx,
                    ((Double(y) + 0.5) * Double(c.height) / Double(depth.height) - c.cy) * z / c.fy, z)
            }
            var connected = false
            if let point, let previous {
                // Explicit diagnostic discontinuity threshold, not a fitted bridge.
                if abs(point.z - previous.z) < 0.08 {
                    if !activeSegment { lengths.append(0); activeSegment = true }
                    lengths[lengths.count - 1] += (point - previous).norm * 100
                    connected = true
                } else { status = "Putus: lonjakan depth ≥8 cm"; activeSegment = false }
            } else { activeSegment = false }
            let displayPoint = depth.orientation.displayPoint(fromRaw: Point2(
                (Double(x) + 0.5) / Double(depth.width),
                (Double(y) + 0.5) / Double(depth.height)))
            samples.append(.init(displayPoint: displayPoint, x: x, y: y, depth: z, confidence: confidence,
                                 point: point, status: status, connectedToPrevious: connected))
            previous = point
            if x == endX && y == endY { break }
            let twice = 2 * error
            if twice >= dy { error += dy; x += sx }
            if twice <= dx { error += dx; y += sy }
        }
        return ChestDepthProfile(samples: samples, segmentLengthsCM: lengths)
    }
}
