//
//  AddCattleButton.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct AddCattleButton: View {
    @Binding var tambahSapi: Bool
    
    var body: some View {
        Button {
            tambahSapi = true
        } label: {
            Text("+ Tambah Sapi")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Button.Primary.foreground)
                .padding(.vertical, AppSpacing.xs)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500))
        }
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    AddCattleButton(tambahSapi: .constant(false))
}
