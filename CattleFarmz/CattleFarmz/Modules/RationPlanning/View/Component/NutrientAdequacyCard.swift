import SwiftUI

struct NutrientAdequacyCard: View {
    let nutrient: NutrientComparison

    private var meetsMinimum: Bool { (nutrient.coverage ?? 0) >= 1 }
    private var accent: Color {
        guard nutrient.coverage != nil else { return AppColor.Text.secondary }
        return meetsMinimum ? AppColor.Primitive.Primary.shade500 : AppColor.Primitive.Secondary.shade600
    }
    private var status: String {
        guard nutrient.coverage != nil else { return "Data belum tersedia" }
        return meetsMinimum ? "Memenuhi minimum" : "Di bawah referensi"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(nutrient.name).font(AppFont.headline)
                Spacer()
                Text(nutrient.coverage.map { evaluationNumber($0 * 100, digits: 0) + "%" } ?? "—")
                    .font(AppFont.title)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Referensi minimum " + formatted(nutrient.minimum))
                Spacer()
                Text(formatted(nutrient.actual))
            }
            .font(AppFont.caption)
            .foregroundStyle(AppColor.Text.secondary)

            NutrientBulletChart(coverage: nutrient.coverage, color: accent)
            Label(status, systemImage: nutrient.coverage == nil ? "questionmark.circle" : (meetsMinimum ? "checkmark" : "exclamationmark.triangle"))
                .font(AppFont.caption)
                .padding(.horizontal, AppSpacing.xxs)
                .padding(.vertical, AppSpacing.xxs)
                .background(
                    meetsMinimum ? AppColor.Primitive.Primary.shade100 : AppColor.Primitive.Secondary.shade200,
                    in: RoundedRectangle(cornerRadius: AppRadius.small)
                )
        }
        .padding(AppSpacing.Card.compact)
        .foregroundStyle(AppColor.Text.primary)
        .background(
            nutrient.coverage == nil ? AppColor.Surface.inset : (meetsMinimum ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade50),
            in: RoundedRectangle(cornerRadius: AppRadius.large)
        )
        .shadow(color: AppColor.Primitive.Neutral.shade950.opacity(0.08), radius: 5, y: 2)
    }

    private func formatted(_ value: Double?) -> String {
        guard let value else { return "Tidak tersedia" }
        return evaluationNumber(value) + (nutrient.unit == "%" ? "%" : " " + nutrient.unit)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        NutrientAdequacyCard(nutrient: NutrientComparison(name: "Protein kasar", actual: 15.53, minimum: 10.5, unit: "%"))
        NutrientAdequacyCard(nutrient: NutrientComparison(name: "TDN", actual: 57.12, minimum: 60, unit: "%"))
        NutrientAdequacyCard(nutrient: NutrientComparison(name: "Zinc", actual: nil, minimum: 40, unit: "ppm"))
    }
    .padding(AppSpacing.md)
}
