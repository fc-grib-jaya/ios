import SwiftUI

struct RationChangesTable: View {
    let recommendation: RationRecommendation
    let scenario: RationCalculationResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Perubahan pemberian").font(AppFont.title)
            HStack {
                Text("Bahan")
                Spacer()
                Text("Saat ini").frame(width: 72, alignment: .trailing)
                Text("Skenario").foregroundStyle(AppColor.Primitive.Secondary.shade600)
                    .frame(width: 80, alignment: .trailing)
            }.font(AppFont.caption).foregroundStyle(AppColor.Text.secondary)
            ForEach([recommendation.removedIngredient, recommendation.addedIngredient]) { feed in
                Divider()
                HStack {
                    Text(feed.name)
                    Spacer()
                    Text(amount(feed.id, in: recommendation.before)).frame(width: 72, alignment: .trailing)
                    Text(amount(feed.id, in: scenario)).font(AppFont.headline).frame(width: 80, alignment: .trailing)
                }.font(AppFont.body)
            }
        }
    }

    private func amount(_ id: String, in result: RationCalculationResult) -> String {
        evaluationNumber(result.items.first { $0.id == id }?.kilogramsPerAnimalPerDay ?? 0) + " kg"
    }
}

#if DEBUG
#Preview {
    let vm = RationRecommendationPreviewData.viewModel()
    if let scenario = vm.scenario {
        RationChangesTable(recommendation: vm.selected, scenario: scenario).evaluationCard().padding(AppSpacing.md)
    }
}
#endif
