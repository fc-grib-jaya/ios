//
//  CattlesDetailView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct CattlesDetailView: View {
    @State private var viewModel: CattlesViewModel

    init(viewModel: CattlesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.medium) {
                ForEach(viewModel.items) { cattle in
                    let bodyWeight = cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)
                    VStack(alignment: .leading) {
                        Text(cattle.name)
                        Text("\(cattle.currentAge) bulan")
                        if let imageData = cattle.cattleImage,
                           let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "photo")
                                .font(AppFont.title)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        
                        if let bodyWeight {
                            Text("Berat Sapi: \(bodyWeight, specifier: "%.2f") kg")

                            if let carcassWeight = viewModel.carcassWeight(for: cattle, bodyWeight: bodyWeight) {
                                Text("Berat Karkas: \(carcassWeight, specifier: "%.2f") kg")
                            }

                            if let meatWeight = viewModel.meatWeight(for: cattle, bodyWeight: bodyWeight) {
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
                    .padding(.bottom, AppSpacing.medium)
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
    CattlesDetailView(viewModel: CattlesViewModel(repository: MockCattleRepository(), calculation: WeightCalculator()))
}
