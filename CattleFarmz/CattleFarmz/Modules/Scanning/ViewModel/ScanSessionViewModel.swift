//
//  ScanSessionViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation
import SwiftUI

/// Drives one full-screen scan session: camera first, then measurement.
///
/// Created by `DIContainer` when the cover opens, so the AR session is
/// allocated at that moment and released when the session ends. The camera is
/// stopped before measurement starts; the session never runs in the background.
@Observable
@MainActor
final class ScanSessionViewModel {
    let camera: CameraViewModel
    private(set) var measurement: MeasurementViewModel?

    @ObservationIgnored private let makeMeasurement: (Capture) -> MeasurementViewModel
    @ObservationIgnored private let onFinish: (ScanResult?) -> Void

    init(
        service: any ScanCapturing,
        haptics: any HapticProviding,
        makeMeasurement: @escaping (Capture) -> MeasurementViewModel,
        onFinish: @escaping (ScanResult?) -> Void
    ) {
        self.makeMeasurement = makeMeasurement
        self.onFinish = onFinish
        camera = CameraViewModel(service: service, haptics: haptics)
        camera.onCapture = { [weak self] capture in
            self?.showMeasurement(for: capture)
        }
    }

    /// Cancels the session and reports `nil` to the caller.
    func close() {
        camera.stop()
        onFinish(nil)
    }

    /// Finishes the measurement stage and reports the result to the caller.
    func finishMeasurement() {
        guard let result = measurement?.result else {
            onFinish(nil)
            return
        }
        
        guard let profile = measurement?.result?.profile else {
            onFinish(nil)
            return
        }
        onFinish(
            ScanResult(
                lengthCM: result.lengthCM,
//                girth: result.girth,
                girth: profile.lengthCM,
                cattleImage: UIImage(cgImage: measurement!.capture.image)
            )
        )
    }

    private func showMeasurement(for capture: Capture) {
        camera.stop()
        measurement = makeMeasurement(capture)
    }

    /// Discards the current measurement and returns to the camera stage.
    ///
    /// The camera view starts the capture service again in its `onAppear`, so
    /// the AR session stays stopped while this screen is not visible.
    func retakePhoto() {
        measurement = nil
    }
}
