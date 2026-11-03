//
//  CattlesView.swift
//  CattleFarmz
//

import SwiftUI

/// Cattles screen: a scrollable list of cattle.
struct CattlesView: View {
    @State private var viewModel: CattlesViewModel

    init(viewModel: CattlesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.medium) {
                ForEach(viewModel.items) { cattle in
                    Text(cattle.name)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(viewModel.cattleWeight(for: cattle), specifier: "%.2f") kg")
                }
            }
            .padding(AppSpacing.medium)
        }
        .task { await viewModel.load() }
    }
}

#Preview {
    CattlesView(viewModel: CattlesViewModel(repository: MockCattleRepository(), calculation: WeightCalculator()))
}
