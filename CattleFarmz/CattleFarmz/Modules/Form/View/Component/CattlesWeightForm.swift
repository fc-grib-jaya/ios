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
    @State private var chestGirth = 0.0
    @State private var bodyLength = 0.0
    @State private var manual = false

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack {
            if !manual {
                if scanResult != nil {
                    Spacer()
                }
                
                HStack(spacing: 1) {
                    Text("Bobotnya berapa?")
                        .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                    Text("*")
                        .foregroundStyle(Color.red)
                }
                .font(AppFont.formTitle)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.lg)

                if scanResult?.girth != nil,
                   let bobotCattleBinding = Binding($bobotCattle) {
                    WeightResult(
                        bobotCattle: bobotCattleBinding,
                        chestGirth: $chestGirth,
                        bodyLength: $bodyLength
                    )
                    .padding(.horizontal, AppSpacing.xl)
                    Spacer()
                    Button {
                        startScan()
                    } label: {
                        Text(
                            "\(Image(systemName: "arrow.clockwise"))  Ukur bobot ulang"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .appButtonStyle(.goldSecondary)
                    .accessibilityLabel("Estimasi Bobot")
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                } else {
                    Button {
                        startScan()
                    } label: {
                        Text(
                            "\(Image(systemName: "scalemass.fill"))  Ukur bobot dengan kamera"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .appButtonStyle(.goldPrimary)
                    .accessibilityLabel("Estimasi Bobot")
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.xs)

                    Button {
                        focusedField = nil
                        manual = true
                    } label: {
                        Text("Isi bobot manual")
                            .font(AppFont.mediumBody)
                            .foregroundStyle(
                                AppColor.Primitive.Secondary.shade700
                            )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Isi bobot manual")
                    .padding(.horizontal, AppSpacing.xl)
                }

            } else {
                ManualWeightForm(
                    bobotCattle: $bobotCattle,
                    scanResult: $scanResult,
                    jenisSapi: $jenisSapi,
                    genderSapi: $genderSapi,
                    onScanSession: onScanSession,
                    isActive: true
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
            dismissKeyboard()
        }
        .onChange(of: isActive) { _, isActive in
            if !isActive {
                focusedField = nil
            }
        }
        .onChange(of: jenisSapi) { _, _ in
            recalculateWeight()
        }
        .onChange(of: genderSapi) { _, _ in
            recalculateWeight()
        }
        .onChange(of: chestGirth) { _, _ in
            recalculateWeight()
        }
        .onChange(of: bodyLength) { _, _ in
            recalculateWeight()
        }
        .onAppear {
            synchronizeMeasurementsFromScanResult()
            recalculateWeight()
        }
        .alert(
            "Foto sapi belum tersedia",
            isPresented: $isAskingToUseScanPhoto
        ) {
            Button("Ya, jadikan foto profil") {
                cattlePhoto = pendingScanPhoto
                pendingScanPhoto = nil
            }
            Button("Tidak", role: .cancel) {
                pendingScanPhoto = nil
            }
        } message: {
            Text(
                "Apakah anda ingin menjadikan foto estimasi bobot menjadi foto profil sapi?"
            )
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
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func startScan() {
        focusedField = nil

        Task { @MainActor in
            await Task.yield()
            onScanSession(handleScanResult)
        }
    }

    private func handleScanResult(_ result: ScanResult?) {
        guard let result else { return }

        let croppedImage =
            result.cattleImage.cattleSquareCropped()
            ?? result.cattleImage
        let normalizedResult = ScanResult(
            lengthCM: result.lengthCM,
            girth: result.girth,
            cattleImage: croppedImage
        )
        scanResult = normalizedResult
        chestGirth = normalizedResult.girth ?? 0
        bodyLength = normalizedResult.lengthCM
        recalculateWeight()
        pendingScanPhoto = cattlePhoto == nil ? croppedImage : nil
        isAskingToUseScanPhoto = false

        // The LiDAR cover is dismissed after the scan callback. Delay the alert
        // until that dismissal finishes so SwiftUI can present it on the form.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard isActive, cattlePhoto == nil, pendingScanPhoto != nil else {
                return
            }
            isAskingToUseScanPhoto = true
        }
    }

    private func synchronizeMeasurementsFromScanResult() {
        guard let scanResult else {
            return
        }

        chestGirth = scanResult.girth ?? 0
        bodyLength = scanResult.lengthCM
    }

    private func recalculateWeight() {
        guard scanResult != nil else {
            return
        }

        if let jenisSapi, let genderSapi {
            bobotCattle = WeightCalculator().cattleWeight(
                chestGirth: chestGirth,
                bodyLength: bodyLength,
                breed: jenisSapi,
                gender: genderSapi
            )
        } else {
            bobotCattle = nil
        }

        guard let currentScanResult = scanResult else {
            return
        }

        scanResult = ScanResult(
            lengthCM: bodyLength,
            girth: chestGirth,
            cattleImage: currentScanResult.cattleImage
        )
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
