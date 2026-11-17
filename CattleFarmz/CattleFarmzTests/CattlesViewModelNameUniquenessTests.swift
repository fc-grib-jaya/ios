//
//  CattlesViewModelNameUniquenessTests.swift
//  CattleFarmzTests
//

import Testing
import UIKit
@testable import CattleFarmz

@MainActor
struct CattlesViewModelNameUniquenessTests {

    private func makeViewModel(items: [Cattle]) -> CattlesViewModel {
        CattlesViewModel(
            repository: MockCattleRepository(items: items),
            calculation: WeightCalculator(),
            toast: ToastManager()
        )
    }

    private func makeCattle(name: String) -> Cattle {
        Cattle(
            name: name,
            dateAcquired: .now,
            breed: .aceh,
            gender: .male,
            recordedAge: 12
        )
    }

    private func makeValues(name: String) -> CattleFormValues {
        CattleFormValues(
            name: name,
            dateAcquired: .now,
            breed: .aceh,
            gender: .male,
            recordedAge: 12,
            bodyWeight: 350,
            cattleImage: nil,
            notes: nil
        )
    }

    @Test func addCattleThrowsOnExactDuplicate() async throws {
        let sapi1 = makeCattle(name: "Sapi 1")
        let model = makeViewModel(items: [sapi1])

        await #expect(throws: CattleRepositoryError.duplicateName) {
            try model.addCattle(
                name: "Sapi 1",
                dateAcquired: .now,
                breed: .aceh,
                gender: .male,
                recordedAge: 12,
                bodyWeight: nil,
                cattleImage: nil,
                notes: nil
            )
        }
    }

    @Test func addCattleThrowsOnCaseInsensitiveDuplicate() async throws {
        let model = makeViewModel(items: [makeCattle(name: "Sapi 1")])

        await #expect(throws: CattleRepositoryError.duplicateName) {
            try model.addCattle(
                name: "sapi 1",
                dateAcquired: .now,
                breed: .aceh,
                gender: .male,
                recordedAge: 12,
                bodyWeight: nil,
                cattleImage: nil,
                notes: nil
            )
        }
    }

    @Test func addCattleThrowsOnWhitespacePaddedDuplicate() async throws {
        let model = makeViewModel(items: [makeCattle(name: "Sapi 1")])

        await #expect(throws: CattleRepositoryError.duplicateName) {
            try model.addCattle(
                name: "  Sapi 1  ",
                dateAcquired: .now,
                breed: .aceh,
                gender: .male,
                recordedAge: 12,
                bodyWeight: nil,
                cattleImage: nil,
                notes: nil
            )
        }
    }

    @Test func addCattleAllowsUniqueName() throws {
        let model = makeViewModel(items: [makeCattle(name: "Sapi 1")])

        try model.addCattle(
            name: "Melati",
            dateAcquired: .now,
            breed: .bali,
            gender: .female,
            recordedAge: 10,
            bodyWeight: nil,
            cattleImage: nil,
            notes: nil
        )

        #expect(model.items.count == 2)
    }

    @Test func isNameTakenExcludesEditedCattle() {
        let sapi1 = makeCattle(name: "Sapi 1")
        let model = makeViewModel(items: [sapi1, makeCattle(name: "Sapi 2")])

        #expect(!model.isNameTaken("Sapi 1", excluding: sapi1.id))
        #expect(model.isNameTaken("Sapi 1"))
    }

    @Test func editCattleRejectsRenamingToAnotherCattlesName() {
        let sapi1 = makeCattle(name: "Sapi 1")
        let sapi2 = makeCattle(name: "Sapi 2")
        let model = makeViewModel(items: [sapi1, sapi2])

        let error = model.editCattle(makeValues(name: "Sapi 2"), for: sapi1)

        #expect(error == "Nama sapi sudah digunakan, pilih nama lain.")
        #expect(sapi2.name == "Sapi 2")
        #expect(model.items.count == 2)
    }

    @Test func editCattleAllowsKeepingOwnName() {
        let sapi1 = makeCattle(name: "Sapi 1")
        let model = makeViewModel(items: [sapi1])

        let error = model.editCattle(makeValues(name: "Sapi 1"), for: sapi1)

        #expect(error == nil)
    }

    @Test func editCattleAllowsCaseChangedOwnName() {
        let sapi1 = makeCattle(name: "Sapi 1")
        let model = makeViewModel(items: [sapi1, makeCattle(name: "Melati")])

        let error = model.editCattle(makeValues(name: "sapi 1"), for: sapi1)

        #expect(error == nil)
    }
}
