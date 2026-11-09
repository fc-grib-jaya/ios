//
//  WeightDetailCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 07/11/26.
//

import SwiftUI

struct WeightDetailCard: View {
    let weight: Double?
    let updated: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                
                HStack {
                    Text("Estimasi Bobot")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade50)
                    
                    Spacer()
                    
                    Button {
                        // Ke Detail Bobot
                    } label: {
                        Text("Detail Bobot \(Image(systemName: "chevron.right"))")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Base.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(AppColor.Primitive.Secondary.shade800))
                }
                
                Text(
                    weight == nil
                    ? "Belum diukur"
                    : String(format: "%.2f kg", weight!)
                )
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.Primitive.Neutral.shade50)
                
                Text("Update: \(formatDate(updated))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade300)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Secondary.shade600)
        .cornerRadius(AppSpacing.lg)
    }
}

#Preview {
    WeightDetailCard(
        weight: 900, updated: .now
    )
}
