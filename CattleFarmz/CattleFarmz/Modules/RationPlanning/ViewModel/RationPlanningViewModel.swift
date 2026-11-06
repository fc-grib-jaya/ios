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

    var searchText = ""
    var selectedCategory: FeedCategory?

    private(set) var feeds: [FeedIngredient] = []
    private(set) var selectedFeedIDs: Set<String> = []
    private(set) var amountTexts: [String: String] = [:]

    private(set) var result: RationCalculationResult?
    var errorMessage: String?

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
        } else {
            selectedFeedIDs.insert(feed.id)
        }

        clearResult()
    }

    func removeFeed(_ feed: FeedIngredient) {
        selectedFeedIDs.remove(feed.id)
        clearResult()
    }

    func amountText(for feed: FeedIngredient) -> String {
        amountTexts[feed.id] ?? "0"
    }

    func updateAmount(
        _ text: String,
        for feed: FeedIngredient
    ) {
        amountTexts[feed.id] = text
        clearResult()
    }

    func calculate() {
        clearResult()

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
