//
//  CattlesView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

/// Cattles screen: a scrollable list of cattle.
struct CattlesView: View {
    @State private var viewModel: CattlesViewModel

    init(viewModel: CattlesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                ForEach(viewModel.items) { cattle in
                    let bodyWeight =
                        cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)
                    let image =
                        UIImage(data: cattle.cattleImage ?? Data()) ?? UIImage(
                            systemName: "photo"
                        )!

                    CattleCard(
                        cattleImage: image,
                        name: cattle.name,
                        breed: cattle.breed,
                        gender: cattle.gender,
                        age: cattle.currentAge,
                        weight: bodyWeight,
                        updated: .now
                    )
                }
            }
            .font(AppFont.body)
            .foregroundStyle(AppColor.textPrimary)
            .padding(AppSpacing.medium)
        }
        .task { await viewModel.load() }
    }
}

#Preview {
    CattlesView(
        viewModel: CattlesViewModel(
            repository: MockCattleRepository(),
            calculation: WeightCalculator()
        )
    )
}
