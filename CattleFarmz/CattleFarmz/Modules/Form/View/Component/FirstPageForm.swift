//
//  FirstPageForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 18/11/26.
//

import AVFoundation
import SwiftUI

struct FirstPageForm: View {
    @Binding var cattlePhoto: UIImage?
    @Binding var cattleName: String
    @Binding var cattleAge: Int?
    @Binding var notes: String?

    @State private var isShowingCamera = false
    @State private var cameraPermissionError: String?
    @State private var isAskingToUseScanPhoto = false

    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xxxl) {
                CattlesPictureCard(
                    cattleImage: cattlePhoto.map { Image(uiImage: $0) },
                    action: requestCameraAccess,
                    onRemove: { self.cattlePhoto = nil }
                )
                
                NameForm(namaCattle: $cattleName)
                
                AgeForm(usiaSapi: $cattleAge)
                
                NotesForm(notes: $notes)
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .alert(
            "Akses Kamera Diperlukan",
            isPresented: Binding(
                get: { cameraPermissionError != nil },
                set: { if !$0 { cameraPermissionError = nil } }
            )
        ) {
            Button("Buka Pengaturan") {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else {
                    return
                }
                UIApplication.shared.open(url)
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                cameraPermissionError
                    ?? "Silakan izinkan akses kamera di Pengaturan."
            )
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker(
                image: $cattlePhoto,
                isPresented: $isShowingCamera,
                onAccessDenied: {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        cameraPermissionError = "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
                    }
                }
            )
            .ignoresSafeArea()
        }
    }

    private func requestCameraAccess() {
        focusedField = nil

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            Task { @MainActor in
                await Task.yield()
                isShowingCamera = true
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        await Task.yield()
                        isShowingCamera = true
                    } else {
                        cameraPermissionError =
                            "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionError =
                "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
        @unknown default:
            cameraPermissionError =
                "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
        }
    }
}

#Preview {
    @Previewable @State var cattlePhoto: UIImage?
    @Previewable @State var cattleName: String = ""
    @Previewable @State var cattleAge: Int?
    @Previewable @State var notes: String?

    FirstPageForm(
        cattlePhoto: $cattlePhoto,
        cattleName: $cattleName,
        cattleAge: $cattleAge,
        notes: $notes
    )
}
