//
//  RationPlanningViewModel.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class RationPlanningViewModel {
    private(set) var profile = CattleRationProfile() {
        didSet { clearResult() }
    }

    var bodyWeightText = "250" {
        didSet { clearResult() }
    }

    var animalCountText = "1" {
        didSet { clearResult() }
    }

    var dailyWeightGainText = "0.5" {
        didSet { clearResult() }
    }

    var milkProductionText = "0" {
        didSet { clearResult() }
    }
    
    var totalFeedKilogramsPerAnimalPerDay: Double? {
        var total = 0.0

        for feed in selectedFeeds {
            let text = amountText(for: feed)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: ".")

            guard let amount = Double(text),
                  amount.isFinite,
                  amount >= 0 else {
                return nil
            }

            total += amount
        }

        return total.isFinite ? total : nil
    }

    var searchText = ""
    var selectedCategory: FeedCategory?

    private(set) var feeds: [FeedIngredient] = []
    private(set) var selectedFeedIDs: Set<String> = []
    private(set) var amountTexts: [String: String] = [:]

    private(set) var result: RationCalculationResult?
    var errorMessage: String?
    private(set) var repairGroups: [RationRecommendationGroup] = []
    private(set) var repairMessage: String?
    
    private(set) var missingAmountFeedIDs: Set<FeedIngredient.ID> = []

    func hasMissingAmount(for feed: FeedIngredient) -> Bool {
        missingAmountFeedIDs.contains(feed.id)
    }

    func clearAmountWarning(for id: FeedIngredient.ID) {
        missingAmountFeedIDs.remove(id)
    }

    func findRepairs(for snapshot: RationCalculationResult) {
        load()
        repairGroups = []
        repairMessage = nil
        guard hasLoaded else {
            repairMessage = errorMessage
            return
        }
        do {
            repairGroups = try RationRecommendationEngine(calculator: calculator)
                .recommendGroups(for: snapshot, catalog: feeds, season: RationSeason(date: .now))
            if repairGroups.isEmpty {
                let rows = NutrientComparison.rows(for: snapshot).prefix(2)
                let complete = rows.allSatisfy { ($0.coverage ?? 0) >= 1 }
                repairMessage = complete
                    ? "Protein dan Energi (TDN) sudah mencapai acuan."
                    : "Belum ditemukan perbaikan dengan penggantian satu bahan dari katalog yang tersedia."
            }
        } catch {
            repairMessage = error.localizedDescription
        }
    }

    func makeRecommendationReview(for option: RationRecommendation) -> RationRecommendationViewModel {
        RationRecommendationViewModel(
            recommendation: option,
            alternatives: repairGroups.first { $0.target == option.target }?.alternatives ?? [option],
            engine: RationRecommendationEngine(calculator: calculator)
        )
    }

    func clearRepairs() {
        repairGroups = []
        repairMessage = nil
    }


    @ObservationIgnored
    private let feedProvider: () throws -> [FeedIngredient]

    @ObservationIgnored
    private let calculator: any RationCalculating

    @ObservationIgnored
    private var hasLoaded = false

    init(
        feedProvider: @escaping () throws -> [FeedIngredient],
        calculator: any RationCalculating
    ) {
        self.feedProvider = feedProvider
        self.calculator = calculator
    }

    var filteredFeeds: [FeedIngredient] {
        feeds.filter { feed in
            let matchesCategory =
                selectedCategory == nil
                || feed.category == selectedCategory

            let query = searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let matchesSearch =
                query.isEmpty
                || feed.name.localizedStandardContains(query)

            return matchesCategory && matchesSearch
        }
    }

    var selectedFeeds: [FeedIngredient] {
        feeds.filter {
            selectedFeedIDs.contains($0.id)
        }
    }

    func load() {
        guard !hasLoaded else {
            return
        }

        errorMessage = nil

        do {
            feeds = try feedProvider()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectProductionType(
        _ type: CattleProductionType
    ) {
        profile.selectProductionType(type)
    }

    func selectSex(_ sex: CattleSex) {
        profile.selectSex(sex)
    }

    func selectStage(_ stage: CattleProductionStage) {
        profile.selectStage(stage)
    }

    func toggleFeed(_ feed: FeedIngredient) {
        guard feeds.contains(where: { $0.id == feed.id }) else {
            return
        }

        if selectedFeedIDs.contains(feed.id) {
            selectedFeedIDs.remove(feed.id)
            missingAmountFeedIDs.remove(feed.id)
        } else {
            selectedFeedIDs.insert(feed.id)
        }

        clearResult()
    }

    func removeFeed(_ feed: FeedIngredient) {
        selectedFeedIDs.remove(feed.id)
        missingAmountFeedIDs.remove(feed.id)
        clearResult()
    }

    func amountText(for feed: FeedIngredient) -> String {
        amountTexts[feed.id] ?? ""
    }
    
    func limitedAmountText(_ text: String) -> String {
        let normalized = text
            .replacingOccurrences(of: ".", with: ",")
            .filter { ("0"..."9").contains($0) || $0 == "," }

        let parts = normalized.split(
            separator: ",",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )

        let integerPart = String((parts.first ?? "").prefix(3))

        guard parts.count == 2 else {
            return integerPart
        }

        let decimalPart = parts[1]
            .filter { ("0"..."9").contains($0) }
            .prefix(2)

        return integerPart + "," + decimalPart
    }

    func updateAmount(
        _ text: String,
        for feed: FeedIngredient
    ) {
        let limited = limitedAmountText(text)
        amountTexts[feed.id] = limited
        if !limited.isEmpty {
            missingAmountFeedIDs.remove(feed.id)
        }
        clearResult()
    }

    func restore(_ saved: RationCalculationResult) {
        missingAmountFeedIDs = []
        load()
        for item in saved.items where !feeds.contains(where: { $0.id == item.id }) {
            feeds.append(item.ingredient)
        }
        profile = saved.profile
        bodyWeightText = String(saved.profile.bodyWeightKilograms)
        dailyWeightGainText = String(saved.profile.targetDailyWeightGainKilograms)
        animalCountText = String(saved.profile.animalCount)
        milkProductionText = String(saved.profile.dailyMilkProductionLiters)
        selectedFeedIDs = Set(saved.items.map { $0.id })
        amountTexts = Dictionary(uniqueKeysWithValues: saved.items.map {
            ($0.id, String($0.kilogramsPerAnimalPerDay))
        })
    }

    func calculate() {
        clearResult()

        missingAmountFeedIDs = Set(
            selectedFeeds
                .filter {
                    amountText(for: $0)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                }
                .map(\.id)
        )

        guard missingAmountFeedIDs.isEmpty else {
            errorMessage = "Isi jumlah setiap bahan pakan terlebih dahulu."
            return
        }

        do {
            var inputProfile = profile

            let countText = animalCountText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard let count = Int(countText) else {
                throw InputError.invalidAnimalCount
            }

            inputProfile.animalCount = count

            inputProfile.bodyWeightKilograms = try number(
                from: bodyWeightText,
                field: "Body weight"
            )

            if inputProfile.usesWeightGainTarget {
                inputProfile.targetDailyWeightGainKilograms =
                    try number(
                        from: dailyWeightGainText,
                        field: "Target daily weight gain"
                    )
            }

            if inputProfile.usesMilkProduction {
                inputProfile.dailyMilkProductionLiters =
                    try number(
                        from: milkProductionText,
                        field: "Milk production"
                    )
            }

            let items = try selectedFeeds.map { feed in
                RationItem(
                    ingredient: feed,
                    kilogramsPerAnimalPerDay: try number(
                        from: amountText(for: feed),
                        field: feed.name
                    )
                )
            }

            result = try calculator.calculate(
                profile: inputProfile,
                items: items
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearResult() {
        clearRepairs()
        result = nil
        errorMessage = nil
    }

    private func number(
        from text: String,
        field: String
    ) throws -> Double {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let value = Double(normalized),
              value.isFinite else {
            throw InputError.invalidNumber(field)
        }

        return value
    }

    private enum InputError: LocalizedError {
        case invalidAnimalCount
        case invalidNumber(String)

        var errorDescription: String? {
            switch self {
            case .invalidAnimalCount:
                return "Enter a whole number for the cattle count."

            case .invalidNumber(let field):
                return "Enter a valid number for \(field)."
            }
        }
    }
}
