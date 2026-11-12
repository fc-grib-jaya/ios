import SwiftUI

struct FeedProportionsCard: View {
    let result: RationCalculationResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Proporsi Pakan").font(AppFont.title)
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(FeedCategory.allCases) { category in
                        color(category).frame(width: geometry.size.width * result.sharePercent(for: category) / 100)
                    }
                }
            }
            .frame(height: AppSpacing.massive)
            .accessibilityHidden(true)
            ForEach(FeedCategory.allCases) { category in
                LabeledContent {
                    Text(evaluationNumber(result.sharePercent(for: category)) + " %").font(AppFont.headline)
                } label: {
                    HStack {
                        Circle().fill(color(category)).frame(width: AppSpacing.xs, height: AppSpacing.xs)
                        Text(category.displayName)
                    }
                }
                if category != FeedCategory.allCases.last { Divider() }
            }
        }
        .evaluationCard()
    }

    private func color(_ category: FeedCategory) -> Color {
        switch category {
        case .forage: AppColor.Primitive.Primary.shade500
        case .concentrate: AppColor.Primitive.Secondary.shade600
        case .mineral: AppColor.Primitive.Neutral.shade300
        }
    }
}

#if DEBUG
#Preview {
    FeedProportionsCard(result: RationEvaluationPreviewData.result).padding(AppSpacing.md)
}
#endif
