//
//  ManualWeightForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 19/11/26.
//

import SwiftUI

struct ManualWeightForm: View {
    @Binding var bobotCattle: Double?
    @Binding var scanResult: ScanResult?
    @Binding var jenisSapi: CattleBreed?
    @Binding var genderSapi: CattleGender?

    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    let isActive: Bool

    @State private var pendingScanPhoto: UIImage?
    @State private var isAskingToUseScanPhoto = false

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 1) {
                Text("Bobotnya berapa?")
                    .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                Text("*")
                    .foregroundStyle(Color.red)
            }
            .font(AppFont.formTitle)
            .multilineTextAlignment(.center)
            .padding(.vertical, AppSpacing.lg)
            
            HStack {
                VStack {
                    TextField(
                        value: $bobotCattle,
                        format: .number,
                        prompt: Text("Contoh: \"190,64\"").italic()
                            .accessibilityLabel("Tuliskan Bobot Sapi")
                    ) {
                        Text("Bobot Sapi (kg)")
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .onChange(of: bobotCattle) { _, value in
                        guard let value else { return }

                        let bounded = min(max(value, 0), 9_999)
                        let rounded = (bounded * 100).rounded() / 100

                        if value != rounded {
                            bobotCattle = rounded
                        }
                    }
                    .font(AppFont.mediumBody)
                    .focused($focusedField, equals: .weight)

                    Divider()
                        .overlay(AppColor.Text.primary)
                }

                Text("kg")
                    .foregroundStyle(AppColor.Text.primary)
                    .font(AppFont.mediumBody)
            }
            .padding(.vertical, AppSpacing.xxs)
            .padding(.horizontal, AppSpacing.massive)

            Spacer()

            Button {
                startScan()
            } label: {
                Text(
                    "\(Image(systemName: "scalemass.fill"))  Ukur bobot dengan kamera"
                )
                .frame(maxWidth: .infinity)
            }
            .appButtonStyle(.goldSecondary)
            .accessibilityLabel("Estimasi Bobot")
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
            dismissKeyboard()
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
        bobotCattle = estimatedWeight(for: normalizedResult)
        pendingScanPhoto = croppedImage
        isAskingToUseScanPhoto = false

        // The LiDAR cover is dismissed after the scan callback. Delay the alert
        // until that dismissal finishes so SwiftUI can present it on the form.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard isActive, pendingScanPhoto != nil else { return }
            isAskingToUseScanPhoto = true
        }
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
}

#Preview {
    @Previewable @State var bobotCattle: Double?
    @Previewable @State var scanResult: ScanResult?
    @Previewable @State var jenisSapi: CattleBreed?
    @Previewable @State var genderSapi: CattleGender?
    
    ManualWeightForm(
        bobotCattle: $bobotCattle,
        scanResult: $scanResult,
        jenisSapi: $jenisSapi,
        genderSapi: $genderSapi,
        onScanSession: { _ in},
        isActive: true
    )
}
