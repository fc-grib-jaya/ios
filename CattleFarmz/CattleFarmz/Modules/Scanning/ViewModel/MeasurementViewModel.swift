import Foundation
import Observation

@MainActor
@Observable
final class MeasurementViewModel {
    let capture: Capture
    let steps = MeasurementGuideStep.steps
    private(set) var rawValidCount = 0
    private(set) var flow: GuidedReviewFlow
    private(set) var landmarks: [Landmark] = []
    private(set) var depthPreview: DepthPreview?
    private(set) var depthLoading = false
    private(set) var depthError: String?
    private(set) var result: MeasurementResult?
    private(set) var message: String?
    private(set) var analysisText = ""
    @ObservationIgnored private var analysisTask: Task<Void, Never>?
    @ObservationIgnored private var landmarkVersion = LandmarkRevision()

    var display: CaptureDisplay = .overlay

    @ObservationIgnored private let depthRenderer: any DepthRendering
    @ObservationIgnored private var prepared = false

    /// Init only stores dependencies; the depth scan and render start in `prepare()`.
    init(capture: Capture, renderer: any DepthRendering) {
        self.capture = capture
        self.depthRenderer = renderer
        flow = GuidedReviewFlow(pointIDs: MeasurementGuideStep.steps.map(\.id))
    }

    var currentStep: MeasurementGuideStep? {
        flow.currentIndex.map { steps[$0] }
    }
    var activePoint: Landmark? {
        landmarks.first { $0.id == flow.currentID }
    }
    var canBegin: Bool {
        !depthLoading && depthError == nil && rawValidCount >= 3
            && (depthPreview?.visualization.validCount ?? 0) >= 3
    }
    var currentDepthProblem: String? {
        guard let activePoint else { return nil }
        let depth = capture.metadata.depth
        guard let sample = try? MeasurementEngine.chestProfile(top: activePoint.point, bottom: activePoint.point, depth: depth).samples.first else { return "Depth kosong/tidak valid" }
        if sample.point == nil { return sample.status }
        // Diagnostic only: 3×3 valid raw depths, range ≥8 cm. No replacement or rejection.
        var values: [Double] = []
        for y in max(0, sample.y - 1)...min(depth.height - 1, sample.y + 1) {
            for x in max(0, sample.x - 1)...min(depth.width - 1, sample.x + 1) {
                let index = y * depth.width + x
                let z = Double(depth.meters[index])
                if DepthFrame.isUsableDepth(z, confidence: depth.confidence[index]) { values.append(z) }
            }
        }
        if let low = values.min(), let high = values.max(), high - low >= 0.08 {
            return "Perubahan depth lokal tajam: rentang 3×3 ≥8 cm (indikator saja)."
        }
        return nil
    }
    var canAdvance: Bool {
        guard let activePoint, currentStep != nil else { return false }
        // All four landmarks must point to a usable raw-depth pixel.
        return (try? capture.metadata.depth.point(at: activePoint.point)) != nil
    }

    func prepare() {
        guard !prepared else { return }
        prepared = true
        let raw = capture.metadata.depth
        rawValidCount = raw.meters.indices.reduce(0) { count, index in
            count
                + (DepthFrame.isUsableDepth(
                    Double(raw.meters[index]),
                    confidence: raw.confidence[index]
                ) ? 1 : 0)
        }
        depthLoading = true
        let previewFrame = capture.metadata.depth
        depthRenderer.render(previewFrame) { [weak self] outcome in
            guard let self else { return }
            self.depthLoading = false
            switch outcome {
            case .success(let preview):
                self.depthPreview = preview
            case .failure(let error):
                self.depthError = error.localizedDescription
                self.display = .photo
            }
        }
    }

    func beginGuide() {
        guard canBegin else { return }
        flow.begin()
        result = nil
        message = nil
    }

    /// Points stay normalized against the full upright image, even when cropped on screen.
    func moveActivePoint(to point: Point2) {
        guard point.isValid, let step = currentStep else { return }
        landmarkVersion.advance()
        analysisTask?.cancel()
        analysisText = ""
        if let index = landmarks.firstIndex(where: { $0.id == step.id }) {
            landmarks[index].point = point
        } else {
            landmarks.append(
                Landmark(id: step.id, label: step.label, point: point)
            )
        }
        flow.invalidateCurrentAndFollowing()
        result = nil
        message = nil
    }

    func nudge(dx: Int, dy: Int) {
        guard let point = activePoint?.point,
              let next = ProfileAnalysis.step(point, dx: dx, dy: dy, depth: capture.metadata.depth, crop: capture.metadata.previewCrop) else { return }
        moveActivePoint(to: next)
        analyzePlacement()
    }

    func analyzePlacement() {
        analysisTask?.cancel()
        guard let top = landmarks.first(where: { $0.id == "chestTop" })?.point,
              let bottom = landmarks.first(where: { $0.id == "chestBottom" })?.point else { return }
        let version = landmarkVersion.value
        let depth = capture.metadata.depth
        let crop = capture.metadata.previewCrop
        analysisTask = Task { [weak self] in
            let report = await Task.detached {
                (try? ProfileAnalysis.report(top: top, bottom: bottom, depth: depth, crop: crop)) ?? "Profil tidak dapat dianalisis."
            }.value
            guard !Task.isCancelled, let self, self.landmarkVersion.accepts(version) else { return }
            self.analysisText = report
        }
    }

    func clearCurrentPoint() {
        guard let id = flow.currentID else { return }
        landmarkVersion.advance()
        analysisTask?.cancel()
        analysisText = ""
        landmarks.removeAll { $0.id == id }
        flow.invalidateCurrentAndFollowing()
        result = nil
        message = nil
    }

    func advance() {
        guard flow.advance(hasUsablePoint: canAdvance) else { return }
        message = nil
        if flow.stage == .results { compute() }
    }

    func previous() {
        flow.previous()
        result = nil
        message = nil
    }

    func editPoints(from index: Int = 0) {
        flow.edit(from: index)
        result = nil
        message = nil
    }

    private func compute() {
        guard flow.allReviewed else { return }
        let points = Dictionary(
            uniqueKeysWithValues: landmarks.map { ($0.id, $0.point) }
        )
        guard let shoulder = points["shoulder"], let pin = points["pin"],
            let top = points["chestTop"], let bottom = points["chestBottom"]
        else { return }
        let depth = capture.metadata.depth
        let version = landmarkVersion.value
        Task { [weak self] in
            let outcome = await Task.detached {
                Result { try MeasurementEngine.cattle(shoulder: shoulder, pin: pin, top: top, bottom: bottom, depth: depth) }
            }.value
            guard let self, self.landmarkVersion.accepts(version), self.flow.stage == .results else { return }
            switch outcome {
            case .success(let measurement): self.result = measurement; self.message = measurement.warning
            case .failure(let error): self.result = nil; self.message = error.localizedDescription
            }
        }

    }
}

//#if DEBUG
extension MeasurementViewModel {
    /// Builds a view model driven by the synthetic capture, advanced through
    /// the real flow so previews show each stage without a camera.
    static func preview(_ stage: MeasurementPreviewStage) -> MeasurementViewModel {
        let model = MeasurementViewModel(
            capture: PreviewCattle.capture,
            renderer: MockDepthRenderer()
        )
        model.prepare()
        switch stage {
        case .inspection:
            break
        case .point(let index):
            model.beginGuide()
            for step in model.steps.prefix(index) {
                model.moveActivePoint(to: PreviewCattle.landmarks[step.id]!)
                model.advance()
            }
        case .results:
            model.beginGuide()
            for step in model.steps {
                model.moveActivePoint(to: PreviewCattle.landmarks[step.id]!)
                model.advance()
            }

        }
        return model
    }
}
//#endif
