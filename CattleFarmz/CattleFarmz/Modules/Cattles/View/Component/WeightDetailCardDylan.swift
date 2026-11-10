//
//  WeightDetailCardDylan.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct WeightDetailCardDylan: View {
    let weight: Double?
    let updated: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                
                HStack {
                    Text("Estimasi Bobot")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.Text.primary)
                    
                    Spacer()
                    
                    Button {
                        // Ke Detail Bobot
                    } label: {
                        Text("Detail Bobot \(Image(systemName: "chevron.right"))")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(AppColor.Primitive.Secondary.shade200))
                }
                
                HStack {
                    Image(systemName: "scalemass.fill")
                        .resizable()
                        .frame(width: AppSpacing.xxl, height: AppSpacing.xxl)
                        .foregroundStyle(AppColor.Primitive.Secondary.shade900)

                    Text(
                        weight == nil
                        ? "Belum diukur"
                        : String(format: "%.2f kg", weight!)
                    )
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                }
                
                Text("Diperbaharui: \(formatDate(updated))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade500)
            }
            Spacer()
        }
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Secondary.shade50)
        .cornerRadius(AppSpacing.lg)
    }
}

#Preview {
    WeightDetailCardDylan(
        weight: 900, updated: .now
    )
}
