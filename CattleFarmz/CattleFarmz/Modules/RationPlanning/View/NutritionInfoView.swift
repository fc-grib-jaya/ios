//
//  NutritionInfoView.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 11/11/26.
//

import SwiftUI

struct NutritionInfoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var nutritionFeed: FeedIngredient?
    
    var body: some View {
        if let feed = nutritionFeed {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(feed.name)
                        // MARK: belum make AppFont
                            .font(.title.bold())
                        Text(feed.category.rawValue)
                        // MARK: belum make AppFont
                            .font(.subheadline)
                    }
                    
                    Text("Kandungan nutrisi")
                    // MARK: belum make AppFont
                        .font(.subheadline.bold())
                    nutrientCard(feed.nutrients)
                }
                .padding(AppSpacing.md)
            }
            .navigationTitle("Nutrisi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            
        } else {
            Text("Belum ada pakan dipilih")
                .padding(AppSpacing.md)
                .navigationTitle("Nutrisi")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        Button{
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
        }
    }
    
    private func nutrientCard(
        _ nutrients: NutrientContent
    ) -> some View {
        VStack(spacing: 0) {
            nutrientRow(
                "Protein kasar",
                value: nutrients.crudeProteinPercent,
                unit: "%"
            )
            Divider()
            
            nutrientRow(
                "TDN",
                value: nutrients.totalDigestibleNutrientsPercent,
                unit: "%"
            )
            Divider()
            
            nutrientRow(
                "Kalsium",
                value: nutrients.calciumPercent,
                unit: "%"
            )
            Divider()
            
            nutrientRow(
                "Fosfor",
                value: nutrients.phosphorusPercent,
                unit: "%"
            )
            Divider()
            
            nutrientRow(
                "Magnesium",
                value: nutrients.magnesiumPercent,
                unit: "%"
            )
            Divider()
            
            nutrientRow(
                "Zat Besi",
                value: nutrients.ironPPM,
                unit: "ppm"
            )
            Divider()
            
            nutrientRow(
                "Copper",
                value: nutrients.copperPPM,
                unit: "ppm"
            )
            Divider()
            
            nutrientRow(
                "Zinc",
                value: nutrients.zincPPM,
                unit: "ppm"
            )
        }
        .padding(.horizontal, AppSpacing.Card.compact)
        .background{
            // MARK: belum make AppRadius
            RoundedRectangle(cornerRadius: 16).fill(
                AppColor.Primitive.Base.white
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private func nutrientRow(
        _ title: String,
        value: Double?,
        unit: String
    ) -> some View {
        LabeledContent {
            Text(formatted(value, unit: unit))
                .foregroundStyle(AppColor.Text.secondary)
                .multilineTextAlignment(.trailing)
        } label: {
            Text(title)
                .foregroundStyle(AppColor.Text.primary)
        }
        .font(AppFont.body)
        .padding(.vertical, AppSpacing.md)
    }
    
    private func formatted(
        _ value: Double?,
        unit: String
    ) -> String {
        guard let value else {
            return "Tidak tersedia"
        }
        
        let number = value.formatted(
            .number.precision(.fractionLength(0...2))
        )
        
        return number + (unit == "%" ? "%" : " \(unit)")
    }
}


//#Preview {
//    NutritionInfoView()
//}

#Preview {
    NavigationStack{
        NutritionInfoView(
            nutritionFeed: FeedIngredient(
                id: "preview-grass",
                name: "Rumput Gajah",
                category: .forage,
                nutrients: NutrientContent(
                    crudeProteinPercent: 10.2,
                    totalDigestibleNutrientsPercent: 55,
                    calciumPercent: 0.4,
                    phosphorusPercent: 0.3,
                    magnesiumPercent: nil,
                    ironPPM: nil,
                    copperPPM: nil,
                    zincPPM: nil
                ),
                triggersGossypolWarning: false
            )
        )
    }
}
