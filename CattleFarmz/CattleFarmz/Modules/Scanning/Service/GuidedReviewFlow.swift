import Foundation

public enum GuidedReviewStage: Equatable, Sendable {
    case inspection
    case point(Int)
    case results
}

/// UI-independent manual flow. A point counts only after the user presses
/// Continue. Editing invalidates that step and those after it.
public struct GuidedReviewFlow: Sendable {
    public let pointIDs: [String]
    public private(set) var stage: GuidedReviewStage = .inspection
    public private(set) var reviewedIDs: Set<String> = []

    public init(pointIDs: [String]) {
        precondition(!pointIDs.isEmpty && Set(pointIDs).count == pointIDs.count)
        self.pointIDs = pointIDs
    }
    public var currentIndex: Int? {
        if case .point(let index) = stage { return index }
        return nil
    }
    public var currentID: String? { currentIndex.map { pointIDs[$0] } }
    public var allReviewed: Bool { pointIDs.allSatisfy { reviewedIDs.contains($0) } }

    public mutating func begin() {
        reviewedIDs.removeAll()
        stage = .point(0)
    }
    public mutating func inspect() {
        reviewedIDs.removeAll()
        stage = .inspection
    }
    public mutating func invalidateCurrentAndFollowing() {
        guard let index = currentIndex else { return }
        reviewedIDs.subtract(pointIDs[index...])
    }
    @discardableResult public mutating func advance(hasUsablePoint: Bool) -> Bool {
        guard let index = currentIndex, hasUsablePoint else { return false }
        reviewedIDs.insert(pointIDs[index])
        stage = index + 1 < pointIDs.count ? .point(index + 1) : .results
        return true
    }
    public mutating func previous() {
        guard let index = currentIndex else { return }
        if index == 0 { inspect() }
        else { stage = .point(index - 1); invalidateCurrentAndFollowing() }
    }
    public mutating func edit(from index: Int) {
        guard pointIDs.indices.contains(index) else { return }
        // Earlier steps remain reviewed only when they have actually been reviewed.
        reviewedIDs.subtract(pointIDs[index...])
        stage = .point(index)
    }
}
