import SwiftUI

struct RationAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    let result: RationCalculationResult
    let onShowDetails: () -> Void
    var cattleName: String? = nil
    var onSave: (() -> Void)? = nil

    var body: some View {
        let comparisons = NutrientComparison.rows(for: result)
        let below = comparisons.filter { ($0.coverage ?? 1) < 1 }
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                RationProfileCard(profile: result.profile, cattleName: cattleName)
                    .padding(.bottom, -AppSpacing.xs)

                NutritionResultCard(below: below.count,
                                    unknown: comparisons.filter { $0.coverage == nil }.count,
                                    total: comparisons.count)
                NutrientReviewCard(result: result, onShowDetails: onShowDetails)
                ReviewedFeedsCard(result: result)

                Button {
                    onSave?()
                } label: {
                    Text("Simpan")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                }
                .disabled(onSave == nil)
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500).interactive(), in: Capsule())
            }
            .padding(AppSpacing.Screen.compact)
        }
//        .font(AppFont.body)
//        .foregroundStyle(AppColor.Text.primary)
//        .background(AppColor.Surface.canvas)
        .navigationTitle("Evaluasi pakan")
        .navigationBarTitleDisplayMode(.inline)
    }

}

#if DEBUG
#Preview("Evaluasi pakan") {
    NavigationStack {
        RationAnalysisView(
            result: RationEvaluationPreviewData.result,
            onShowDetails: {},
            cattleName: "Sapi #00001"
        )
    }
}
#endif
