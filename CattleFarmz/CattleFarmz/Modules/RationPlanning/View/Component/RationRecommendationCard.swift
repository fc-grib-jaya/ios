import SwiftUI

struct RationRecommendationCard: View {
    let recommendation: RationRecommendation
    let onCompare: () -> Void

    private var focusIndex: Int { recommendation.focusTarget.comparisonIndex }

    private var before: NutrientComparison {
        NutrientComparison.rows(for: recommendation.before)[focusIndex]
    }

    private var after: NutrientComparison {
        NutrientComparison.rows(for: recommendation.after)[focusIndex]
    }

    private var sourceAmount: Double {
        recommendation.before.items.first { $0.id == recommendation.removedIngredient.id }?
            .kilogramsPerAnimalPerDay ?? 0
    }

    private var ingredientExplanation: String {
        let source = recommendation.removedIngredient
        let target = recommendation.addedIngredient
        let sourceValue = focusIndex == 1 ? source.nutrients.totalDigestibleNutrientsPercent : source.nutrients.crudeProteinPercent
        let targetValue = focusIndex == 1 ? target.nutrients.totalDigestibleNutrientsPercent : target.nutrients.crudeProteinPercent
        return target.name + " memiliki " + before.name + " " + percent(targetValue)
            + " dibanding " + source.name + " " + percent(sourceValue) + "."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
                Text(before.name).font(AppFont.body)
                Spacer()
                Text(percent(before.actual)).font(AppFont.headline)
                Image(systemName: "arrow.right").foregroundStyle(AppColor.Text.secondary)
                Text((after.actualIsMinimum ? "≥ " : "") + percent(after.actual)).font(AppFont.headline)
            }
            Divider()
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Text(recommendation.removedIngredient.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.right").foregroundStyle(AppColor.Text.secondary)
                Text(recommendation.addedIngredient.name)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(AppFont.headline)
            HStack(alignment: .top) {
                Text("Jumlah yang diganti")
                Spacer()
                Text(evaluationNumber(recommendation.replacedKilograms, digits: 2)
                     + " kg dari " + evaluationNumber(sourceAmount, digits: 2) + " kg")
                    .multilineTextAlignment(.trailing)
            }
            .font(AppFont.caption)
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: "info.circle")
                Text(ingredientExplanation)
            }
            .font(AppFont.caption)
            .padding(AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.Primitive.Neutral.shade100,
                        in: RoundedRectangle(cornerRadius: AppRadius.small))

            if !recommendation.meetsTargets {
                Text("Perbaikan sebagian · Protein dan Energi (TDN) belum keduanya mencapai acuan.")
                    .font(AppFont.caption).foregroundStyle(AppColor.Text.secondary)
            }
            Button(action: onCompare) {
                HStack {
                    Text("Tinjau perubahan")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(AppFont.mediumBody)
                .foregroundStyle(AppColor.Button.Primary.foreground)
                .padding(AppSpacing.sm)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(AppColor.Primitive.Primary.shade400,
                            in: RoundedRectangle(cornerRadius: AppRadius.medium))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.Card.compact)
        .background(AppColor.Primitive.Primary.shade50,
                    in: RoundedRectangle(cornerRadius: AppRadius.large))
        .shadow(color: AppColor.Primitive.Neutral.shade950.opacity(0.08), radius: 5, y: 2)
    }

    private func percent(_ value: Double?) -> String {
        guard let value else { return "Belum tersedia" }
        return evaluationNumber(value, digits: 1) + "%"
    }
}

#if DEBUG
#Preview {
    let result = RationEvaluationPreviewData.result
    RationRecommendationCard(recommendation: RationRecommendation(
        removedIngredient: result.items[0].ingredient,
        addedIngredient: result.items[1].ingredient,
        replacedKilograms: 2, before: result, after: result
    ), onCompare: {}).padding(AppSpacing.md)
}
#endif
