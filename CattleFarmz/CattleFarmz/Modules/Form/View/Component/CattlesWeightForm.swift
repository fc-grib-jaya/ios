//
//  CattlesWeightForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import AVFoundation
import SwiftUI
import UIKit

struct CattlesWeightForm: View {
    @Binding var bobotCattle: Double?
    @Binding var cattlePhoto: UIImage?
    @Binding var scanResult: ScanResult?
    @Binding var jenisSapi: CattleBreed?
    @Binding var genderSapi: CattleGender?
    let isActive: Bool

    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void

    @State private var isShowingCamera = false
    @State private var cameraPermissionError: String?
    @State private var pendingScanPhoto: UIImage?
    @State private var isAskingToUseScanPhoto = false
    
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack {
            Text("Bobot sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)

            Spacer()

            HStack {
                VStack {
                    TextField(
                        value: $bobotCattle,
                        format: .number,
                        prompt: Text("Contoh: \"190,64\"").italic()
                    ) {
                        Text("Bobot Sapi (kg)")
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: .weight)

                    Divider()
                        .overlay(AppColor.Text.primary)
                }

                Text("kg")
                    .foregroundStyle(AppColor.Text.primary)
            }
            .padding(.vertical, AppSpacing.xxs)
            .padding(.horizontal, AppSpacing.massive)

            Text("Tidak tahu bobot?")
                .font(AppFont.mediumBody.bold())
                .padding(.vertical, AppSpacing.sm)

            Button {
                startScan()
            } label: {
                Text("\(Image(systemName: "scalemass.fill"))  Estimasi Bobot")
                    .frame(maxWidth: .infinity)
            }
            .appButtonStyle(.goldPrimary)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xs)

            Group {
                if let cattlePhoto {
                    CattlesPictureCard(
                        cattleImage: Image(uiImage: cattlePhoto),
                        action: requestCameraAccess,
                        onRemove: { self.cattlePhoto = nil }
                    )
                } else {
                    Button(action: requestCameraAccess) {
                        Text("Ambil foto profil sapi")
                            .frame(maxWidth: .infinity)
                    }
                    .appButtonStyle(.goldSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.xl)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: isActive) { _, isActive in
            if !isActive {
                focusedField = nil
            }
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
        .alert(
            "Pakai foto hasil LiDAR?",
            isPresented: $isAskingToUseScanPhoto
        ) {
            Button("Ya, pakai sebagai profil") {
                cattlePhoto = pendingScanPhoto
                pendingScanPhoto = nil
            }
            Button("Tidak", role: .cancel) {
                pendingScanPhoto = nil
            }
        } message: {
            Text("Apakah foto yang diambil saat pemindaian LiDAR ingin digunakan sebagai foto profil sapi?")
        }
        .alert(
            "Akses Kamera Diperlukan",
            isPresented: Binding(
                get: { cameraPermissionError != nil },
                set: { if !$0 { cameraPermissionError = nil } }
            )
        ) {
            Button("Buka Pengaturan") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(url)
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(cameraPermissionError ?? "Silakan izinkan akses kamera di Pengaturan.")
        }
    }

    private func startScan() {
        onScanSession(handleScanResult)
    }

    private func handleScanResult(_ result: ScanResult?) {
        guard let result else { return }

        scanResult = result
        bobotCattle = estimatedWeight(for: result)
        pendingScanPhoto = result.cattleImage
        isAskingToUseScanPhoto = true
    }

    private func estimatedWeight(for result: ScanResult) -> Double? {
        guard let girth = result.girth,
              let jenisSapi,
              let genderSapi
        else {
            return nil
        }

        return WeightCalculator().cattleWeight(
            chestGirth: girth,
            bodyLength: result.lengthCM,
            breed: jenisSapi,
            gender: genderSapi
        )
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        isShowingCamera = true
                    } else {
                        cameraPermissionError = "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionError = "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
        @unknown default:
            cameraPermissionError = "Akses kamera diperlukan. Silakan izinkan akses kamera di Pengaturan, lalu coba lagi."
        }
    }
}

#Preview {
    @Previewable @State var bobotCattle: Double?
    @Previewable @State var cattlePhoto: UIImage?
    @Previewable @State var scanResult: ScanResult?
    @Previewable @State var jenisSapi: CattleBreed?
    @Previewable @State var genderSapi: CattleGender?

    CattlesWeightForm(
        bobotCattle: $bobotCattle,
        cattlePhoto: $cattlePhoto,
        scanResult: $scanResult,
        jenisSapi: $jenisSapi,
        genderSapi: $genderSapi,
        isActive: true,
        onScanSession: { _ in }
    )
}
