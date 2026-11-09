//
//  CattlesDetailView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

struct CattlesDetailView: View {
    @State private var viewModel: CattlesViewModel
    private let cattleID: UUID?
    private let onEditTap: (Cattle, @escaping (CattleEditValues) -> String?) -> Void

    init(
        cattleID: String,
        viewModel: CattlesViewModel,
        onEditTap: @escaping (Cattle, @escaping (CattleEditValues) -> String?) -> Void
    ) {
        self.cattleID = UUID(uuidString: cattleID)
        _viewModel = State(initialValue: viewModel)
        self.onEditTap = onEditTap
    }

    /// Derived from the ViewModel so edits made through the shared instance
    /// are reflected here without manual syncing.
    private var currentCattle: Cattle? {
        viewModel.items.first { $0.id == cattleID }
    }

    var body: some View {
        ScrollView {
            if let cattle = currentCattle {
                let breakdown = viewModel.weightBreakdown(for: cattle)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    if let imageData = cattle.cattleImage,
                       let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180, alignment: .top)
                            .clipped()
                            .cornerRadius(AppSpacing.Card.compact)
                    } else {
                        Image("CattlePlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180, alignment: .top)
                            .clipped()
                            .cornerRadius(AppSpacing.Card.compact)
                    }

                    CattlesDetailCard(
                        name: cattle.name,
                        breed: cattle.breed,
                        gender: cattle.gender,
                        age: cattle.recordedAge,
                        weight: breakdown.bodyWeight,
                        updatedDate: cattle.dateAcquired,
                        chestGirth: cattle.chestGirth,
                        bodyLength: cattle.bodyLength,
                        notes: cattle.notes
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        weightRow(title: "Berat Karkas", value: breakdown.carcass)
                        weightRow(title: "Berat Non-Karkas", value: breakdown.nonCarcass)
                        weightRow(title: "Berat Daging", value: breakdown.meat)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.Card.background)
                    .cornerRadius(AppSpacing.Card.compact)
                    .shadow(radius: 10, x: 0, y: 2)

                    if !carcassSankeyItems(breakdown).isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Persentase Karkas")
                                .font(AppFont.title)
                                .foregroundStyle(AppColor.Text.primary)

                            // Tight layer spacing so all three levels fit
                            // the card width. Tall enough that every
                            // last-level row keeps its minimum thickness
                            // (13 labeled rows need more than 360pt).
                            HorizontalSankeyChart(
                                data: carcassSankeyItems(breakdown),
                                levelSpacing: 84
                            )
                            .frame(height: 520)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.Card.background)
                        .cornerRadius(AppSpacing.Card.compact)
                        .shadow(radius: 10, x: 0, y: 2)
                    }

                    Text("Terakhir disimpan: \(formatDate(cattle.dateAcquired))")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade500)
                }
                .padding(AppSpacing.md)
            } else {
                ContentUnavailableView(
                    "Sapi Tidak Ditemukan",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Data sapi tidak tersedia.")
                )
            }
        }
        .navigationTitle(currentCattle?.name ?? "Detail Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let cattle = currentCattle {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        onEditTap(cattle) { values in
                            viewModel.editCattle(values, for: cattle)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func weightRow(title: String, value: Double?) -> some View {
        HStack {
            Text(title)
                .font(AppFont.mediumBody)
                .foregroundStyle(AppColor.Text.primary)
            Spacer()
            Text(value.map { String(format: "%.2f kg", $0) } ?? "Belum diukur")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.primary)
        }
    }

    /// Builds the carcass-percentage Sankey tree, all as percentages of the
    /// live weight:
    /// level 1 total weight -> level 2 carcass (upper) and non-carcass (lower)
    /// -> level 3 meat & bone under carcass, one leaf per non-carcass part
    /// under non-carcass.
    /// Leaf values must be positive, so empty/zero slices are omitted;
    /// returns an empty array when nothing can be shown.
    private func carcassSankeyItems(
        _ breakdown: CattleWeightBreakdown
    ) -> [SankeyItem] {
        guard let bodyWeight = breakdown.bodyWeight, bodyWeight > 0 else {
            return []
        }

        func percent(_ value: Double) -> Double {
            value / bodyWeight * 100
        }

        let meatPercent = breakdown.meat.map(percent)

        var carcassChildren: [SankeyItem] = []
        if let meatPercent {
            carcassChildren.append(
                SankeyItem(
                    id: "meat",
                    title: "Daging",
                    value: meatPercent,
                    color: AppColor.Primitive.Primary.shade600,
                    order: 0 // layer 3: 0.0
                )
            )
        }
        if let carcass = breakdown.carcass, let meatPercent {
            let bonePercent = percent(carcass) - meatPercent
            if bonePercent > 0 {
                carcassChildren.append(
                    SankeyItem(
                        id: "bone",
                        title: "Tulang",
                        value: bonePercent,
                        color: AppColor.Button.Secondary.pressedBackground,
                        order: 1 // layer 3: 0.1
                    )
                )
            }
        }

        // Layer 3 ordering: meat 0.0, bone 0.1, non-carcass parts from 2.
        let nonCarcassChildren: [SankeyItem] = NonCarcassPart.allCases
            .enumerated()
            .compactMap { index, part in
                guard let weight = breakdown.nonCarcassParts[part],
                      percent(weight) > 0 else {
                    return nil
                }
                return SankeyItem(
                    id: "non-\(part.rawValue)",
                    title: part.displayName,
                    value: percent(weight),
                    color: AppColor.Button.Secondary.pressedBackground,
                    order: 2 + index
                )
            }

        var children: [SankeyItem] = []
        if let carcass = breakdown.carcass {
            if carcassChildren.isEmpty {
                children.append(
                    SankeyItem(
                        id: "carcass",
                        title: "Karkas",
                        value: percent(carcass),
                        color: AppColor.Button.Secondary.foreground,
                        order: 0
                    )
                )
            } else {
                children.append(
                    SankeyItem(
                        id: "carcass",
                        title: "Karkas",
                        color: AppColor.Button.Secondary.foreground,
                        order: 0,
                        children: carcassChildren
                    )
                )
            }
        }
        if let nonCarcass = breakdown.nonCarcass {
            if nonCarcassChildren.isEmpty {
                children.append(
                    SankeyItem(
                        id: "nonCarcass",
                        title: "Non Karkas",
                        value: percent(nonCarcass),
                        color: AppColor.Button.Secondary.pressedBackground,
                        order: 1
                    )
                )
            } else {
                children.append(
                    SankeyItem(
                        id: "nonCarcass",
                        title: "Non Karkas",
                        color: AppColor.Button.Secondary.pressedBackground,
                        order: 1,
                        children: nonCarcassChildren
                    )
                )
            }
        }

        guard !children.isEmpty else { return [] }

        return [
            SankeyItem(
                id: "body",
                title: "Bobot",
                color: AppColor.Primitive.Secondary.shade600,
                order: 0,
                children: children
            )
        ]
    }
}

#Preview {
    NavigationStack {
        CattlesDetailView(
            cattleID: Cattle.samples[1].id.uuidString,
            viewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            ),
            onEditTap: { _, _ in }
        )
    }
}
