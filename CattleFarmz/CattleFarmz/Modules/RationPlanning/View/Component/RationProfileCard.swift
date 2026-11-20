import SwiftUI

struct RationProfileCard: View {
    let profile: CattleRationProfile
    let cattleName: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(cattleName ?? "Profil sapi")
                    .font(AppFont.title)
                HStack(spacing: AppSpacing.xxl) {
                    VStack(alignment: .leading) {
                        Text("Bobot")
                            .font(AppFont.mediumSubheadline)
                        Text("\(evaluationNumber(profile.bodyWeightKilograms)) kg")
                            .font(AppFont.callout)
                    }
                    
                    Rectangle()
                        .fill(AppColor.Primitive.Neutral.shade200)
                        .frame(width: 2, height: 41)
                    
                    VStack(alignment: .leading) {
                        Text("Target ADG")
                            .font(AppFont.mediumSubheadline)
                        Text("\(evaluationNumber(profile.targetDailyWeightGainKilograms)) kg/hari")
                            .font(AppFont.callout)
                    }
                }
            }
            
            Spacer()
            
            Image("Image/cowImage")
                .resizable()
                .scaledToFit()
                .frame(width: 94)
        }
        .evaluationCard()
    }

    private var profileSummary: String {
        let weight = "Bobot \(evaluationNumber(profile.bodyWeightKilograms)) kg"
        guard profile.usesWeightGainTarget else { return weight }
        return weight + " • Target ADG \(evaluationNumber(profile.targetDailyWeightGainKilograms)) kg/hari"
    }

}

#if DEBUG
#Preview {
    RationProfileCard(profile: RationEvaluationPreviewData.result.profile, cattleName: "Sapi #00001")
        .padding(AppSpacing.md)
}
#endif
