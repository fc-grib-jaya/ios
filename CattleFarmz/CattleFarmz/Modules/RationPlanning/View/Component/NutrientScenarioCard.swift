import SwiftUI

struct NutrientScenarioCard: View {
    let before: NutrientComparison
    let after: NutrientComparison
    private var meetsMinimum: Bool { (after.coverage ?? 0) >= 1 }
    private var accent: Color {
        meetsMinimum ? AppColor.Primitive.Primary.shade500 : AppColor.Primitive.Secondary.shade600
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(after.name).font(AppFont.headline)
                Spacer()
                Text("Referensi " + formatted(after.minimum)).font(AppFont.caption)
            }
            chartRow("Saat ini", nutrient: before, color: AppColor.Text.secondary)
            chartRow("Skenario", nutrient: after, color: accent)
            Label(after.coverage == nil ? "Data belum tersedia" : (meetsMinimum ? "Memenuhi minimum" : "Di bawah referensi"),
                  systemImage: after.coverage == nil ? "questionmark.circle" : (meetsMinimum ? "checkmark" : "exclamationmark.triangle"))
                .font(AppFont.caption)
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs)
                .background(meetsMinimum ? AppColor.Primitive.Primary.shade100 : AppColor.Primitive.Secondary.shade200,
                            in: RoundedRectangle(cornerRadius: AppRadius.small))
        }
        .padding(AppSpacing.md)
        .background(meetsMinimum ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade50,
                    in: RoundedRectangle(cornerRadius: AppRadius.large))
        .shadow(color: AppColor.Primitive.Neutral.shade950.opacity(0.08), radius: 5, y: 2)
    }

    private func chartRow(_ title: String, nutrient: NutrientComparison, color: Color) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Text(title).font(AppFont.caption).foregroundStyle(AppColor.Text.secondary).frame(width: 62, alignment: .leading)
            NutrientBulletChart(coverage: nutrient.coverage, color: color)
            Text(formatted(nutrient.actual)).font(AppFont.caption).monospacedDigit()
                .frame(minWidth: 48, alignment: .trailing)
        }
    }

    private func formatted(_ value: Double?) -> String {
        guard let value else { return "—" }
        return evaluationNumber(value, digits: 1) + (after.unit == "%" ? "%" : " " + after.unit)
    }
}

#Preview {
    NutrientScenarioCard(
        before: NutrientComparison(name: "TDN", actual: 57.8, minimum: 60, unit: "%"),
        after: NutrientComparison(name: "TDN", actual: 59.8, minimum: 60, unit: "%")
    ).padding(AppSpacing.md)
}
