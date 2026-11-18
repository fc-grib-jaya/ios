//
//  NameForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 18/11/26.
//

import SwiftUI

struct NameForm: View {
    @Binding var namaCattle: String
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Text("Nama sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)
            
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
        }
        .padding(.horizontal, AppSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    @Previewable @State var namaCattle = ""
    NameForm(namaCattle: $namaCattle)
}
