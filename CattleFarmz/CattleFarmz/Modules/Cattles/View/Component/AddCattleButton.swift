//
//  AddCattleButton.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct AddCattleButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text("+ Tambah Sapi")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Button.Primary.foreground)
                .padding(.vertical, AppSpacing.xs)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500))
        }
//        .AppButtonStyle(.primary)
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    AddCattleButton(onTap: {})
}
