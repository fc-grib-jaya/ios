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
            LazyVStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(viewModel.items) { cattle in
                    let bodyWeight = cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)
                    
                    VStack(alignment: .leading) {
                        Text(cattle.name)
                        
                        if let bodyWeight {
                            Text("Berat Sapi: \(bodyWeight, specifier: "%.2f") kg")

                            if let carcassWeight = viewModel.carcassWeight(for: cattle, bodyWeight: bodyWeight) {
                                Text("Berat Karkas: \(carcassWeight, specifier: "%.2f") kg")
                            }

                            if let meatWeight = viewModel.meatWeight(for: cattle, bodyWeight: bodyWeight) {
                                Text("Berat Daging Bersih: \(meatWeight, specifier: "%.2f") kg")
                                    .padding(.bottom, AppSpacing.xs)
                            }

                            ForEach(NonCarcassPart.allCases, id: \.self) { part in
                                if let partWeight = viewModel.nonCarcassWeight(
                                    for: cattle,
                                    bodyWeight: bodyWeight,
                                    part: part
                                ) {
                                    HStack {
                                        Text(part.displayName)
                                        Spacer()
                                        Text("\(partWeight, specifier: "%.2f") kg")
                                    }
                                }
                            }
                            
                        } else {
                            Text("Not Measured")
                        }
                    }
                    .padding(.bottom, AppSpacing.md)
                }
            }
            .font(AppFont.body)
            .foregroundStyle(AppColor.Text.primary)
            .padding(AppSpacing.md)
        }
        .task { await viewModel.load() }
    }
}

#Preview {
    CattlesView(viewModel: CattlesViewModel(repository: MockCattleRepository(), calculation: WeightCalculator()))
}
