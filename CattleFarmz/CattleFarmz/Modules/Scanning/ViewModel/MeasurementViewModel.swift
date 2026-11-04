import Observation
import Foundation

@MainActor
@Observable
final class MeasurementViewModel {
    let capture: Capture
    let steps = MeasurementGuideStep.steps
    let rawValidCount: Int
    private(set) var flow: GuidedReviewFlow
    private(set) var landmarks: [Landmark] = []
    private(set) var depthPreview: DepthPreview?
    private(set) var depthLoading = false
    private(set) var depthError: String?
    private(set) var result: MeasurementResult?
    private(set) var message: String?
    var display: CaptureDisplay = .overlay

    @ObservationIgnored private let depthRenderer = DepthRenderer()
    @ObservationIgnored private var prepared = false

    init(capture: Capture) {
        self.capture = capture
        let raw=capture.metadata.depth
        rawValidCount=raw.meters.indices.reduce(0) { count,index in
            count + (DepthFrame.isUsableDepth(Double(raw.meters[index]),confidence:raw.confidence[index]) ? 1 : 0)
        }
        flow = GuidedReviewFlow(pointIDs: MeasurementGuideStep.steps.map(\.id))
    }

    var usesSmoothedDepth: Bool {
        capture.metadata.smoothedDepth?.confidence.contains(where: { $0 >= 1 }) == true
    }

    var currentStep: MeasurementGuideStep? {
        flow.currentIndex.map { steps[$0] }
    }
    var activePoint: Landmark? {
        landmarks.first { $0.id == flow.currentID }
    }
    var canBegin: Bool {
        !depthLoading && depthError == nil && rawValidCount >= 3 && (depthPreview?.visualization.validCount ?? 0) >= 3
    }
    var currentDepthProblem: String? {
        guard let activePoint, let step = currentStep else { return nil }
        do {
            _ = try capture.metadata.depth.point(at: activePoint.point)
            return nil
        } catch {
            // The marked chest silhouette itself can mix with background.
            // Permit it only when nearby pixels on the inside have valid depth.
            if step.id == "chestTop" || step.id == "chestBottom" {
                let direction = step.id == "chestTop" ? 1.0 : -1.0
                for shift in [0.02, 0.04, 0.06] {
                    let inside = Point2(activePoint.point.x, activePoint.point.y + direction * shift)
                    if inside.isValid, (try? capture.metadata.depth.point(at: inside)) != nil {
                        return nil
                    }
                }
            }
            return error.localizedDescription
        }
    }
    var canAdvance: Bool {
        activePoint != nil && currentDepthProblem == nil
    }

    func prepare() {
        guard !prepared else { return }
        prepared = true
        depthLoading = true
        let previewFrame=usesSmoothedDepth ? capture.metadata.smoothedDepth! : capture.metadata.depth
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
        if let index = landmarks.firstIndex(where: { $0.id == step.id }) {
            landmarks[index].point = point
        } else {
            landmarks.append(Landmark(id: step.id, label: step.label, point: point))
        }
        flow.invalidateCurrentAndFollowing()
        result = nil
        message = nil
    }

    func clearCurrentPoint() {
        guard let id = flow.currentID else { return }
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
        let points = Dictionary(uniqueKeysWithValues: landmarks.map { ($0.id, $0.point) })
        guard let shoulder = points["shoulder"], let pin = points["pin"],
              let top = points["chestTop"], let bottom = points["chestBottom"] else { return }
        do {
            result = try MeasurementEngine.cattle(
                shoulder: shoulder, pin: pin, top: top, bottom: bottom,
                depth: capture.metadata.depth
            )
            message = result?.warning
        } catch {
            result = nil
            message = error.localizedDescription
        }
    }
}
