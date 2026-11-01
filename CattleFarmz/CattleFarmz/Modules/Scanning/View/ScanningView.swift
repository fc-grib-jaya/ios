//
//  ScanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Placeholder for the LiDAR scanning flow.
struct ScanningView: View {
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            Text("Scan placeholder")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview {
    ScanningView()
}
