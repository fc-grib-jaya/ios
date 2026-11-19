import CoreGraphics
import Testing
@testable import CattleFarmz

@MainActor
struct ScanningInteractionTests {
    private func makeModel() -> MeasurementViewModel {
        let model = MeasurementViewModel(capture: PreviewCattle.capture, renderer: MockDepthRenderer())
        model.prepare()
        model.beginGuide()
        return model
    }

    private func place(_ index: Int, in model: MeasurementViewModel) {
        let step = model.steps[index]
        model.beginPlacement(on: step.id)
        model.moveActivePoint(to: PreviewCattle.landmarks[step.id]!)
        model.endPlacement(didMove: true)
    }

    @Test func touchingAnotherMarkerSelectsItWithoutMovingIt() throws {
        var gesture = try #require(PointPlacementGesture(
            start: CGPoint(x: 42, y: 40),
            activeID: "chestTop",
            markers: [(id: "Chest", position: CGPoint(x: 40, y: 40))]
        ))
        #expect(gesture.targetID == "Chest")
        #expect(gesture.movedLocation(to: CGPoint(x: 42, y: 40)) == nil)
        #expect(!gesture.didMove)
        #expect(gesture.movedLocation(to: CGPoint(x: 52, y: 60)) == CGPoint(x: 50, y: 60))
        #expect(gesture.didMove)
        #expect(gesture.targetID == "Chest")
    }

    @Test func backgroundTapPlacesOnlyTheSelectedPoint() throws {
        var gesture = try #require(PointPlacementGesture(
            start: CGPoint(x: 200, y: 100), activeID: "chestTop",
            markers: [(id: "Chest", position: CGPoint(x: 40, y: 40))]
        ))
        #expect(gesture.targetID == "chestTop")
        #expect(gesture.movedLocation(to: CGPoint(x: 200, y: 100)) == CGPoint(x: 200, y: 100))
        #expect(gesture.didMove)
    }

    @Test func nearestMarkerWinsWhenHitAreasOverlap() throws {
        let gesture = try #require(PointPlacementGesture(
            start: CGPoint(x: 48, y: 40), activeID: "chestTop",
            markers: [
                (id: "Chest", position: CGPoint(x: 40, y: 40)),
                (id: "pin", position: CGPoint(x: 50, y: 40))
            ]
        ))
        #expect(gesture.targetID == "pin")
    }

    @Test func newPointAdvancesOnlyAfterRelease() {
        let model = makeModel()
        model.beginPlacement(on: "Chest")
        model.moveActivePoint(to: PreviewCattle.shoulder)
        #expect(model.flow.currentIndex == 0)
        #expect(model.flow.reviewedIDs.isEmpty)
        #expect(model.isPlacing)
        #expect(!model.canFinish)
        model.endPlacement(didMove: true)
        #expect(model.flow.currentIndex == 1)
        #expect(model.flow.reviewedIDs == ["Chest"])
        #expect(!model.isPlacing)
    }

    @Test func selectingAnExistingPointDoesNotConfirmOrMoveAnyPoint() {
        let model = makeModel()
        place(0, in: model)
        place(1, in: model)
        let before = model.landmarks.map(\.point)
        model.beginPlacement(on: "Chest")
        #expect(model.flow.currentID == "Chest")
        model.endPlacement(didMove: false)
        #expect(model.flow.currentID == "Chest")
        #expect(model.landmarks.map(\.point) == before)
        #expect(model.flow.reviewedIDs == ["Chest", "pin"])
    }

    @Test func editingCompletedPointStaysSelectedAndPreservesOtherPoints() {
        let model = makeModel()
        place(0, in: model)
        place(1, in: model)
        let pin = model.landmarks.first { $0.id == "pin" }?.point
        model.beginPlacement(on: "Chest")
        let edited = Point2(0.23, 0.53)
        model.moveActivePoint(to: edited)
        model.endPlacement(didMove: true)
        #expect(model.flow.currentID == "Chest")
        #expect(model.flow.reviewedIDs == ["Chest", "pin"])
        #expect(model.activePoint?.point == edited)
        #expect(model.landmarks.first { $0.id == "pin" }?.point == pin)
    }

    @Test func invalidDepthDoesNotAdvanceAndValidCorrectionDoes() {
        let model = makeModel()
        model.beginPlacement(on: "Chest")
        model.moveActivePoint(to: Point2(0, 0))
        model.endPlacement(didMove: true)
        #expect(model.flow.currentIndex == 0)
        #expect(model.flow.reviewedIDs.isEmpty)
        #expect(model.message != nil)
        #expect(!model.canFinish)
        place(0, in: model)
        #expect(model.flow.currentIndex == 1)
        #expect(model.flow.reviewedIDs == ["Chest"])
    }

    @Test func draggingConfirmedPointThroughInvalidDepthRestoresCheckmark() {
        let model = makeModel()
        place(0, in: model)
        model.beginPlacement(on: "Chest")
        model.moveActivePoint(to: Point2(0, 0))
        #expect(!model.flow.reviewedIDs.contains("Chest"))
        model.moveActivePoint(to: PreviewCattle.shoulder)
        model.endPlacement(didMove: true)
        #expect(model.flow.currentID == "Chest")
        #expect(model.flow.reviewedIDs.contains("Chest"))
    }

    @Test func lastPointPlacedFirstCannotFinishEarly() {
        let model = makeModel()
        place(3, in: model)
        #expect(model.flow.currentIndex == 0)
        #expect(!model.canFinish)
        #expect(model.result == nil)
    }

    @Test func completingAllPointsKeepsPhotoEditableUntilFinalCheckmark() async {
        let model = makeModel()
        for index in model.steps.indices { place(index, in: model) }
        #expect(model.flow.stage == .point(3))
        #expect(model.canFinish)
        #expect(model.result == nil)
        let result = await model.finish()
        #expect(result != nil)
        #expect(model.finishError == nil)
        #expect(!model.isComputing)
    }

    @Test func selectionCannotChangeGestureTargetMidDrag() {
        let model = makeModel()
        model.beginPlacement(on: "Chest")
        model.selectPoint(at: 2)
        #expect(model.flow.currentID == "Chest")
        model.moveActivePoint(to: PreviewCattle.shoulder)
        model.endPlacement(didMove: true)
        #expect(model.landmarks.map(\.id) == ["Chest"])
    }

    @Test func calculationFailureLeavesSessionOpen() async {
        let model = makeModel()
        for index in model.steps.indices { place(index, in: model) }
        // Individually valid points can still describe an impossible zero body length.
        model.beginPlacement(on: "pin")
        model.moveActivePoint(to: PreviewCattle.shoulder)
        model.endPlacement(didMove: true)
        #expect(model.canFinish)
        let result = await model.finish()
        #expect(result == nil)
        #expect(model.finishError != nil)
        #expect(!model.isComputing)
        #expect(model.flow.currentID == "pin")
        #expect(model.canFinish)
    }

    @Test func finalCheckmarkReturnsScanExactlyOnce() async {
        let service = MockScanCapturing()
        var results: [ScanResult?] = []
        let session = ScanSessionViewModel(
            service: service,
            haptics: NoopHaptics(),
            makeMeasurement: { MeasurementViewModel(capture: $0, renderer: MockDepthRenderer()) },
            onFinish: { results.append($0) },
            onCameraAccessDenied: {}
        )
        session.camera.takePhoto(viewportSize: CGSize(width: 672, height: 370))
        guard let model = session.measurement else {
            Issue.record("Capture did not open measurement")
            return
        }
        model.prepare()
        model.beginGuide()
        await session.finishMeasurement()
        #expect(results.isEmpty)
        for index in model.steps.indices { place(index, in: model) }
        #expect(results.isEmpty)
        await session.finishMeasurement()
        #expect(results.count == 1)
        #expect(results.first.flatMap { $0 }?.girth != nil)
        await session.finishMeasurement()
        #expect(results.count == 1)
    }
}
