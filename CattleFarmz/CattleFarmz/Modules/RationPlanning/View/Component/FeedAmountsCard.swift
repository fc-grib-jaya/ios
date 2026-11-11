//
//  FeedAmountsCard.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 10/11/26.
//

import SwiftUI
struct FeedAmountsCard: View {
    var rationVM: RationPlanningViewModel
    var onTap: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !rationVM.selectedFeeds.isEmpty {
                ForEach(rationVM.selectedFeeds) { feed in
                    HStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(feed.name)
                                .font(AppFont.headline)
                            
                            Text(feed.category.rawValue)
                            // MARK: belum make AppFont
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: AppSpacing.xs) {
                            TextField(
                                "0",
                                text: Binding(
                                    get: {rationVM.amountText(for: feed)},
                                    set: {newValue in rationVM.updateAmount(newValue, for: feed)}
                                )
                            )
                            .font(AppFont.body)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            
                            Text("kg")
                            // MARK: belum pake AppFont
                                .font(.footnote)
                                .foregroundStyle(AppColor.Text.secondary)
                        }
                        .padding(AppSpacing.xs)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Button {
                            rationVM.removeFeed(feed)
                        } label: {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Hapus \(feed.name)")
                    }
                    .padding(AppSpacing.xs)
                    
                    Divider()
                }
            }
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Button {
                    onTap()
                } label: {
                    Label("Tambah bahan pakan yang dimiliki", systemImage: "plus")
                    // MARK: belum make AppFont
                        .font(.subheadline.bold())
                        .foregroundStyle(AppColor.Primitive.Primary.shade500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.md)
        .background(
            // MARK: belum make AppRadius
            RoundedRectangle(cornerRadius: 16).fill(
                AppColor.Card.background)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}


//#Preview {
//    FeedAmountsCard(
//        rationVM: RationPlanningViewModel(
//            feedProvider: {
//                let text = try BundledFeedCSVReader().read()
//                let ingredients = try FeedCSVParser().parse(text)
//
//                return Array(ingredients.prefix(3))
//            },
//            calculator: ManualRationCalculator { profile in
//                CattleNutritionDefaults.requirements(
//                    for: profile.productionType,
//                    stage: profile.stage
//                )
//            }
//        ),
//        onTap: {}
//    )
//}

#Preview {
    let viewModel = RationPlanningViewModel(
        feedProvider: {
            let text = try BundledFeedCSVReader().read()
            return try FeedCSVParser().parse(text)
        },
        calculator: ManualRationCalculator { profile in
            CattleNutritionDefaults.requirements(
                for: profile.productionType,
                stage: profile.stage
            )
        }
    )
    
    FeedAmountsCard(
        rationVM: viewModel,
        onTap: {}
    )
    .task {
        viewModel.load()
        
        for feed in viewModel.feeds.prefix(2) {
            if !viewModel.selectedFeedIDs.contains(feed.id) {
                viewModel.toggleFeed(feed)
            }
            
            viewModel.updateAmount("10", for: feed)
        }
    }
}
