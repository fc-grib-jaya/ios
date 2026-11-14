import SwiftUI

struct ReviewedFeedsCard: View {
    let result: RationCalculationResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Susunan yang diperiksa").font(AppFont.title)
            ForEach(result.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(item.ingredient.name).font(AppFont.headline)
                        Text(item.ingredient.category.displayName)
                    }
                    Spacer()
                    Text("\(evaluationNumber(item.kilogramsPerAnimalPerDay)) kg").font(AppFont.headline)
                }
                Divider()
            }
            HStack {
                Text("Total pemberian per hari")
                Spacer()
                Text("\(evaluationNumber(result.kilogramsPerAnimalPerDay)) kg")
            }
            .font(AppFont.headline)
        }
        .evaluationCard()
    }
}

#if DEBUG
#Preview {
    ReviewedFeedsCard(result: RationEvaluationPreviewData.result)
        .padding(AppSpacing.md)
}
#endif
