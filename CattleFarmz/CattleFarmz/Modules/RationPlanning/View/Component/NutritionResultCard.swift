import SwiftUI

struct NutritionResultCard: View {
    let status: NutritionResultStatus
    let onTap: () -> Void
    
    private var complete: Bool { status.complete }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            HStack(spacing: AppSpacing.sm) {
                if let message = status.belowMessage {
                    Text(LocalizedStringKey(message))
                        .font(AppFont.titleBase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if complete {
                    Text("**Energi (TDN) dan Protein** telah mencapai referensi minimum")
                        .font(AppFont.titleBase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let message = status.unavailableMessage {
                    Text(LocalizedStringKey(message))
                        .font(AppFont.titleBase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(complete ? "Image/NutritionCheck" : "Image/NutritionWarn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92)
                    .accessibilityHidden(true)
            }
            .padding(AppSpacing.md)
            
            if !complete {
                Button{
                    onTap()
                } label:{
                    HStack {
                        Text("Pergi ke **Pilihan perbaikan nutrisi**")
                            .font(AppFont.subheadlineBase)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(AppSpacing.md)
                    .background(
                        AppColor.Primitive.Secondary.shade200,
                        in: RoundedRectangle(cornerRadius: AppRadius.large)
                    )
                }
            }
        }
        .frame(minHeight: 194)
        .font(AppFont.body)
        .padding(AppSpacing.md)
        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
        .background(complete ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade50,
                    in: RoundedRectangle(cornerRadius: AppRadius.large))
    }
}

#Preview("TDN di bawah referensi") {
    NutritionResultCard(
        status: NutritionResultStatus(proteinCoverage: 1.2, tdnCoverage: 0.9),
        onTap: {}
    )
        .padding(AppSpacing.md)
}

#Preview("Protein di bawah referensi") {
    NutritionResultCard(
        status: NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 1.1),
        onTap: {}
    )
        .padding(AppSpacing.md)
}

#Preview("Protein dan TDN di bawah referensi") {
    NutritionResultCard(
        status: NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 0.9),
        onTap: {}
    )
        .padding(AppSpacing.md)
}

#Preview("Minimum terpenuhi") {
    NutritionResultCard(
        status: NutritionResultStatus(proteinCoverage: 1, tdnCoverage: 1),
        onTap: {}
    )
        .padding(AppSpacing.md)
}

#Preview("Data belum lengkap") {
    NutritionResultCard(
        status: NutritionResultStatus(proteinCoverage: 1, tdnCoverage: nil),
        onTap: {}
    )
        .padding(AppSpacing.md)
}
