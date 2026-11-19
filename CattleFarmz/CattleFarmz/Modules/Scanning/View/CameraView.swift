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
    @State private var isHelpVisible = true
    @Environment(\.scenePhase) private var scenePhase
    private let onClose: () -> Void
    
    init(viewModel: CameraViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing = AppSpacing.md
            let previewSize = CGSize(
                width: geometry.size.width * 728 / 874,
                height: geometry.size.height
            )
            let shutterAreaWidth = max(0, geometry.size.width - previewSize.width - spacing)

            HStack(spacing: spacing) {
                ScanViewport(previewSize: previewSize) { size in
                    let guideWidth = size.width * 451 / 672
                    let guideHeight = size.height * 295 / 402

                    CameraPreview(session: viewModel.previewSession)
                        .overlay {
                            Color.black
                                .opacity(0.6)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .frame(width: guideWidth, height: guideHeight)
                                        .foregroundStyle(.white)
                                        .blendMode(.destinationOut)
                                }
                                .compositingGroup()
                                .allowsHitTesting(false)

                            ScanGuideFrame()
                                .frame(width: guideWidth, height: guideHeight)
                        }
                        .overlay {
                            ScanHelpOverlay(isVisible: isHelpVisible) {
                                ScanInstructionCarousel {
                                    isHelpVisible = false
                                }
                                .frame(
                                    width: min(370, max(1, size.width - 2 * AppSpacing.md)),
                                    height: min(370, max(1, size.height - 2 * AppSpacing.md))
                                )
                            }
                        }
                        .overlay(alignment: .bottomLeading) {
                            ScanIconButton(systemImage: "xmark", accessibilityLabel: "Tutup kamera", action: onClose)
                                .padding(.vertical, AppSpacing.md)
                                .padding(.horizontal, AppSpacing.md)
                        }
                }
                .overlay(alignment: .topLeading) {
                    ScanIconButton(
                        systemImage: "questionmark.circle",
                        accessibilityLabel: "Petunjuk pemindaian",
                        style: isHelpVisible ? .primary : .material
                    ) {
                        isHelpVisible.toggle()
                    }
                    .accessibilityValue(isHelpVisible ? "Ditampilkan" : "Disembunyikan")
                    .padding(.vertical, AppSpacing.md)
                    .padding(.horizontal, AppSpacing.md)
                }

                shutterButton(viewportSize: previewSize)
                    .frame(width: shutterAreaWidth, height: previewSize.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { Color.black }
        }
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
    

}

#Preview("CameraView", traits: .fixedLayout(width: 874, height: 402)) {
    CameraView(viewModel: CameraViewModel(service: MockScanCapturing(), haptics: NoopHaptics()), onClose: {})
}
