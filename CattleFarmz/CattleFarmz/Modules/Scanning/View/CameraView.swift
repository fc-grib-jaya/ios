//
//  CameraView.swift
//  CattleFarmz
//

import SwiftUI

/// LiDAR camera screen.
///
/// The `App` layer presents it through `AppCover` and supplies the view model.
/// The view starts and stops the capture service with its own lifecycle and
/// reports a capture through the view model; it never presents measurement.
struct CameraView: View {
    @State private var viewModel: CameraViewModel
    @Environment(\.scenePhase) private var scenePhase
    private let onClose: () -> Void

    init(viewModel: CameraViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }

    var body: some View {
        ScanHelpOverlay(initiallyVisible: false) { isHelpVisible in
            ScanViewport { previewSize in
                CameraPreview(session: viewModel.previewSession)
                    .overlay(alignment: .trailing) {
                        shutterButton(viewportSize: previewSize)
                    }
                    .overlay(alignment: .bottomLeading) {
                        if isHelpVisible {
                            statusOverlay
                                .frame(width: min(340, max(1, previewSize.width - 2 * AppSpacing.lg)))
                                .padding(.leading, AppSpacing.lg)
                                .padding(.bottom, AppSpacing.lg)
                        }
                    }
            }
            .background { Color.white.ignoresSafeArea() }
            .overlay(alignment: .topLeading) {
                ScanIconButton(systemImage: "xmark", accessibilityLabel: "Tutup kamera", action: onClose)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxl)
            }
        }
        .ignoresSafeArea()
        .forceLandscape()
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.start() }
            if phase != .active { viewModel.stop() }
        }
    }

    private func shutterButton(viewportSize: CGSize) -> some View {
        Button {
            viewModel.takePhoto(viewportSize: viewportSize)
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 74, height: 74)

                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)

                if viewModel.isBusy {
                    ProgressView()
                        .tint(.teal)
                }
            }
            .frame(width: 74, height: 74)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ambil foto dan depth")
        .disabled(!viewModel.isReady || viewModel.isBusy)
        .padding(.trailing, 24)
    }

    private var statusOverlay: some View {
        ScanInstructionCard {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "info.circle")
                    .font(AppFont.title)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text("Foto sapi dari samping")
                        .font(AppFont.mediumBody)

                    Text("Pastikan pengambilan foto simetris")
                        .font(AppFont.mediumSubheadline)
                        .foregroundStyle(AppColor.Text.secondary)
                }
            }
        }
    }

}

#Preview {
    CameraView(viewModel: CameraViewModel(service: MockScanCapturing(), haptics: NoopHaptics()), onClose: {})
}
