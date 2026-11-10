//
//  CattlesDetailView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

struct CattlesDetailView: View {
    @State private var viewModel: CattlesViewModel
    @State private var detailView = 0
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
        
        let primary = UIColor(AppColor.Primitive.Primary.shade400)
        let white = UIColor(AppColor.Primitive.Base.white)
        let segmented = UISegmentedControl.appearance()
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)

        segmented.selectedSegmentTintColor = primary
        segmented.backgroundColor = primary.withAlphaComponent(0.12)

        segmented.setTitleTextAttributes(
            [.foregroundColor: primary, .font: font],
            for: .normal
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: white, .font: font],
            for: .selected
        )
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
                    
                    Picker("Options", selection: $detailView) {
                        Text("Karkas").tag(0)
                        Text("Pakan").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.large)
                    .padding(.vertical, AppSpacing.xs)
                    
                    switch detailView {
                    case 0:
                        CarcassView(breakdown: breakdown)
                    case 1:
                        NoRationCard()
                    default:
                        EmptyView()
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
