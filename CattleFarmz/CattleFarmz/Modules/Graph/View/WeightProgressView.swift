//
//  WeightProgressView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 21/11/26.
//

import SwiftUI

struct WeightProgressView: View {
    let progress: String
    let weight: Double
    let sign: String
    let difference: Int
    let secondLast: Date?
    let lastUpdate: Date
    var records: [CattleWeightProgress] = []
    var onMeasureTap: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Perkembangan bobot")
                .font(AppFont.title).bold()
                .foregroundStyle(AppColor.Primitive.Neutral.shade950)

            ProgressCard(
                progress: progress,
                weight: weight,
                sign: sign,
                difference: difference,
                secondLast: secondLast ?? nil,
                lastUpdate: lastUpdate,
                records: records
            )
            
            Text("Grafik menunjukan progres pertumbuhan bobot")
                .font(AppFont.caption)
                .padding(.vertical, AppSpacing.xs)
                .foregroundStyle(AppColor.Primitive.Neutral.shade400)
            
            Button {
                onMeasureTap()
            } label: {
                Text("\(Image(systemName: "scalemass.fill")) Ukur Perkembangan")
            }
            .appButtonStyle(.secondary)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Base.white)
        .cornerRadius(16)
        .shadow(
            color: Color(red: 0.000, green: 0.000, blue: 0.000, opacity: 0.05),
            radius: 5,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    WeightProgressView(
        progress: "Naik",
        weight: 196,
        sign: "+",
        difference: 4,
        secondLast: .now.addingTimeInterval(-7 * 86_400),
        lastUpdate: .now
    )
}
