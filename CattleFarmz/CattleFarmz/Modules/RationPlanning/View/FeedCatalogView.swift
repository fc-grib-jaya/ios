//
//  FeedCatalogView.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 10/11/26.
//

import SwiftUI

struct FeedCatalogView: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var rationVM: RationPlanningViewModel
    
    @State private var nutritionFeed: FeedIngredient?
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Pilih bahan pakan")
                // MARK: belum make AppFont
                    .font(.title.bold())
                
                Text("Pilih bahan pakan yang tersedia di kandang")
                // MARK: belum make AppFont
                    .font(.subheadline)
            }
            
            searchField
            
            categoryFilters
            
            HStack {
                Text("Daftar bahan")
                // MARK: belum make AppFont
                    .font(.subheadline.bold())
                
                Spacer()
                
                Text(
                    "\(rationVM.filteredFeeds.count) bahan"
                    + " · \(rationVM.selectedFeedIDs.count) terpilih"
                )
                .font(.subheadline)
                .foregroundStyle(AppColor.Text.secondary)
            }
            
            ScrollView {
                LazyVStack(spacing: AppSpacing.xs) {
                    ForEach(rationVM.filteredFeeds) { feed in
                        feedRow(feed)
                    }
                    
                    if rationVM.filteredFeeds.isEmpty {
                        Text("Bahan pakan tidak ditemukan.")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.xl)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
        .background(AppColor.Surface.card)
        .navigationTitle("Susunan Pakan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button{
                dismiss()
            } label: {
                Text("Tambah pakan")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.Button.Primary.foreground)
            .background(
                AppColor.Button.Primary.background,
                in: Capsule()
            )
            .padding(AppSpacing.md)
            .background(AppColor.Surface.card)
        }
        .task {
            rationVM.load()
        }
        .sheet(item: $nutritionFeed) { feed in
            NavigationStack {
                NutritionInfoView(nutritionFeed: feed)
                    .background(AppColor.Primitive.Base.white)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var searchField: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.Text.secondary)
            
            TextField("Cari bahan pakan", text: $rationVM.searchText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(minHeight: 48)
        .glassEffect(
            .regular.interactive(),
            in: Capsule()
        )
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                categoryButton("Semua", category: nil)
                
                ForEach(FeedCategory.allCases) { category in
                    categoryButton(
                        categoryTitle(category),
                        category: category
                    )
                }
            }
        }
    }
    
    private func categoryButton(
        _ title: String,
        category: FeedCategory?
    ) -> some View {
        let isSelected = rationVM.selectedCategory == category
        
        return Button {
            rationVM.selectedCategory = category
        } label: {
            Text(title)
                .font(isSelected ? .subheadline.bold() : .subheadline)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .foregroundStyle(
                    isSelected
                    ? AppColor.Primitive.Primary.shade700
                    : AppColor.Primitive.Neutral.shade400
                )
                .background {
                    Capsule().fill(
                        (isSelected
                         ? AppColor.Primitive.Primary.shade200
                         : AppColor.Primitive.Primary.shade50)
                        .shadow(.inner(color: .white.opacity(0.75), radius: 3, x: 0, y: 1))
                    )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func feedRow(_ feed: FeedIngredient) -> some View {
        let isSelected = rationVM.selectedFeedIDs.contains(feed.id)
        
        return HStack(spacing: AppSpacing.sm) {
            Button {
                rationVM.toggleFeed(feed)
            } label: {
                HStack(spacing: AppSpacing.md) {
                    Image(
                        systemName:isSelected ? "checkmark.square.fill" : "square"
                    )
                        .foregroundStyle(AppColor.Primitive.Primary.shade500)
                    
                    VStack(
                        alignment: .leading,
                        spacing: AppSpacing.xs
                    ) {
                        Text(feed.name)
                            .font(AppFont.headline)
                            .foregroundStyle(AppColor.Primitive.Primary.shade700)
                        
                        Text(categoryTitle(feed.category))
                        // MARK: belum make AppFont
                            .font(.subheadline)
                            .foregroundStyle(AppColor.Primitive.Primary.shade700)
                    }
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            
            Button {
                nutritionFeed = feed
            } label: {
                VStack {
                    Image(systemName: "info.circle")
            
                    Text("Nutrisi")
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.Primitive.Neutral.shade400)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Lihat nutrisi \(feed.name)")
        }
        .foregroundStyle(
            isSelected
            ? AppColor.Badge.Active.foreground
            : AppColor.Text.primary
        )
        .padding(AppSpacing.md)
        .background(
            // MARK: belum make AppRadius
            RoundedRectangle(cornerRadius: 16).fill(
                (isSelected ? AppColor.Primitive.Primary.shade200 : AppColor.Primitive.Neutral.shade50)
                    .shadow(.inner(color: .white.opacity(0.75), radius: 3, x: 0, y: 1))
            )
        )
    }
    
    private func categoryTitle(_ category: FeedCategory) -> String {
        switch category {
        case .forage: "Hijauan"
        case .concentrate: "Konsentrat"
        case .mineral: "Mineral"
        }
    }
    
    private func nutritionDescription(
        for feed: FeedIngredient
    ) -> String {
        let nutrients = feed.nutrients
        
        return [
            feed.name,
            "Protein kasar: \(formatted(nutrients.crudeProteinPercent, unit: "%"))",
            "TDN: \(formatted(nutrients.totalDigestibleNutrientsPercent, unit: "%"))",
            "Kalsium: \(formatted(nutrients.calciumPercent, unit: "%"))",
            "Fosfor: \(formatted(nutrients.phosphorusPercent, unit: "%"))",
            "Magnesium: \(formatted(nutrients.magnesiumPercent, unit: "%"))",
            "Besi: \(formatted(nutrients.ironPPM, unit: "ppm"))",
            "Tembaga: \(formatted(nutrients.copperPPM, unit: "ppm"))",
            "Seng: \(formatted(nutrients.zincPPM, unit: "ppm"))"
        ]
            .joined(separator: "\n")
    }
    
    private func formatted(
        _ value: Double?,
        unit: String
    ) -> String {
        guard let value else {
            return "Tidak tersedia"
        }
        
        return value.formatted(
            .number.precision(.fractionLength(0...2))
        ) + " " + unit
    }
}

#Preview {
    NavigationStack{
        FeedCatalogView(
            rationVM: RationPlanningViewModel(
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
        )
    }
}
