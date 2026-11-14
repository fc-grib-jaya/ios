import SwiftUI

struct FeedHomeEntry: Identifiable {
    let id: UUID
    let name: String
    let details: String
    let photo: Data?
    let updated: Date?
    let adg: Double?
}

struct FeedHomeView: View {
    let entries: [FeedHomeEntry]
    let onOpen: (UUID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(entries.filter { $0.updated != nil }.sorted { ($0.updated ?? .distantPast) > ($1.updated ?? .distantPast) }) { entry in
                    FeedPlanCard(entry: entry) { onOpen(entry.id) }
                }
                let pending = entries.filter { $0.updated == nil }
                if !pending.isEmpty {
                    Divider()
                    Text("Sapi yang belum dihitung nutrisinya").font(AppFont.headline)
                    ForEach(pending) { entry in
                        FeedPlanCard(entry: entry) { onOpen(entry.id) }
                    }
                }
                if entries.isEmpty {
                    ContentUnavailableView("Belum ada sapi", systemImage: "leaf", description: Text("Tambahkan sapi di Beranda untuk mengatur pakan."))
                }
            }
            .padding(AppSpacing.Screen.compact)
        }
        .background(LinearGradient(colors: [AppColor.Primitive.Secondary.shade50, AppColor.Surface.inset],
                                   startPoint: .top, endPoint: .center).ignoresSafeArea())
        .navigationTitle("Pakan")
        .navigationBarTitleDisplayMode(.large)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        FeedHomeView(entries: FeedPlanCard.previewEntries, onOpen: { _ in })
    }
}
#endif
