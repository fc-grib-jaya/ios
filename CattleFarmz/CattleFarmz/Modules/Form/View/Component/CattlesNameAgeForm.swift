//
//  CattlesNameAgeForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CattlesNameAgeForm: View {
    @Binding var namaCattle: String
    @Binding var usiaSapi: Int?
    let isActive: Bool
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Text("Nama sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)
            
            Spacer()
            
            HStack {
                TextField("Tuliskan Nama Sapi", text: $namaCattle)
                    .font(AppFont.body)
                    .autocorrectionDisabled()
                    .onChange(of: namaCattle) { _, newValue in
                        if newValue.count > 30 {
                            namaCattle = String(newValue.prefix(30))
                        }
                    }
                    .focused($focusedField, equals: .name)
                
                if !namaCattle.isEmpty {
                    Button {
                        namaCattle = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColor.Primitive.Neutral.shade300)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hapus nama sapi")
                }
            }
            .padding(.vertical, AppSpacing.xxs)
            .padding(.horizontal, AppSpacing.huge)
            
            Divider()
                .overlay(AppColor.Text.primary)
                .padding(.horizontal, AppSpacing.huge)
            
            Spacer()
            
            Text("Usia sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)

            HStack {
                VStack {
                    TextField(
                        value: $usiaSapi,
                        format: .number,
                        prompt: Text("Contoh: \"12\"").italic().accessibilityLabel("Tuliskan Usia Sapi")
                    ) {
                        Text("Usia Sapi (Bulan)")
                    }
                    .keyboardType(.numberPad)
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .onChange(of: usiaSapi) { _, value in
                        guard let value else { return }
                        
                        if value > 99 {
                            usiaSapi = 99
                        } else if value < 0 {
                            usiaSapi = 0
                        }
                    }
                    .focused($focusedField, equals: .age)
                    
                    Divider()
                        .overlay(AppColor.Text.primary)
                }

                Text("bulan")
            }
            .padding(.horizontal, AppSpacing.massive)
            .padding(.horizontal, AppSpacing.xxl)
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .onChange(of: isActive) { _, isActive in
            if !isActive {
                focusedField = nil
            }
        }
    }
}

#Preview {
    @Previewable @State var namaCattle = ""
    @Previewable @State var usiaSapi: Int?

    CattlesNameAgeForm(
        namaCattle: $namaCattle,
        usiaSapi: $usiaSapi,
        isActive: true
    )
}
