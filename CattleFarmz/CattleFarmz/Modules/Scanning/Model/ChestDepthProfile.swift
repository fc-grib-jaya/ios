import Foundation

/// Actual raw depth pixels in traversal order; nil XYZ explicitly breaks the path.
struct ChestDepthProfile: Codable, Sendable {
    struct Sample: Codable, Sendable {
        let displayPoint: Point2
        let x: Int
        let y: Int
        let depth: Double
        let confidence: UInt8
        let point: Vector3?
        let status: String
        let connectedToPrevious: Bool
    }
    let samples: [Sample]
    let segmentLengthsCM: [Double]
    var lengthCM: Double? { segmentLengthsCM.isEmpty ? nil : segmentLengthsCM.reduce(0, +) }
}
