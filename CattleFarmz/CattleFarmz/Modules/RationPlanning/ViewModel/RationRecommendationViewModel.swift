import Foundation
import Observation

@Observable
@MainActor
final class RationRecommendationViewModel {
    let alternatives: [RationRecommendation]
    private(set) var selected: RationRecommendation
    private(set) var portionText: String
    private(set) var scenario: RationCalculationResult?
    private(set) var errorMessage: String?
    @ObservationIgnored private let engine: RationRecommendationEngine

    var sourceAmount: Double {
        selected.before.items.first { $0.id == selected.removedIngredient.id }?.kilogramsPerAnimalPerDay ?? 0
    }

    init(recommendation: RationRecommendation, alternatives: [RationRecommendation], engine: RationRecommendationEngine) {
        self.selected = recommendation
        var seen = Set<String>()
        self.alternatives = ([recommendation] + alternatives).filter {
            $0.before.items == recommendation.before.items && seen.insert($0.id).inserted
        }
        self.engine = engine
        self.portionText = Self.suggestedPortion(recommendation)
        recalculate()
    }

    var focusTarget: RationRecommendationTarget { selected.focusTarget }

    var hasDifferentSources: Bool {
        Set(alternatives.map { $0.removedIngredient.id }).count > 1
    }

    private static func suggestedPortion(_ recommendation: RationRecommendation) -> String {
        let available = recommendation.before.items.first { $0.id == recommendation.removedIngredient.id }?.kilogramsPerAnimalPerDay ?? 0
        var decimalAvailable = Decimal(available)
        var roundedAvailable = Decimal()
        NSDecimalRound(&roundedAvailable, &decimalAvailable, 2, .down)
        let amount = min(recommendation.replacedKilograms, NSDecimalNumber(decimal: roundedAvailable).doubleValue)
        return formattedPortion(amount)
    }

    func select(_ option: RationRecommendation) {
        guard let option = alternatives.first(where: { $0.id == option.id }) else { return }
        let sourceChanged = selected.removedIngredient.id != option.removedIngredient.id
        selected = option
        if sourceChanged {
            // A different source has its own available quantity and suggested replacement.
            portionText = Self.suggestedPortion(option)
        }
        recalculate()
    }

    func updatePortion(_ text: String) {
        portionText = Self.limitDecimalPlaces(text)
        recalculate()
    }

    func finishEditingPortion() {
        guard scenario != nil,
              let amount = Double(portionText.replacingOccurrences(of: ",", with: ".")) else { return }
        updatePortion(Self.formattedPortion(amount))
    }

    private static func formattedPortion(_ amount: Double) -> String {
        amount.formatted(.number.locale(Locale(identifier: "id_ID"))
            .grouping(.never).precision(.fractionLength(2)))
    }

    private static func limitDecimalPlaces(_ text: String) -> String {
        let normalized = text.replacingOccurrences(of: ".", with: ",")
        let parts = normalized.split(separator: ",", omittingEmptySubsequences: false)
        guard parts.count == 2, parts[0].allSatisfy({ $0.isASCII && $0.isNumber }),
              parts[1].allSatisfy({ $0.isASCII && $0.isNumber }) else { return normalized }
        return String(parts[0]) + "," + parts[1].prefix(2)
    }

    private func recalculate() {
        scenario = nil
        errorMessage = nil
        let text = portionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Double(text.replacingOccurrences(of: ",", with: ".")),
              amount.isFinite, amount >= 0, amount <= sourceAmount else {
            errorMessage = "Masukkan porsi antara 0 dan \(sourceAmount.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(0...2)))) kg."
            return
        }
        do { scenario = try engine.simulate(selected, amount: amount) }
        catch { errorMessage = "Perubahan belum dapat dihitung. Periksa porsi bahan." }
    }
}
