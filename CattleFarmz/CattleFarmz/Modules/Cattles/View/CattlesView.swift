//
//  CattlesView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

/// Cattles screen: a scrollable list of cattle.
struct CattlesView: View {
    @State private var viewModel: CattlesViewModel
    private let onCardTap: (String) -> Void

    init(
        viewModel: CattlesViewModel,
        onCardTap: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCardTap = onCardTap
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(viewModel.filteredItems) { cattle in
                let bodyWeight = cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)
                let image = cattle.cattleImage.flatMap { UIImage(data: $0) }
                Button {
                    onCardTap(cattle.id.uuidString)
                } label: {
                    CattleCard(
                        cattleImage: image ?? UIImage(named: "CattlePlaceholder") ?? UIImage(),
                        name: cattle.name,
                        breed: cattle.breed,
                        gender: cattle.gender,
                        age: cattle.currentAge,
                        weight: bodyWeight,
                        updated: cattle.dateAcquired
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .font(AppFont.body)
        .foregroundStyle(AppColor.Text.primary)
        .padding(.horizontal, AppSpacing.md)
        .task { await viewModel.load() }
    }
}

#Preview {
    CattlesView(
        viewModel: CattlesViewModel(
            repository: MockCattleRepository(),
            calculation: WeightCalculator(),
            toast: ToastManager()
        ),
        onCardTap: { _ in }
    )
}
