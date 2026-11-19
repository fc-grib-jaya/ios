import SwiftUI

struct RationAnalysisView: View {
    let result: RationCalculationResult
    let onShowDetails: () -> Void
    var cattleName: String? = nil
    var onSave: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var rationVM: RationPlanningViewModel? = nil
    var onReviewRecommendation: ((RationRecommendation) -> Void)? = nil
    
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    RationProfileCard(profile: result.profile, cattleName: cattleName)
                    
                    NutritionResultCard(status: NutritionResultStatus(result: result)){
                        withAnimation {
                            proxy.scrollTo("evaluate", anchor: .top)
                        }
                    }
                    NutrientReviewCard(result: result, onShowDetails: onShowDetails)
                    if let rationVM, let onReviewRecommendation {
                        RationRecommendationsSection(result: result, viewModel: rationVM, onCompare: onReviewRecommendation)
                            .id("evaluate")
                    }
                    ReviewedFeedsCard(result: result)
                    
                    if let onSave {
                        Button(action: onSave) {
                            Text("Simpan")
                                .foregroundStyle(.white)
                        }
                        .appButtonStyle(.primary)
                    }
                }
                .padding(AppSpacing.Screen.compact)
            }
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
