//
//  HistoryView.swift
//  CattleFarmz
//

import SwiftUI

/// Placeholder for the scan history list.
struct HistoryView: View {
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            Text("History placeholder")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview {
    HistoryView()
}
