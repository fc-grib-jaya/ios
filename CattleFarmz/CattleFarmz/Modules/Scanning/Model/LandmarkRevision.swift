/// A capture owns one revision counter. Async work may publish only to its original revision.
nonisolated struct LandmarkRevision: Sendable {
    private(set) var value = 0
    mutating func advance() { value += 1 }
    func accepts(_ token: Int) -> Bool { value == token }
}
