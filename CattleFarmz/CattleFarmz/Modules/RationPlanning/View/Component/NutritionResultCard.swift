import SwiftUI

struct NutritionResultCard: View {
    let status: NutritionResultStatus

    private var complete: Bool { status.complete }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Text(complete ? "Semua minimum referensi terpenuhi." : "Ada yang perlu ditinjau kembali.")
                    .font(AppFont.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(complete ? "NutritionCheck" : "NutritionWarn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92)
                    .accessibilityHidden(true)
            }
            if let message = status.belowMessage {
                Text(LocalizedStringKey(message))
            } else if complete {
                Text("Seluruh 2 nutrisi mencapai nilai minimum referensi.")
            }
            if let message = status.unavailableMessage {
                Text(LocalizedStringKey(message))
            }
        }
        .font(AppFont.body)
        .padding(AppSpacing.xxl)
        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
        .background(complete ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade50,
                    in: RoundedRectangle(cornerRadius: AppRadius.large))
    }
}

#Preview("TDN di bawah referensi") {
    NutritionResultCard(status: NutritionResultStatus(proteinCoverage: 1.2, tdnCoverage: 0.9))
        .padding(AppSpacing.md)
}

#Preview("Protein di bawah referensi") {
    NutritionResultCard(status: NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 1.1))
        .padding(AppSpacing.md)
}

#Preview("Protein dan TDN di bawah referensi") {
    NutritionResultCard(status: NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 0.9))
        .padding(AppSpacing.md)
}

#Preview("Minimum terpenuhi") {
    NutritionResultCard(status: NutritionResultStatus(proteinCoverage: 1, tdnCoverage: 1))
        .padding(AppSpacing.md)
}

#Preview("Data belum lengkap") {
    NutritionResultCard(status: NutritionResultStatus(proteinCoverage: 1, tdnCoverage: nil))
        .padding(AppSpacing.md)
}
