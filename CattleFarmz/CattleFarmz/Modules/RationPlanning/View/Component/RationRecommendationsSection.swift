import SwiftUI

struct RationRecommendationsSection: View {
    let result: RationCalculationResult
    @Bindable var viewModel: RationPlanningViewModel
    let onCompare: (RationRecommendation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Pilihan perbaikan nutrisi").font(AppFont.title)
            ForEach(viewModel.repairGroups) { group in
                if let option = group.best {
                    RationRecommendationCard(recommendation: option) {
                        onCompare(option)
                    }
                }
            }
            if let message = viewModel.repairMessage {
                Text(message).font(AppFont.body)
            }

        }
        .evaluationCard()
        .task(id: result.items) {
            viewModel.findRepairs(for: result)
        }

    }
}

#if DEBUG
#Preview {
    RationRecommendationsSection(
        result: RationEvaluationPreviewData.result,
        viewModel: DIContainer.preview.makeRationPlanningViewModel(),
        onCompare: { _ in }
    )
    .padding(AppSpacing.md)
}
#endif
