//
//  AgeForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 18/11/26.
//

import SwiftUI

struct AgeForm: View {
    @Binding var usiaSapi: Int?
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            HStack(spacing: 1) {
                Text("Usia sapi?")
                    .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                Text("*")
                    .foregroundStyle(Color.red)
            }
            .font(AppFont.formTitle)
            .multilineTextAlignment(.center)
            .padding(.vertical, AppSpacing.sm)
            
            HStack {
                VStack {
                    TextField(
                        value: $usiaSapi,
                        format: .number,
                        prompt: Text("Contoh: 19").italic().accessibilityLabel("Tuliskan Usia Sapi")
                    ) {
                        Text("Usia Sapi (Bulan)")
                    }
                    .keyboardType(.numberPad)
                    .font(AppFont.mediumBody).bold()
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
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    @Previewable @State var usiaSapi: Int?
    AgeForm(usiaSapi: $usiaSapi)
}
