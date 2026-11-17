import SwiftUI

struct RationAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    let result: RationCalculationResult
    let onShowDetails: () -> Void
    var cattleName: String? = nil
    var onSave: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil

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
                }
                .disabled(onSave == nil)
                .appButtonStyle(.primary)
            }
            .padding(AppSpacing.Screen.compact)
        }
        .navigationTitle("Evaluasi pakan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onEdit {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
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
