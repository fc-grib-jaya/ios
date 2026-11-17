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
/// Continue for its first confirmation. Valid edits preserve that confirmation.
struct GuidedReviewFlow: Sendable {
    let pointIDs: [String]
    private(set) var stage: GuidedReviewStage = .inspection
    private(set) var reviewedIDs: Set<String> = []
    private var confirmedIDs: Set<String> = []

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
        confirmedIDs.removeAll()
        stage = .point(0)
    }

    mutating func inspect() {
        reviewedIDs.removeAll()
        confirmedIDs.removeAll()
        stage = .inspection
    }

    mutating func invalidateCurrent() {
        guard let id = currentID else { return }
        reviewedIDs.remove(id)
        confirmedIDs.remove(id)
    }

    /// A confirmed point can pass through invalid depth during a drag and recover
    /// its checkmark when it reaches valid depth again, without another Continue.
    mutating func updateCurrentValidity(hasUsablePoint: Bool) {
        guard let id = currentID else { return }
        if hasUsablePoint && confirmedIDs.contains(id) {
            reviewedIDs.insert(id)
        } else {
            reviewedIDs.remove(id)
        }
    }

    @discardableResult
    mutating func selectPoint(at index: Int) -> Bool {
        guard stage != .inspection, pointIDs.indices.contains(index) else { return false }
        stage = .point(index)
        return true
    }

    @discardableResult
    mutating func advance(hasUsablePoint: Bool) -> Bool {
        guard let index = currentIndex, hasUsablePoint else { return false }
        confirmedIDs.insert(pointIDs[index])
        reviewedIDs.insert(pointIDs[index])
        if allReviewed {
            stage = .results
        } else {
            // Continue to the next unconfirmed point, wrapping after the last one.
            let next = (1...pointIDs.count)
                .map { (index + $0) % pointIDs.count }
                .first { !reviewedIDs.contains(pointIDs[$0]) }!
            stage = .point(next)
        }
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
            }
        case .results:
            stage = .point(pointIDs.count - 1)
        }
    }

    mutating func edit(from index: Int) {
        selectPoint(at: index)
    }
}
