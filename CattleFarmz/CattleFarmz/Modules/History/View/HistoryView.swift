//
//  HistoryView.swift
//  CattleFarmz
//

import SwiftUI

/// Placeholder for the scan history list.
struct HistoryView: View {
    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            Text("History placeholder")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
        }
    }
}

#Preview {
    HistoryView()
}
