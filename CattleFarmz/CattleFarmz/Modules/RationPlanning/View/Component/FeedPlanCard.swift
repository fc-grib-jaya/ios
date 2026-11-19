import SwiftUI

struct FeedPlanCard: View {
    let entry: FeedHomeEntry
    let onOpen: () -> Void

    var body: some View {
        if entry.adg != nil {
            Button(action: onOpen) {
                cardContent
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                Group {
                    if let data = entry.photo, let image = UIImage(data: data) {
                        Image(uiImage: image).resizable().scaledToFill()
                    } else {
                        Image(systemName: "photo").foregroundStyle(AppColor.Text.secondary)
                    }
                }
                .frame(width: AppSpacing.massive, height: AppSpacing.massive)
                .background(AppColor.Surface.inset)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(entry.name).font(AppFont.title)
                    HStack(spacing: 0){
                        Text(entry.breed)
                            .font(AppFont.subheadlineBase)
                        Text(" • ")
                            .font(.subheadline).bold()
                        Text(entry.gender)
                            .font(AppFont.subheadlineBase)
                        Text(" • ")
                            .font(.subheadline).bold()
                        Text("\(entry.ageInMonths) bulan")
                            .font(AppFont.subheadlineBase)
                    }
                }
                Spacer()
                if entry.updated != nil {
                    Image(systemName: "chevron.right").foregroundStyle(AppColor.Text.secondary)
                }
            }
            Divider()
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    if entry.adg != nil {
                        Text("Target kenaikan bobot").font(AppFont.mediumBody)
                    }
                    Text(entry.updated.map { date in
                        let locale = Locale(identifier: "id_ID")
                        let tanggal = date.formatted(.dateTime.locale(locale).day().month(.wide).year())
                        let jam = date.formatted(.dateTime.locale(locale).hour().minute())
                        return "Diperbarui: \(tanggal), \(jam)"
                    } ?? "")
                        .font(AppFont.caption).foregroundStyle(AppColor.Text.secondary)
                }
                Spacer()
                if let adg = entry.adg {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xxs) {
                        Text(evaluationNumber(adg)).font(AppFont.largeTitle)
                        Text("kg / hari").font(AppFont.body)
                    }
                } else {
                    Button(action: onOpen) {
                        Text("Atur Pakan").font(AppFont.headline)
                    }
                    .appButtonStyle(.primary)
                }
            }
        }
        .evaluationCard()
    }

    #if DEBUG
    static let previewEntries = [
        FeedHomeEntry(
            id: UUID(),
            name: "Sapi #00001",
            breed: "Limousin",
            gender: "jantan",
            ageInMonths: 12,
            photo: nil,
            updated: .now,
            adg: 1.2
        ),
        FeedHomeEntry(
            id: UUID(),
            name: "Sapi #00002",
            breed: "Bali",
            gender: "jantan",
            ageInMonths: 12,
            photo: nil,
            updated: nil,
            adg: nil
        )
    ]
    #endif
}

#if DEBUG
#Preview {
    VStack {
        ForEach(FeedPlanCard.previewEntries) { entry in FeedPlanCard(entry: entry, onOpen: {}) }
    }.padding()
}
#endif
