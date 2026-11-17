import Foundation

enum RationSeason: String, CaseIterable, Identifiable {
    case wet
    case dry

    var id: Self { self }
    var displayName: String { self == .wet ? "Hujan" : "Kemarau" }

    init(date: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .gmt
        self = [11, 12, 1, 2, 3, 4].contains(calendar.component(.month, from: date)) ? .wet : .dry
    }

    /// Ranking preferences from the existing app guidance, not an availability or inclusion limit.
    func priority(for feed: FeedIngredient) -> Int {
        let name = feed.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let preferred: Set<String>
        switch self {
        case .wet:
            preferred = ["rumput gajah", "rumput raja", "rumput benggala", "rumput setaria",
                         "rumput odot", "rumput brachiaria", "rumput panicum maximum", "rumput mott"]
        case .dry:
            preferred = ["silase jagung", "hay alfalfa"]
        }
        return preferred.contains(name) ? 1 : 0
    }
}
