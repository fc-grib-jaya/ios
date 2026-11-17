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
            $0.removedIngredient.id == recommendation.removedIngredient.id && seen.insert($0.id).inserted
        }
        self.engine = engine
        // Recalculate from the displayed two-decimal amount, keeping it within the source quantity.
        let available = recommendation.before.items.first { $0.id == recommendation.removedIngredient.id }?.kilogramsPerAnimalPerDay ?? 0
        var decimalAvailable = Decimal(available)
        var roundedAvailable = Decimal()
        NSDecimalRound(&roundedAvailable, &decimalAvailable, 2, .down)
        let amount = min(recommendation.replacedKilograms, NSDecimalNumber(decimal: roundedAvailable).doubleValue)
        self.portionText = Self.formattedPortion(amount)
        recalculate()
    }

    func select(_ option: RationRecommendation) {
        guard alternatives.contains(where: { $0.id == option.id }) else { return }
        selected = option
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
