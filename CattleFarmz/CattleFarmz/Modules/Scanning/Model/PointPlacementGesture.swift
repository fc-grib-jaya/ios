import CoreGraphics

/// Locks one target for an entire touch and preserves the finger-to-marker offset.
struct PointPlacementGesture {
    let targetID: String
    private let start: CGPoint
    private let offset: CGPoint
    private let startedOnMarker: Bool
    private(set) var didMove = false

    init?(
        start: CGPoint,
        activeID: String?,
        markers: [(id: String, position: CGPoint)]
    ) {
        let nearest = markers.min { lhs, rhs in
            hypot(lhs.position.x - start.x, lhs.position.y - start.y)
                < hypot(rhs.position.x - start.x, rhs.position.y - start.y)
        }
        let hit = nearest.flatMap {
            hypot($0.position.x - start.x, $0.position.y - start.y) <= 30 ? $0 : nil
        }
        guard let targetID = hit?.id ?? activeID else { return nil }
        self.targetID = targetID
        self.start = start
        startedOnMarker = hit != nil
        offset = hit.map { CGPoint(x: $0.position.x - start.x, y: $0.position.y - start.y) } ?? .zero
    }

    mutating func movedLocation(to location: CGPoint) -> CGPoint? {
        // A tap on a marker selects it without moving or confirming it.
        if startedOnMarker && !didMove && hypot(location.x - start.x, location.y - start.y) < 4 {
            return nil
        }
        didMove = true
        return CGPoint(x: location.x + offset.x, y: location.y + offset.y)
    }
}
