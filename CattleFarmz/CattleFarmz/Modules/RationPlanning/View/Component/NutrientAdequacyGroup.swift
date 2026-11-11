import SwiftUI

struct NutrientAdequacyGroup: View {
    let title: String
    let nutrients: [NutrientComparison]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title).font(AppFont.title)
            ForEach(nutrients) { nutrient in
                NutrientAdequacyCard(nutrient: nutrient)
            }
        }
        .evaluationCard()
    }
}

#if DEBUG
#Preview {
    NutrientAdequacyGroup(
        title: "Energi & protein",
        nutrients: Array(NutrientComparison.rows(for: RationEvaluationPreviewData.result).prefix(2))
    )
    .padding(AppSpacing.md)
}
#endif
