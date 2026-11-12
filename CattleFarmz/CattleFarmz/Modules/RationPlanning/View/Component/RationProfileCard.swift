import SwiftUI

struct RationProfileCard: View {
    let profile: CattleRationProfile
    let cattleName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(cattleName ?? "Profil sapi").font(AppFont.title)
            Text(profileSummary)
        }
        .evaluationCard()
    }

    private var profileSummary: String {
        let weight = "Bobot \(evaluationNumber(profile.bodyWeightKilograms)) kg"
        guard profile.usesWeightGainTarget else { return weight }
        return weight + " · Target ADG \(evaluationNumber(profile.targetDailyWeightGainKilograms)) kg/hari"
    }

}

#if DEBUG
#Preview {
    RationProfileCard(profile: RationEvaluationPreviewData.result.profile, cattleName: "Sapi #00001")
        .padding(AppSpacing.md)
}
#endif
