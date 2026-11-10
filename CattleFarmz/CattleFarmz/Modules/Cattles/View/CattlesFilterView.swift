//
//  CattlesFilterView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct CattlesFilterView: View {
    @Environment(\.dismiss) var filter
    @Binding var selectedBreed: Set<String>
    @Binding var selectedGender: Set<String>
    @Binding var selectedAgeRange: Set<String>

    var body: some View {
        ZStack {
            AppColor.Primitive.Base.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading) {
                    Text("Jenis Sapi")
                        .font(AppFont.body)
                    FilterBulletsView(
                        options: CattleBreed.allCases.map(\.rawValue),
                        selectedOptions: $selectedBreed
                    )
                    .padding(.bottom, AppSpacing.sm)
                    Divider()
                }

                VStack(alignment: .leading) {
                    Text("Jenis Kelamin Sapi")
                        .font(AppFont.body)
                    FilterBulletsView(
                        options: CattleGender.allCases.map(\.rawValue),
                        selectedOptions: $selectedGender
                    )
                    .padding(.bottom, AppSpacing.sm)
                    Divider()
                }
                
                VStack(alignment: .leading) {
                    Text("Usia Sapi")
                        .font(AppFont.body)
                    FilterBulletsView(
                        options: CattleAgeRange.allCases.map(\.rawValue),
                        selectedOptions: $selectedAgeRange
                    )
                }
                
                Spacer()
                
                VStack(spacing: AppSpacing.sm) {
                    Button {
                        filter()
                    } label: {
                        Text("Terapkan Filter")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Base.white)
                            .padding(.vertical, AppSpacing.sm)
                            .frame(maxWidth: .infinity)
                            .glassEffect(
                                .regular
                                    .tint(AppColor.Primitive.Primary.shade500)
                            )
                    }
                    .appButtonStyle(.primary)
                    
                    Button {
                        selectedBreed.removeAll()
                        selectedGender.removeAll()
                        selectedAgeRange.removeAll()
                        filter()
                    } label: {
                        Text("Hapus Filter")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Primary.shade500)
                            .padding(.vertical, AppSpacing.xxs)
                            .frame(maxWidth: .infinity)
                    }
                    .appButtonStyle(.text)
                }
            }
            .padding(AppSpacing.md)
        }
        .navigationTitle("Filter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    selectedBreed.removeAll()
                    selectedGender.removeAll()
                    selectedAgeRange.removeAll()
                    filter()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        })
    }
}

#Preview {
    @Previewable @State var selectedBreed: Set<String> = ["Brahman"]
    @Previewable @State var selectedGender: Set<String> = []
    @Previewable @State var selectedAgeRange: Set<String> = ["6-12 Bulan"]
    
    NavigationStack {
        CattlesFilterView(
            selectedBreed: $selectedBreed,
            selectedGender: $selectedGender,
            selectedAgeRange: $selectedAgeRange
        )
    }
}
