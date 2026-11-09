//
//  CattlesViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation
import UIKit
import SwiftUI

enum CattleSortOption: String, CaseIterable, Identifiable {
    case name
    case weight
    case age

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name: "Nama"
        case .weight: "Berat"
        case .age: "Umur"
        }
    }
}

/// Backing model for the cattles screen.
@Observable
@MainActor
final class CattlesViewModel {
    private(set) var items: [Cattle] = []

    /// Active filter selections. Empty set means "no filter" for that facet.
    var selectedBreeds: Set<String> = []
    var selectedGenders: Set<String> = []
    var selectedAgeRanges: Set<String> = []

    /// True when sorting by acquisition date from oldest to newest.
    var sortOption: CattleSortOption = .name
    var sortAscending = false

    /// Cattle visible under the active filter and sort settings.
    var filteredItems: [Cattle] {
        let filtered = items.filter { cattle in
            let matchesBreed =
                selectedBreeds.isEmpty
                || selectedBreeds.contains(cattle.breed.rawValue)
            let matchesGender =
                selectedGenders.isEmpty
                || selectedGenders.contains(cattle.gender.rawValue)
            let matchesAge =
                selectedAgeRanges.isEmpty
                || selectedAgeRanges.contains { range in
                    ageRange(for: cattle.currentAge) == range
                }

            return matchesBreed && matchesGender && matchesAge
        }

        return filtered.sorted { first, second in
            let result: ComparisonResult

            switch sortOption {
            case .name:
                result = first.name.localizedCaseInsensitiveCompare(second.name)
            case .weight:
                let firstWeight = cattleWeight(for: first) ?? -Double.infinity
                let secondWeight = cattleWeight(for: second) ?? -Double.infinity
                result =
                    firstWeight == secondWeight
                    ? .orderedSame
                    : (firstWeight < secondWeight
                        ? .orderedAscending : .orderedDescending)
            case .age:
                result =
                    first.currentAge == second.currentAge
                    ? .orderedSame
                    : (first.currentAge < second.currentAge
                        ? .orderedAscending : .orderedDescending)
            }

            return sortAscending
                ? result == .orderedAscending : result == .orderedDescending
        }
    }

    /// True when there is nothing to list (no cattle at all, or none pass the filters).
    var hasNoVisibleCattle: Bool {
        items.isEmpty
    }

    /// Subtitle describing the current list state.
    var listSubtitle: Text {
        hasNoVisibleCattle
            ? Text("Kamu belum\n") + Text("menambahkan sapi.").bold()
            : Text("Kamu memiliki\n")
                + Text("\(items.count) sapi terdaftar.").bold()
    }

    private let repository: any CattleRepository
    private let calculation: any WeightCalculation

    init(
        repository: any CattleRepository,
        calculation: any WeightCalculation
    ) {
        self.repository = repository
        self.calculation = calculation
    }

    func add(
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        chestGirth: Double?,
        bodyLength: Double?,
        bodyWeight: Double?,
        cattleImage: Data?,
        notes: String?
    ) throws {
        try repository.add(
            name: name,
            dateAcquired: dateAcquired,
            breed: breed,
            gender: gender,
            recordedAge: recordedAge,
            chestGirth: chestGirth,
            bodyLength: bodyLength,
            bodyWeight: bodyWeight,
            cattleImage: cattleImage,
            notes: notes
        )
        items = try repository.cattles()
    }

    func update(
        for cattle: Cattle,
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        chestGirth: Double?,
        bodyLength: Double?,
        bodyWeight: Double?,
        notes: String?
    ) throws {
        try repository.update(
            for: cattle.id,
            name: name,
            dateAcquired: dateAcquired,
            breed: breed,
            gender: gender,
            recordedAge: recordedAge,
            chestGirth: chestGirth,
            bodyLength: bodyLength,
            bodyWeight: bodyWeight,
            notes: notes
        )
        items = try repository.cattles()
    }

    func updateMeasurements(
        for cattle: Cattle,
        chestGirth: Double,
        bodyLength: Double
    ) throws {
        try repository.updateMeasurement(
            for: cattle.id,
            chestGirth: chestGirth,
            bodyLength: bodyLength
        )
    }

    func updateWeight(
        for cattle: Cattle,
        weight: Double
    ) throws {
        try repository.updateWeight(
            for: cattle.id,
            bodyWeight: weight
        )
    }

    func updateNotes(
        for cattle: Cattle,
        notes: String
    ) throws {
        try repository.updateNotes(for: cattle.id, notes: notes)
    }

    func cattleWeight(for cattle: Cattle) -> Double? {
        guard let chestGirth = cattle.chestGirth else {
            return nil
        }

        return calculation.cattleWeight(
            chestGirth: chestGirth,
            bodyLength: cattle.bodyLength,
            breed: cattle.breed,
            gender: cattle.gender
        )
    }

    func carcassWeight(
        for cattle: Cattle,
        bodyWeight: Double
    ) -> Double? {
        calculation.carcassWeight(
            breed: cattle.breed,
            gender: cattle.gender,
            bodyWeight: bodyWeight
        )
    }

    func nonCarcassWeight(
        for cattle: Cattle,
        bodyWeight: Double,
        part: NonCarcassPart
    ) -> Double? {
        calculation.nonCarcassWeight(
            breed: cattle.breed,
            bodyWeight: bodyWeight,
            part: part
        )
    }

    func meatWeight(
        for cattle: Cattle,
        bodyWeight: Double
    ) -> Double? {
        calculation.meatWeight(
            breed: cattle.breed,
            gender: cattle.gender,
            bodyWeight: bodyWeight
        )
    }

    /// Computes the weight breakdown for a cattle on the fly.
    /// Non-carcass weight is the sum over all `NonCarcassPart` cases.
    func weightBreakdown(for cattle: Cattle) -> CattleWeightBreakdown {
        guard let bodyWeight = cattle.bodyWeight ?? cattleWeight(for: cattle)
        else {
            return CattleWeightBreakdown(
                bodyWeight: nil,
                carcass: nil,
                nonCarcass: nil,
                meat: nil,
                nonCarcassParts: [:]
            )
        }

        let nonCarcassParts = Dictionary(
            uniqueKeysWithValues: NonCarcassPart.allCases.compactMap { part in
                nonCarcassWeight(
                    for: cattle,
                    bodyWeight: bodyWeight,
                    part: part
                )
                .map { (part, $0) }
            }
        )
        let nonCarcass = nonCarcassParts.values.reduce(0.0, +)

        return CattleWeightBreakdown(
            bodyWeight: bodyWeight,
            carcass: carcassWeight(for: cattle, bodyWeight: bodyWeight),
            nonCarcass: nonCarcass,
            meat: meatWeight(for: cattle, bodyWeight: bodyWeight),
            nonCarcassParts: nonCarcassParts
        )
    }

    /// Selects a sort field and keeps the current direction.
    func selectSort(_ option: CattleSortOption) {
        sortOption = option
    }

    /// Applies edit-form values to the given cattle, then refreshes the list.
    /// Returns an error message when the save fails, `nil` on success.
    func editCattle(_ values: CattleEditValues, for cattle: Cattle) -> String? {
        do {
            try update(
                for: cattle,
                name: values.name,
                dateAcquired: values.dateAcquired,
                breed: values.breed,
                gender: values.gender,
                recordedAge: values.recordedAge,
                chestGirth: values.chestGirth,
                bodyLength: values.bodyLength,
                bodyWeight: values.bodyWeight,
                notes: values.notes
            )
            return nil
        } catch {
            return "Periksa kembali data yang dimasukkan."
        }
    }

    /// Flips the sort direction of `filteredItems`.
    func toggleSort() {
        sortAscending.toggle()
    }

    /// Adds a cattle entry, encoding the optional photo to JPEG, then refreshes the list.
    func addCattle(
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        bodyWeight: Double?,
        cattleImage: UIImage?,
        notes: String?
    ) throws {
        let imageData = cattleImage?.jpegData(compressionQuality: 0.85)
        try add(
            name: name,
            dateAcquired: dateAcquired,
            breed: breed,
            gender: gender,
            recordedAge: recordedAge,
            chestGirth: nil,
            bodyLength: nil,
            bodyWeight: bodyWeight,
            cattleImage: imageData,
            notes: notes
        )
    }

    private func ageRange(for ageInMonths: Int) -> String {
        switch ageInMonths {
        case 0..<6:
            return CattleAgeRange.baby.rawValue
        case 6..<12:
            return CattleAgeRange.veryYoung.rawValue
        case 12..<18:
            return CattleAgeRange.young.rawValue
        case 18..<24:
            return CattleAgeRange.mature.rawValue
        default:
            return CattleAgeRange.old.rawValue
        }
    }

    /// Loads all cattle from the repository, newest acquisitions first.
    func load() async {
        items = (try? repository.cattles()) ?? []
    }
}
