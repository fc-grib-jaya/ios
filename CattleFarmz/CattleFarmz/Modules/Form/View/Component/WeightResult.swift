//
//  WeightResult.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 19/11/26.
//

import SwiftUI

struct WeightResult: View {
    @Binding var bobotCattle: Double
    @Binding var chestGirth: Double
    @Binding var bodyLength: Double
    
    @State private var isEditingWeight = false
    @State private var originalWeight: Double = 0
    @FocusState private var isWeightFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    TextField(
                        value: $bobotCattle,
                        format: .number,
                        prompt: Text("Contoh: \"190,64\"").italic()
                            .accessibilityLabel("Bobot Sapi")
                    ) {
                        Text("Bobot Sapi (kg)")
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($isWeightFocused)
                    .disabled(!isEditingWeight)
                    .onChange(of: bobotCattle) { _, value in
                        let bounded = min(max(value, 0), 9_999)
                        let rounded = (bounded * 100).rounded() / 100

                        if value != rounded {
                            bobotCattle = rounded
                        }
                    }
                    .onChange(of: isWeightFocused) { _, focused in
                        if !focused {
                            isEditingWeight = false
                        }
                    }
                    .font(AppFont.mediumBody).bold()

                    Divider()
                        .overlay(AppColor.Text.primary)
                }
                
                Text("kg")
                    .foregroundStyle(AppColor.Text.primary)
                    .font(AppFont.mediumBody)
                
                Button {
                    if isEditingWeight {
                        bobotCattle = originalWeight
                        isWeightFocused = false
                        isEditingWeight = false
                    } else {
                        originalWeight = bobotCattle
                        isEditingWeight = true

                        Task { @MainActor in
                            await Task.yield()
                            isWeightFocused = true
                        }
                    }
                } label: {
                    Image(
                        systemName: isEditingWeight
                            ? "xmark"
                            : "pencil.line"
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.Text.primary)
                .accessibilityLabel(
                    isEditingWeight ? "Batalkan perubahan" : "Edit bobot sapi"
                )
            }
            .padding(.vertical, AppSpacing.xxs)
            .padding(.horizontal, AppSpacing.massive)
            
            HStack(spacing: AppSpacing.sm) {
                VStack(spacing: AppSpacing.xs) {
                    Text("Lingkar Dada")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
                    
                    HStack {
                        VStack {
                            TextField(
                                value: $chestGirth,
                                format: .number,
                                prompt: Text("LD Sapi").italic()
                                    .accessibilityLabel("Lingkar Dada Sapi")
                            ) {
                                Text("Lingkar dada (cm)")
                            }
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .onChange(of: chestGirth) { _, value in
                                let bounded = min(max(value, 0), 9_999)
                                let rounded = (bounded * 100).rounded() / 100

                                if value != rounded {
                                    chestGirth = rounded
                                }
                            }
                            .font(AppFont.mediumSubheadline).bold()

                            Divider()
                                .overlay(AppColor.Text.primary)
                        }
                        
                        Text("cm")
                            .foregroundStyle(AppColor.Text.primary)
                            .font(AppFont.mediumSubheadline)
                    }
                    .padding(.vertical, AppSpacing.xxs)
                    .padding(.horizontal, AppSpacing.xxl)
                }
                
                Divider()
                    .frame(width: AppSpacing.xxxs, height: AppSpacing.huge)
                    .overlay(AppColor.Primitive.Neutral.shade200)
                
                VStack(spacing: AppSpacing.xs) {
                    Text("Panjang Badan")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
                    
                    HStack {
                        VStack {
                            TextField(
                                value: $bodyLength,
                                format: .number,
                                prompt: Text("PB Sapi").italic()
                                    .accessibilityLabel("Panjang Badan Sapi")
                            ) {
                                Text("Panjang badan (cm)")
                            }
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .onChange(of: bodyLength) { _, value in
                                let bounded = min(max(value, 0), 9_999)
                                let rounded = (bounded * 100).rounded() / 100

                                if value != rounded {
                                    bodyLength = rounded
                                }
                            }
                            .font(AppFont.mediumSubheadline).bold()

                            Divider()
                                .overlay(AppColor.Text.primary)
                        }
                        
                        Text("cm")
                            .foregroundStyle(AppColor.Text.primary)
                            .font(AppFont.mediumSubheadline)
                    }
                    .padding(.vertical, AppSpacing.xxs)
                    .padding(.horizontal, AppSpacing.xxl)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isWeightFocused = false
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
}

#Preview {
    @Previewable @State var bobotCattle: Double = 1906
    @Previewable @State var chestGirth: Double = 190
    @Previewable @State var bodyLength: Double = 620.04
    
    WeightResult(bobotCattle: $bobotCattle, chestGirth: $chestGirth, bodyLength: $bodyLength)
}
