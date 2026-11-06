//
//  SplashView.swift
//  CattleFarmz
//

import SwiftUI

/// Startup screen showing the app name until the app switches to the main interface.
struct SplashView: View {
    @State private var viewModel: SplashViewModel

    /// - Parameters:
    ///   - viewModel: View model created by the `App` layer.
    ///   - onFinished: Called when the splash delay elapses.
    init(viewModel: SplashViewModel, onFinished: @escaping () -> Void) {
        viewModel.onFinished = onFinished
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.medium) {
                Text(viewModel.appName)
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)

                if let message = viewModel.errorMessage {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.textSecondary)

                    GlassPrimaryButton("Try again") {
                        Task {
                            await viewModel.start()
                        }
                    }
                }
            }
            .padding(AppSpacing.medium)
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(), onFinished: {})
}
