import Foundation
import Testing
@testable import CattleFarmz

@MainActor
struct ADGReferenceEngineTests {
    @Test func suppliesTheUserSelectedDefaultsForEveryBreed() throws {
        let expected: [(CattleBreed, Double)] = [
            (.bali, 0.6), (.madura, 0.5), (.limousin, 1.0), (.simmental, 1.0),
            (.brahman, 0.9), (.peranakanOngole, 0.7), (.friesianHolstein, 0.9), (.aceh, 0.5)
        ]
        for (breed, target) in expected {
            let reference = try #require(ADGReferenceEngine.reference(
                breedName: breed.rawValue, sex: .male, stage: .adult
            ))
            #expect(reference.kilogramsPerDay == target)
            #expect(!reference.note.isEmpty)
            #expect(reference.sources.count == 1)
            #expect(reference.sources.first?.scheme == "https")
        }
    }

    @Test func femaleHolsteinDefaultAppliesOnlyToHeifers() {
        let heifer = ADGReferenceEngine.reference(
            breedName: "Friesian Holstein", sex: .female, stage: .heifer
        )
        #expect(heifer?.kilogramsPerDay == 0.8)
        let stages: [CattleProductionStage] = [
            .calf, .adult, .pregnantHeifer, .lowProductionLactation, .highProductionLactation, .dry
        ]
        for stage in stages {
            #expect(ADGReferenceEngine.reference(
                breedName: "Friesian Holstein", sex: .female, stage: stage
            )?.kilogramsPerDay == nil)
        }
    }

    @Test func unknownBreedsHaveNoInventedDefaultAndNamesAreNormalized() {
        #expect(ADGReferenceEngine.reference(
            breedName: "Unknown breed", sex: .male, stage: .adult
        ) == nil)
        #expect(ADGReferenceEngine.reference(
            breedName: "  SIMMENTAL  ", sex: .male, stage: .adult
        )?.kilogramsPerDay == 1.0)
    }

    @Test func preservesTheProvisionalBrahmanScope() throws {
        let reference = try #require(ADGReferenceEngine.reference(
            breedName: "Brahman", sex: .male, stage: .adult
        ))
        #expect(reference.note.contains("sementara"))
        #expect(reference.note.contains("Brahman Cross"))
        #expect(reference.note.contains("murni"))
    }
}
