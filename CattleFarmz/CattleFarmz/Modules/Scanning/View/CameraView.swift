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
            ZStack {
                Color.gray
                    .ignoresSafeArea()

                CameraPreview(session: viewModel.previewSession)
                    .ignoresSafeArea()
            }
            .overlay(alignment: .topLeading) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .tint(.primary)
                .padding(24)
                .accessibilityLabel("Tutup kamera")
            }
            .overlay(alignment: .bottomTrailing) {
                Button {} label: {
                    Image(systemName: "info")
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .tint(.primary)
                .padding(24)
                .accessibilityLabel("Petunjuk pemindaian")
            }
            .overlay(alignment: .trailing) {
                shutterButton(viewportSize: geometry.size)
            }
            .overlay(alignment: .bottom) {
                statusOverlay
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
        VStack(spacing: 12) {
            Text("Pastikan tubuh sapi terlihat utuh dari samping")
                .multilineTextAlignment(.center)
                .padding(8)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 14)
                )

            Text(viewModel.errorMessage ?? viewModel.status)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .frame(maxWidth: 340)
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

#Preview {
    CameraView(viewModel: CameraViewModel(service: MockScanCapturing()), onClose: {})
}
