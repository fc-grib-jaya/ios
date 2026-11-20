import SwiftUI

struct NutrientReviewCard: View {
    let result: RationCalculationResult
    let onShowDetails: () -> Void

    private var rows: [NutrientComparison] {
        NutrientComparison.rows(for: result)
    }
    
    private var hasDeficiency: Bool {
        rows.prefix(2).contains { nutrient in
            guard let coverage = nutrient.coverage else {
                return false
            }

            return coverage < 1
        }
    }

    private var headerColors: [Color] {
        if hasDeficiency {
            return [
                AppColor.Primitive.Secondary.shade400,
                AppColor.Primitive.Secondary.shade600
            ]
        }

        return [
            AppColor.Primitive.Primary.shade400,
            AppColor.Primitive.Primary.shade600
        ]
    }

    private var remainingCount: Int {
        max(0, rows.count - 2)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onShowDetails) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(AppFont.title)

                    Text("Lihat detail analisis")
                        .font(AppFont.headline)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(AppFont.headline)
                }
                .foregroundStyle(AppColor.Button.Primary.foreground)
                .padding(AppSpacing.Card.compact)
                .padding(.bottom, AppSpacing.xxl)
                .frame(maxWidth: .infinity, minHeight: 64)
                .contentShape(Rectangle())
            }
            .background {
                LinearGradient(
                    colors: headerColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.large)
            )
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Ringkasan nutrisi")
                    .font(AppFont.title)

                ForEach(rows.prefix(2)) { nutrient in
                    NutrientAdequacyCard(nutrient: nutrient)
                }

                Divider()

                Text("+ \(remainingCount) nutrisi lainnya pada detail analisis")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Text.secondary)
            }
            .padding(AppSpacing.Card.compact)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background{
                RoundedRectangle(cornerRadius: 16).fill(
                    AppColor.Primitive.Base.white
                ).shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding(.top, -AppSpacing.xxl)
        }
    }
}

#if DEBUG
#Preview {
    NutrientReviewCard(
        result: RationEvaluationPreviewData.result,
        onShowDetails: {}
    )
    .padding(AppSpacing.md)
}
#endif
