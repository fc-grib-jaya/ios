import CoreGraphics
import Foundation
import Testing
@testable import CattleFarmz

@MainActor
struct PointGuideTests {
    @Test func firstVisitShowsGuideAndTouchDismissesIt() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        #expect(guide.visibleStepID == "Chest")
        guide.dismiss()
        #expect(guide.visibleStepID == nil)
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        #expect(guide.visibleStepID == nil)
    }

    @Test func newStepShowsItsOwnGuideButEditingOldStepDoesNot() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        guide.dismiss()
        guide.visit(stepID: "pin", alreadyPlaced: false)
        #expect(guide.visibleStepID == "pin")
        guide.visit(stepID: "Chest", alreadyPlaced: true)
        #expect(guide.visibleStepID == nil)
    }

    @Test func questionMarkReopensAndClosesTheSelectedGuide() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        guide.dismiss()
        guide.toggle(stepID: "Chest")
        #expect(guide.visibleStepID == "Chest")
        guide.toggle(stepID: "Chest")
        #expect(guide.visibleStepID == nil)
    }

    @Test func tappingAnotherExistingPointDoesNotReopenHelp() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "chestTop", alreadyPlaced: false)
        guide.dismiss() // PhotoCanvas reports touch before it changes selection.
        guide.visit(stepID: "Chest", alreadyPlaced: true)
        #expect(guide.visibleStepID == nil)
        guide.visit(stepID: "chestTop", alreadyPlaced: false)
        #expect(guide.visibleStepID == nil)
    }

    @Test func enteringInspectionHidesGIFWithoutResettingSeenSteps() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        guide.visit(stepID: nil, alreadyPlaced: false)
        #expect(guide.visibleStepID == nil)
        guide.visit(stepID: "Chest", alreadyPlaced: false)
        #expect(guide.visibleStepID == nil)
    }

    @Test func newCapturedPhotoGetsFreshGuideHistory() {
        var oldPhoto = PointGuidePresentation()
        oldPhoto.visit(stepID: "Chest", alreadyPlaced: false)
        oldPhoto.dismiss()
        var newPhoto = PointGuidePresentation()
        newPhoto.visit(stepID: "Chest", alreadyPlaced: false)
        #expect(newPhoto.visibleStepID == "Chest")
        #expect(oldPhoto.visibleStepID == nil)
    }

    @Test func allFourStepsHaveIndependentFirstVisitHints() {
        var guide = PointGuidePresentation()
        for step in MeasurementGuideStep.steps {
            guide.visit(stepID: step.id, alreadyPlaced: false)
            #expect(guide.visibleStepID == step.id)
            guide.dismiss()
        }
        for step in MeasurementGuideStep.steps.reversed() {
            guide.visit(stepID: step.id, alreadyPlaced: true)
            #expect(guide.visibleStepID == nil)
            guide.toggle(stepID: step.id)
            #expect(guide.visibleStepID == step.id)
            guide.dismiss()
        }
    }

    @Test func placedPointsNeverAutomaticallyShowEvenOnInitialDisplay() {
        var guide = PointGuidePresentation()
        guide.visit(stepID: "chestBottom", alreadyPlaced: true)
        #expect(guide.visibleStepID == nil)
        guide.toggle(stepID: "chestBottom")
        #expect(guide.visibleStepID == "chestBottom")
    }

    @Test func allGuideGIFsAreBundledAndDecodeAtLimitedResolution() async throws {
        for step in MeasurementGuideStep.steps {
            let page = try #require(ScanGuidePage.pages.first { $0.id == step.id })
            let url = try #require(Bundle.main.url(forResource: page.imageName, withExtension: "gif"))
            let decoder = try #require(GIFFrameSource(url: url))
            #expect(decoder.frameCount == 120)
            for index in [0, 60, 119] {
                let frame = try #require(await decoder.frame(at: index))
                #expect(frame.image.width <= 512)
                #expect(frame.image.height <= 512)
                #expect(frame.duration > 0)
            }
        }
    }

    @Test func decoderRejectsOutOfBoundsFrames() async throws {
        let url = try #require(Bundle.main.url(forResource: "Dada", withExtension: "gif"))
        let decoder = try #require(GIFFrameSource(url: url))
        let negative = await decoder.frame(at: -1)
        let pastEnd = await decoder.frame(at: decoder.frameCount)
        #expect(negative == nil)
        #expect(pastEnd == nil)
    }
}
