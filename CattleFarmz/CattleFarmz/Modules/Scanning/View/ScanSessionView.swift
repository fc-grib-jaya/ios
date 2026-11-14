//
//  ScanSessionView.swift
//  CattleFarmz
//

import SwiftUI

/// Full-screen scanning flow: camera, then measurement for the captured frame.
///
/// Both stages live inside the single `AppCover.scanSession`, so the AR session
/// stops before measurement is shown and no second presentation is needed.
struct ScanSessionView: View {
    @State private var viewModel: ScanSessionViewModel
    
    init(viewModel: ScanSessionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            // Top button: 32 pt inset + 44 pt diameter. Keep 16 pt below it.
            let progressTop = AppSpacing.xxl + 44 + AppSpacing.md
            let progressHeight = max(
                0,
                min(278, geometry.size.height - progressTop - AppSpacing.md)
            )

            ZStack {
                if let measurement = viewModel.measurement {
                    MeasurementView(
                        viewModel: measurement,
                        onExit: { viewModel.close() },
                        onFinish: { viewModel.finishMeasurement() },
                        onRetake: { viewModel.retakePhoto() }
                    )
                } else {
                    CameraView(viewModel: viewModel.camera) {
                        viewModel.close()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                MeasurementProgressBar(
                    currentStep: scanSessionStep,
                    icons: [
                        "camera.fill",
                        "slider.horizontal.3",
                        "waveform"
                    ]
                )
                .frame(width: 44, height: progressHeight)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, progressTop)
            }
        }
        .ignoresSafeArea()
    }

    /// The camera and measurement screens share the same scan flow.
    /// Deriving progress from its stage also handles Back and Retake.
    private var scanSessionStep: Int {
        guard let measurement = viewModel.measurement else { return 0 }

        switch measurement.flow.stage {
        case .inspection, .point:
            return 1
        case .results:
            return 2
        }
    }
}

#Preview {
    ScanSessionView(
        viewModel: ScanSessionViewModel(
            service: MockScanCapturing(),
            haptics: NoopHaptics(),
            makeMeasurement: { capture in
                MeasurementViewModel(capture: capture, renderer: MockDepthRenderer())
            },
            onFinish: { _ in },
            onCameraAccessDenied: {}
        )
    )
}
