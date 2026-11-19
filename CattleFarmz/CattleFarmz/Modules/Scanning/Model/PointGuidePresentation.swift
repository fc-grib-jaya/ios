import Foundation

/// Remembers automatic hints for one captured photo. Manual help is always available.
struct PointGuidePresentation {
    private(set) var visitedIDs: Set<String> = []
    private(set) var visibleStepID: String?

    mutating func visit(stepID: String?, alreadyPlaced: Bool) {
        visibleStepID = nil
        guard let stepID else { return }
        let firstVisit = visitedIDs.insert(stepID).inserted
        if firstVisit && !alreadyPlaced {
            visibleStepID = stepID
        }
    }

    mutating func dismiss() { visibleStepID = nil }

    mutating func toggle(stepID: String) {
        visitedIDs.insert(stepID)
        visibleStepID = visibleStepID == stepID ? nil : stepID
    }
}
