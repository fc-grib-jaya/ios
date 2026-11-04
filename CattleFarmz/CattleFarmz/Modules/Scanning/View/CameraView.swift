//
//  CameraView.swift
//  CattleFarmz
//
//  Created by Salman on 04/11/26.
//
import SwiftUI

@MainActor
struct CameraView: View {
    @State private var model = CameraViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(service: model.service)
                VStack(spacing: 18) {
                    HStack {
                        Button("Tutup") { dismiss() }
                        Spacer()
                        Text("Satu sapi").bold()
                    }
                    .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    Spacer()
                    Text("Pastikan tubuh sapi terlihat utuh dari samping")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    Text(model.errorMessage ?? model.service.status)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    Button {
                        model.takePhoto(viewportSize: geometry.size)
                    } label: {
                        ZStack {
                            Circle().fill(.white).frame(width: 74, height: 74)
                            Circle().stroke(.teal, lineWidth: 4).frame(width: 64, height: 64)
                            if model.service.busy { ProgressView() }
                        }
                    }
                    .accessibilityLabel("Ambil foto dan depth")
                    .disabled(!model.service.ready || model.service.busy)
                }
                .safeAreaPadding()
                .padding()
            }
        }
        .ignoresSafeArea()
        .onAppear { model.start() }
        .onDisappear { model.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && model.capture == nil { model.start() }
            if phase != .active { model.stop() }
        }
        .fullScreenCover(item: $model.capture, onDismiss: { model.start() }) { capture in
            NavigationStack {
                MeasurementView(model: MeasurementViewModel(capture: capture))
            }
        }
    }
}
