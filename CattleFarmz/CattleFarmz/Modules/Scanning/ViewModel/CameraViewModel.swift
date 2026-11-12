//
//  CameraViewModel.swift
//  CattleFarmz
//

import ARKit
import CoreGraphics
import Observation

/// Backing model for the LiDAR camera screen.
///
/// The capture service is injected by `DIContainer`; this view model never
/// creates an AR session itself. Capture is handed to `onCapture`, so the view
/// stays unaware of what happens next.
@Observable
@MainActor
final class CameraViewModel {
    /// Invoked on the main actor after a successful capture.
    var onCapture: ((Capture) -> Void)?

    private(set) var errorMessage: String?

    @ObservationIgnored private let service: any ScanCapturing

    @ObservationIgnored private let haptics: any HapticProviding

    init(service: any ScanCapturing, haptics: any HapticProviding) {
        self.service = service
        self.haptics = haptics
    }

    /// Session shown by the preview. `nil` for mocks and previews.
    var previewSession: ARSession? { service.session }
    var status: String { service.status }
    var isReady: Bool { service.isReady }
    var isBusy: Bool { service.isBusy }

    func start() {
        haptics.prepare()
        service.start()
    }

    func stop() {
        service.stop()
    }

    func takePhoto(viewportSize: CGSize) {
        guard service.isReady, !service.isBusy else { return }
        haptics.play(.scanStart)
        errorMessage = nil
        service.capture(viewportSize: viewportSize) { [weak self] outcome in
            guard let self else { return }
            switch outcome {
            case .success(let capture):
                self.onCapture?(capture)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
