//
//  CattlesDetailView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

struct CattlesDetailView: View {
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
                let bodyWeight = cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)

                LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text(cattle.name)
                    Text("\(cattle.currentAge) bulan")

                    if let imageData = cattle.cattleImage,
                       let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("CattlePlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 250)
                            .clipped()
                    }

                    if let bodyWeight {
                        Text("Berat Sapi: \(bodyWeight, specifier: "%.2f") kg")

                        if let carcassWeight = viewModel.carcassWeight(
                            for: cattle,
                            bodyWeight: bodyWeight
                        ) {
                            Text("Berat Karkas: \(carcassWeight, specifier: "%.2f") kg")
                        }

                        if let meatWeight = viewModel.meatWeight(
                            for: cattle,
                            bodyWeight: bodyWeight
                        ) {
                            Text("Berat Daging Bersih: \(meatWeight, specifier: "%.2f") kg")
                                .padding(.bottom, AppSpacing.small)
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
                .foregroundStyle(AppColor.textPrimary)
                .padding(AppSpacing.medium)
            } else {
                ContentUnavailableView(
                    "Sapi Tidak Ditemukan",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Data sapi tidak tersedia.")
                )
            }
        }
        .navigationTitle(cattle?.name ?? "Detail Sapi")
        .task {
            guard let cattleID else { return }

            await viewModel.load()
            cattle = viewModel.items.first { $0.id == cattleID }
        }
    }
}

#Preview {
    CattlesDetailView(
        cattleID: Cattle.samples[0].id.uuidString,
        viewModel: CattlesViewModel(
            repository: MockCattleRepository(),
            calculation: WeightCalculator()
        )
    )
}
