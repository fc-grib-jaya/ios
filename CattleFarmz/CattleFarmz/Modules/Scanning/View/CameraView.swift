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
        GeometryReader { geometry in
            // Keep the original 734:874 proportion while fitting any landscape width.
            let previewWidth = min(
                geometry.size.width * 734 / 874,
                max(1, geometry.size.width - 2 * AppSpacing.lg)
            )
            let previewSize = CGSize(width: previewWidth, height: geometry.size.height)
            
            ZStack {
                Color.white
                    .ignoresSafeArea()

                CameraPreview(session: viewModel.previewSession)
                    .frame(width: previewSize.width, height: previewSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .overlay(alignment: .trailing) {
                        shutterButton(viewportSize: previewSize)
                    }
                    .overlay(alignment: .bottomLeading) {
                        statusOverlay(maxWidth: min(340, max(1, previewWidth - 2 * AppSpacing.lg)))
                            .padding(.leading, AppSpacing.lg)
                            .padding(.bottom, AppSpacing.lg)
                    }
            }
            .overlay(alignment: .topLeading) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .tint(.primary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xxl)
                .accessibilityLabel("Tutup kamera")
            }
            .overlay(alignment: .bottomLeading) {
                Button {} label: {
                    Image(systemName: "questionmark.circle")
                        .frame(width: 44, height: 44)
                        .background(AppColor.Primitive.Primary.shade500, in: Circle())
                }
                .foregroundStyle(AppColor.Primitive.Neutral.shade50)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xxl)
                .accessibilityLabel("Petunjuk pemindaian")
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

    private func statusOverlay(maxWidth: CGFloat) -> some View {
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

//                Text(viewModel.errorMessage ?? viewModel.status)
//                    .font(AppFont.caption)
//                    .foregroundStyle(AppColor.Text.secondary)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .frame(width: maxWidth, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50))
    }

}

#Preview {
    CameraView(viewModel: CameraViewModel(service: MockScanCapturing()), onClose: {})
}
