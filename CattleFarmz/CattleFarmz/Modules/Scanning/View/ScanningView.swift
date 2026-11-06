//
//  ScanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Entry point of the LiDAR scanning flow.
///
/// The view only asks its view model to start a session; the `App` layer
/// presents the camera cover and the finished measurement returns through the
/// view model.
struct ScanningView: View {
    @State private var viewModel: ScanningViewModel

    init(viewModel: ScanningViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            Text("Scan placeholder")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
        }
        .forcePortrait()
    }

//    private func lastResultCard(_ result: ScanResult) -> some View {
//        VStack(alignment: .leading, spacing: AppSpacing.small) {
//            Text("Hasil terakhir")
//                .font(AppFont.headline)
//            LabeledContent(
//                "Panjang badan",
//                value: result.lengthCM.formatted(.number.precision(.fractionLength(1))) + " cm"
//            )
//            if let girth = result.girthCM {
//                LabeledContent(
//                    "Lingkar dada",
//                    value: girth.formatted(.number.precision(.fractionLength(1))) + " cm"
//                )
//            }
//            if let weight = result.weightKG {
//                LabeledContent(
//                    "Bobot Winter",
//                    value: "≈ " + weight.formatted(.number.precision(.fractionLength(0))) + " kg"
//                )
//            }
//        }
//        .font(AppFont.caption)
//        .foregroundStyle(AppColor.textPrimary)
//        .padding(AppSpacing.medium)
//        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium))
//    }
}

#Preview {
    ScanningView(viewModel: ScanningViewModel(navigation: ScanningNavigation()))
}
