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
    
    @FocusState.Binding var focusedFeedID: FeedIngredient.ID?
    @State private var amountDrafts: [FeedIngredient.ID: String] = [:]
    
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
                                    get: {
                                        amountDrafts[feed.id]
                                            ?? rationVM.amountText(for: feed)
                                    },
                                    set: {
                                        amountDrafts[feed.id] = $0
                                    }
                                )
                            )
                            .font(AppFont.body)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedFeedID, equals: feed.id)
                            .onChange(of: amountDrafts[feed.id]) { _, newValue in
                                guard let newValue else { return }

                                let limited = rationVM.limitedAmountText(newValue)

                                if newValue != limited {
                                    amountDrafts[feed.id] = limited
                                }

                                rationVM.updateAmount(limited, for: feed)
                            }
                            
                            Text("kg")
                            // MARK: belum pake AppFont
                                .font(.footnote)
                                .foregroundStyle(AppColor.Text.secondary)
                        }
                        .padding(AppSpacing.xs)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    borderColor(for: feed),
                                    lineWidth: 1
                                )
                        )
                        .fixedSize(horizontal: true, vertical: false)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedFeedID = feed.id
                        }
                        
                        Button {
                            if focusedFeedID == feed.id {
                                focusedFeedID = nil
                            }
                            rationVM.removeFeed(feed)
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(AppColor.Primitive.Neutral.shade300)
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
                    focusedFeedID = nil
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
        .onChange(of: focusedFeedID) { _, newID in
            guard let newID else { return }
            rationVM.clearAmountWarning(for: newID)
        }
        .gesture(
            TapGesture()
                .onEnded {
                    focusedFeedID = nil
                },
            including: .gesture
        )
    }
    
    private func borderColor(for feed: FeedIngredient) -> Color {
        if focusedFeedID == feed.id {
            return AppColor.Primitive.Primary.shade400
        }

        if rationVM.hasMissingAmount(for: feed) {
            return AppColor.Primitive.Warning.warning
        }

        return Color(.systemGray4)
    }
}

#if DEBUG
private struct FeedAmountsCardPreview: View {
    let viewModel: RationPlanningViewModel
    @FocusState private var focusedFeedID: FeedIngredient.ID?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            FeedAmountsCard(
                rationVM: viewModel,
                onTap: {},
                focusedFeedID: $focusedFeedID
            )
            Button("Evaluasi pakan") {
                focusedFeedID = nil
                viewModel.calculate()
            }
            .appButtonStyle(.primary)
        }
        .padding(AppSpacing.md)
    }
}

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
    
    FeedAmountsCardPreview(viewModel: viewModel)
    .task {
        viewModel.load()
        
        for feed in viewModel.feeds.prefix(2) {
            if !viewModel.selectedFeedIDs.contains(feed.id) {
                viewModel.toggleFeed(feed)
            }
            
        }
    }
}

#endif
