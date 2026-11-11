//
//  CarcassView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct CarcassView: View {
    @State private var weightView = 0
    
    let breakdown: CattleWeightBreakdown
    let carcassPercent: Double
    let nonCarcassPercent: Double
    let carcassWeight: Double
    let nonCarcassWeight: Double
    
    init(breakdown: CattleWeightBreakdown) {
        self.breakdown = breakdown
        
        let bodyWeight = breakdown.bodyWeight ?? 0
        let carcassWeight = breakdown.carcass ?? 0
        let nonCarcassWeight = breakdown.nonCarcass ?? 0
        
        self.carcassWeight = carcassWeight
        self.nonCarcassWeight = nonCarcassWeight
        self.carcassPercent = bodyWeight > 0 ? carcassWeight / bodyWeight * 100 : 0
        self.nonCarcassPercent = bodyWeight > 0 ? nonCarcassWeight / bodyWeight * 100 : 0
        
        let primary = UIColor(AppColor.Primitive.Primary.shade400)
        let white = UIColor(AppColor.Primitive.Base.white)
        let segmented = UISegmentedControl.appearance()
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)

        segmented.selectedSegmentTintColor = primary
        segmented.backgroundColor = primary.withAlphaComponent(0.12)

        segmented.setTitleTextAttributes(
            [.foregroundColor: primary, .font: font],
            for: .normal
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: white, .font: font],
            for: .selected
        )
    }
    
    init(
        carcassPercent: Double,
        nonCarcassPercent: Double,
        carcassWeight: Double,
        nonCarcassWeight: Double
    ) {
        self.init(
            breakdown: CattleWeightBreakdown(
                bodyWeight: carcassWeight + nonCarcassWeight,
                carcass: carcassWeight,
                nonCarcass: nonCarcassWeight,
                meat: nil,
                nonCarcassParts: [:]
            )
        )
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Informasi karkas & non-karkas")
                .font(AppFont.title)
                .padding(.bottom, AppSpacing.md)

            WeightPercentageCard(
                carcassPercent: carcassPercent,
                nonCarcassPercent: nonCarcassPercent,
                carcassWeight: carcassWeight,
                nonCarcassWeight: nonCarcassWeight
            )
            
            HStack {
                Text("Distribusi Bobot")
                    .font(AppFont.headline)
                    .padding(.trailing, AppSpacing.huge)
                
                Picker("Options", selection: $weightView) {
                    Text("kg").tag(0)
                    Text("%").tag(1)
                }
                .pickerStyle(.segmented)
                .controlSize(.large)
                .padding(.vertical, AppSpacing.xs)
                .padding(.leading, AppSpacing.huge)
            }
            
            
            HorizontalSankeyChart(
                data: carcassSankeyItems(
                    breakdown,
                    asPercentage: weightView == 1
                ),
                valueSuffix: weightView == 1 ? " %" : " kg",
                levelSpacing: 84
            )
            .frame(height: 520)
            .padding(.bottom, AppSpacing.md)
            
            Text("Lebar aliran menunjukkan proporsi bobot hidup.")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.Primitive.Neutral.shade400)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Base.white)
        .cornerRadius(16)
        .shadow(
            color: Color(red: 0.000, green: 0.000, blue: 0.000, opacity: 0.05),
            radius: 5,
            x: 0,
            y: 4
        )
    }
    
    
    private func carcassSankeyItems(
        _ breakdown: CattleWeightBreakdown,
        asPercentage: Bool
    ) -> [SankeyItem] {
        guard let bodyWeight = breakdown.bodyWeight, bodyWeight > 0 else {
            return []
        }

        func displayValue(_ value: Double) -> Double {
            asPercentage ? value / bodyWeight * 100 : value
        }

        let meatPercent = breakdown.meat.map(displayValue)

        var carcassChildren: [SankeyItem] = []
        if let meatPercent {
            carcassChildren.append(
                SankeyItem(
                    id: "meat",
                    title: "Daging",
                    value: meatPercent,
                    color: AppColor.Primitive.Secondary.shade300,
                    order: 0 // layer 3: 0.0
                )
            )
        }
        if let carcass = breakdown.carcass, let meatPercent {
            let bonePercent = displayValue(carcass) - meatPercent
            if bonePercent > 0 {
                carcassChildren.append(
                    SankeyItem(
                        id: "bone",
                        title: "Tulang",
                        value: bonePercent,
                        color: AppColor.Primitive.Secondary.shade300,
                        order: 1 // layer 3: 0.1
                    )
                )
            }
        }

        // Layer 3 ordering: meat 0.0, bone 0.1, non-carcass parts from 2.
        let nonCarcassChildren: [SankeyItem] = NonCarcassPart.allCases
            .enumerated()
            .compactMap { index, part in
                guard let weight = breakdown.nonCarcassParts[part],
                      displayValue(weight) > 0 else {
                    return nil
                }
                return SankeyItem(
                    id: "non-\(part.rawValue)",
                    title: part.displayName,
                    value: displayValue(weight),
                    color: AppColor.Primitive.Primary.shade100,
                    order: 2 + index
                )
            }

        var children: [SankeyItem] = []
        if let carcass = breakdown.carcass {
            if carcassChildren.isEmpty {
                children.append(
                    SankeyItem(
                        id: "carcass",
                        title: "Karkas",
                        value: displayValue(carcass),
                        color: AppColor.Primitive.Secondary.shade500,
                        order: 0
                    )
                )
            } else {
                children.append(
                    SankeyItem(
                        id: "carcass",
                        title: "Karkas",
                        color: AppColor.Primitive.Secondary.shade500,
                        order: 0,
                        children: carcassChildren
                    )
                )
            }
        }
        if let nonCarcass = breakdown.nonCarcass {
            if nonCarcassChildren.isEmpty {
                children.append(
                    SankeyItem(
                        id: "nonCarcass",
                        title: "Non Karkas",
                        value: displayValue(nonCarcass),
                        color: AppColor.Primitive.Primary.shade200,
                        order: 1
                    )
                )
            } else {
                children.append(
                    SankeyItem(
                        id: "nonCarcass",
                        title: "Non Karkas",
                        color: AppColor.Primitive.Primary.shade200,
                        order: 1,
                        children: nonCarcassChildren
                    )
                )
            }
        }

        guard !children.isEmpty else { return [] }

        return [
            SankeyItem(
                id: "body",
                title: "Bobot",
                color: AppColor.Primitive.Secondary.shade100,
                order: 0,
                children: children
            )
        ]
    }
}

#Preview {
    CarcassView(
        carcassPercent: 69,
        nonCarcassPercent: 69,
        carcassWeight: 69.69,
        nonCarcassWeight: 69.69
    )
}
