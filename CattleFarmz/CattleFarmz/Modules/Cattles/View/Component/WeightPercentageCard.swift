//
//  WeightPercentageCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct WeightPercentageCard: View {
    let carcassPercent: Double
    let nonCarcassPercent: Double
    let carcassWeight: Double
    let nonCarcassWeight: Double

    var body: some View {
        VStack {
            
        }
        HStack {
            VStack (alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(AppColor.Primitive.Secondary.shade700)
                        .frame(width: 12)
                    
                    Text("Karkas")
                        .font(AppFont.body)
                }
                
                HStack(alignment: .bottom, spacing: AppSpacing.xxs) {
                    Text(String(carcassPercent))
                        .font(AppFont.largeTitle)
                    
                    Text("%")
                        .font(AppFont.body)
                        .padding(.bottom, AppSpacing.xxs)
                }
                
                Text(String(format: "%.2f kg", carcassWeight))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade400)
            }
            Spacer()
            Divider()
                .frame(width: AppSpacing.xxxs, height: 100)
                .overlay(AppColor.Primitive.Neutral.shade200)
                .padding(.horizontal, AppSpacing.md)
            
            VStack (alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(AppColor.Primitive.Primary.shade500)
                        .frame(width: 12)
                    
                    Text("Non-Karkas")
                        .font(AppFont.body)
                }
                
                HStack(alignment: .bottom, spacing: AppSpacing.xxs) {
                    Text(String(nonCarcassPercent))
                        .font(AppFont.largeTitle)
                    
                    Text("%")
                        .font(AppFont.body)
                        .padding(.bottom, AppSpacing.xxs)
                }
                
                Text(String(format: "%.2f kg", nonCarcassWeight))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade400)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Surface.canvas)
        .cornerRadius(19)
    }
}

#Preview {
    WeightPercentageCard(
        carcassPercent: 65,
        nonCarcassPercent: 35,
        carcassWeight: 353.9,
        nonCarcassWeight: 190.6
    )
}
