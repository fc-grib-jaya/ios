//
//  ProgressCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 21/11/26.
//

import SwiftUI

struct ProgressCard: View {
    let progress: String
    let weight: Double
    let sign: String
    let difference: Int
    let secondLast: Date?
    let lastUpdate: Date
    var records: [CattleWeightProgress] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if secondLast != nil {
                    Text(
                        "Bobot \(progress) menjadi \(String(format: "%.2f kg", weight))"
                    )
                    .font(AppFont.headline)
                } else {
                    Text("Bobot \(String(format: "%.2f kg", weight))")
                        .font(AppFont.headline)
                }
                
                if let secondLast {
                    Text(
                        "\(sign)\(difference) kg dari pengukuran sebelumnya"
                    )
                    .font(AppFont.caption).fontWeight(.semibold)
                } else {
                    Text("belum ada pengukuran lainnya")
                        .font(AppFont.callout)
                }
                
                Text("Estimasi bobot terakhir \(formattedDate(kapan: lastUpdate))")
                    .font(AppFont.subheadline)
            }
            
            ProgressChart(records: records)
                .padding(.vertical, AppSpacing.sm)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 23)
                .fill(AppColor.Primitive.Neutral.shade100)
        )
    }
    
    private func formattedDate(kapan: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        formatter.dateFormat = "d MMM yyyy"
        
        return "\(formatter.string(from: kapan))"
    }
}

#Preview {
    ProgressCard(
        progress: "Naik",
        weight: 196,
        sign: "+",
        difference: 4,
        secondLast: .now.addingTimeInterval(-7 * 86_400),
        lastUpdate: .now
    )
}
