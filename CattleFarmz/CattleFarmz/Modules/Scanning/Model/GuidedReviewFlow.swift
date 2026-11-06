//
//  GuidedReviewFlow.swift
//  CattleFarmz
//

import Foundation

enum GuidedReviewStage: Equatable, Sendable {
    case inspection
    case point(Int)
    case results
}

/// UI-independent manual flow. A point counts only after the user presses
/// Continue. Editing invalidates that step and those after it.
struct GuidedReviewFlow: Sendable {
    let pointIDs: [String]
    private(set) var stage: GuidedReviewStage = .inspection
    private(set) var reviewedIDs: Set<String> = []

    init(pointIDs: [String]) {
        precondition(!pointIDs.isEmpty && Set(pointIDs).count == pointIDs.count)
        self.pointIDs = pointIDs
    }

    var currentIndex: Int? {
        if case .point(let index) = stage { return index }
        return nil
    }
    var currentID: String? { currentIndex.map { pointIDs[$0] } }
    var allReviewed: Bool { pointIDs.allSatisfy { reviewedIDs.contains($0) } }

    mutating func begin() {
        reviewedIDs.removeAll()
        stage = .point(0)
    }

    mutating func inspect() {
        reviewedIDs.removeAll()
        stage = .inspection
    }

    mutating func invalidateCurrentAndFollowing() {
        guard let index = currentIndex else { return }
        reviewedIDs.subtract(pointIDs[index...])
    }

    @discardableResult
    mutating func advance(hasUsablePoint: Bool) -> Bool {
        guard let index = currentIndex, hasUsablePoint else { return false }
        reviewedIDs.insert(pointIDs[index])
        stage = index + 1 < pointIDs.count ? .point(index + 1) : .results
        return true
    }

    mutating func previous() {
        switch stage {
        case .inspection:
            return
        case .point(let index):
            if index == 0 {
                inspect()
            } else {
                stage = .point(index - 1)
                invalidateCurrentAndFollowing()
            }
        case .results:
            stage = .point(pointIDs.count - 1)
            invalidateCurrentAndFollowing()
        }
    }

    mutating func edit(from index: Int) {
        guard pointIDs.indices.contains(index) else { return }
        // Earlier steps remain reviewed only when they have actually been reviewed.
        reviewedIDs.subtract(pointIDs[index...])
        stage = .point(index)
    }
}
