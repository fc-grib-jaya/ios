//
//  CattlesCarcassView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 07/11/26.
//

import SwiftUI

struct CattlesCarcassView: View {
    @State private var viewModel: CattlesViewModel
    private let cattleID: UUID?
    @State private var cattle: Cattle?

    init(cattleID: String, viewModel: CattlesViewModel) {
        self.cattleID = UUID(uuidString: cattleID)
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let cattle {
                let bodyWeight =
                    cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    
                    if let bodyWeight {
                        Text("Berat Sapi: \(bodyWeight, specifier: "%.2f") kg")

                        if let carcassWeight = viewModel.carcassWeight(
                            for: cattle,
                            bodyWeight: bodyWeight
                        ) {
                            Text(
                                "Berat Karkas: \(carcassWeight, specifier: "%.2f") kg"
                            )
                        }

                        if let meatWeight = viewModel.meatWeight(
                            for: cattle,
                            bodyWeight: bodyWeight
                        ) {
                            Text(
                                "Berat Daging Bersih: \(meatWeight, specifier: "%.2f") kg"
                            )
                            .padding(.bottom, AppSpacing.sm)
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
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.primary)
                .padding(AppSpacing.md)
            } else {
                ContentUnavailableView(
                    "Sapi Tidak Ditemukan",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Data sapi tidak tersedia.")
                )
            }
        }
        .navigationTitle(cattle?.name ?? "Detail Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let cattleID else { return }

            await viewModel.load()
            cattle = viewModel.items.first { $0.id == cattleID }
        }
    }
}

#Preview {
    NavigationStack {
        CattlesCarcassView(
            cattleID: Cattle.samples[0].id.uuidString,
            viewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            )
        )
    }
}
