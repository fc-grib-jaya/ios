import SwiftUI

struct FeedPlanCard: View {
    let entry: FeedHomeEntry
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
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
                        Text(entry.details).font(AppFont.body)
                    }
                    Spacer()
                    if entry.updated != nil {
                        Image(systemName: "chevron.right").foregroundStyle(AppColor.Text.secondary)
                    }
                }
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Target ADG").font(AppFont.mediumBody)
                        Text(entry.updated.map { "Update: " + $0.formatted(.dateTime.locale(Locale(identifier: "id_ID")).day().month(.wide).year().hour().minute()) } ?? "Update: Belum ada update")
                            .font(AppFont.caption).foregroundStyle(AppColor.Text.secondary)
                    }
                    Spacer()
                    if let adg = entry.adg {
                        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xxs) {
                            Text(evaluationNumber(adg)).font(AppFont.largeTitle)
                            Text("kg / hari").font(AppFont.body)
                        }
                    } else {
                        Text("Atur Pakan").font(AppFont.headline)
                            .padding(.horizontal, AppSpacing.lg).padding(.vertical, AppSpacing.sm)
                            .foregroundStyle(AppColor.Button.Primary.foreground)
                            .background(AppColor.Button.Primary.background, in: Capsule())
                    }
                }
            }
            .evaluationCard()
        }
        .buttonStyle(.plain)
    }

    #if DEBUG
    static let previewEntries = [
        FeedHomeEntry(id: UUID(), name: "Sapi #00001", details: "Simmental · Jantan · 12 bulan", photo: nil, updated: .now, adg: 1.2),
        FeedHomeEntry(id: UUID(), name: "Sapi #00002", details: "Bali · Betina · 10 bulan", photo: nil, updated: nil, adg: nil)
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
