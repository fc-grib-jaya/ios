//
//  ADGCard.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 09/11/26.
//

import SwiftUI

struct ADGCard: View {
    
    let cattleName: String
    let cattleDetails: String
    let estimatedWeightKilograms: Double?
    
    @Binding var targetADG: Double
    
    let targetRange: ClosedRange<Double>
    let targetStep: Double
    let referenceADG: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.Card.compact){
            cattleSummary
            
            Divider()

            targetSection

            if let referenceADG {
                Divider()

                Text(
                    "ADG ideal sapi: \(formatted(referenceADG)) kg/day"
                )
                .font(AppFont.caption)
                .foregroundStyle(AppColor.Text.secondary)
            }
        }
        .padding(AppSpacing.Card.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background{
            // MARK: belum make AppRadius
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.Card.background)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var cattleSummary: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            Text(cattleName)
                .font(AppFont.title)
                .foregroundStyle(AppColor.Text.primary)
            
            Text(cattleDetails)
//                .font(AppFont.body)
                .font(.subheadline)
                .foregroundStyle(AppColor.Text.primary)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Estimated weight")
//                    .font(AppFont.body)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                
                Spacer()
                
                Text(weightText)
                    .font(AppFont.body.bold())
                    .foregroundStyle(AppColor.Primitive.Secondary.shade700)
            }
        }
    }
    
    private var targetSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            Text("Target kenaikan bobot")
                // MARK: belum make AppFont
                .font(.title3.bold())
            
            HStack(alignment: .firstTextBaseline) {
                Text(formatted(targetADG))
                    .font(AppFont.largeTitle)
                
                Text("kg/day")
                    .font(AppFont.body)
            }
            .foregroundStyle(AppColor.Text.primary)
            
            Slider(
                value: $targetADG,
                in: targetRange,
                step: targetStep
            ) {
                Text("Target average daily gain")
            }
            .tint(AppColor.Button.Primary.background)
            .accessibilityValue(
                Text("\(formatted(targetADG)) kilograms per day")
            )
        }
    }
    
    private var weightText: String {
        guard let estimatedWeightKilograms else {
            return "Not available"
        }
        
        return "\(formatted(estimatedWeightKilograms)) kg"
    }
    
    private func formatted(_ value: Double) -> String {
        value.formatted(
            .number.precision(.fractionLength(1))
        )
    }
}



#Preview {
    @Previewable @State var targetADG = 0.5
    
    ADGCard(
        cattleName: "Cattle #00001",
        cattleDetails: "Cross-breed · Male · 12 months",
        estimatedWeightKilograms: 544.5,
        targetADG: $targetADG,
        targetRange: 0.2...2.0,
        targetStep: 0.1,
        referenceADG: 0.8
    )
}
