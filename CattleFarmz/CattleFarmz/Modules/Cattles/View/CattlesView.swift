//
//  CattlesView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

/// Cattles screen: a scrollable list of cattle.
struct CattlesView: View {
    @State private var viewModel: CattlesViewModel
    private let selectedBreed: Set<String>
    private let selectedGender: Set<String>
    private let selectedAgeRange: Set<String>
    private let sortAscending: Bool
    private let onCardTap: (String) -> Void

    init(
        viewModel: CattlesViewModel,
        selectedBreed: Set<String> = [],
        selectedGender: Set<String> = [],
        selectedAgeRange: Set<String> = [],
        sortAscending: Bool = false,
        onCardTap: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.selectedBreed = selectedBreed
        self.selectedGender = selectedGender
        self.selectedAgeRange = selectedAgeRange
        self.sortAscending = sortAscending
        self.onCardTap = onCardTap
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(viewModel.filteredItems(
                selectedBreed: selectedBreed,
                selectedGender: selectedGender,
                selectedAgeRange: selectedAgeRange,
                sortAscending: sortAscending
            )) { cattle in
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
                        updated: .now
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .font(AppFont.body)
        .foregroundStyle(AppColor.Text.primary)
        .padding(AppSpacing.md)
        .task { await viewModel.load() }
    }
}

#Preview {
    CattlesView(
        viewModel: CattlesViewModel(
            repository: MockCattleRepository(),
            calculation: WeightCalculator()
        ),
        onCardTap: { _ in }
    )
}
