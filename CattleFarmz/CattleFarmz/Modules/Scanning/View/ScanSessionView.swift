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
        if let measurement = viewModel.measurement {
            NavigationStack {
                MeasurementView(
                    viewModel: measurement,
                    onExit: { viewModel.close() },
                    onFinish: { viewModel.finishMeasurement() },
                    onRetake: { viewModel.retakePhoto() }
                )
            }
        } else {
            CameraView(viewModel: viewModel.camera) {
                viewModel.close()
            }
        }
    }
}

#Preview {
    ScanSessionView(
        viewModel: ScanSessionViewModel(
            service: MockScanCapturing(),
            makeMeasurement: { capture in
                MeasurementViewModel(capture: capture, renderer: MockDepthRenderer())
            },
            onFinish: { _ in }
        )
    )
}
