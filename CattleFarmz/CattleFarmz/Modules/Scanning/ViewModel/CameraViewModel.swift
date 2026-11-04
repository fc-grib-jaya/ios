import CoreGraphics
import Observation
import Foundation

@MainActor @Observable final class CameraViewModel {
    @ObservationIgnored let service = CaptureService()
    var capture: Capture?
    var errorMessage: String?

    func start() {
        service.start()
    }
    
    func stop() {
        service.stop()
    }

    func takePhoto(viewportSize: CGSize) {
        errorMessage = nil
        service.capture(viewportSize: viewportSize) { [weak self] outcome in
            guard let self else { return }
            switch outcome {
            case .success(let capture):
                self.capture = capture
                self.service.stop()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
