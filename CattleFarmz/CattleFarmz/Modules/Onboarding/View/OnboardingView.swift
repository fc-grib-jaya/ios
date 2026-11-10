//
//  OnboardingView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

/// Paged first-launch intro with the primary action pinned below the page dots.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)

        // Runs before the TabView builds its page control. Dots sit directly on
        // the canvas with no backdrop, so they need explicit colors.
        UIPageControl.appearance().currentPageIndicatorTintColor =
            UIColor(AppColor.Primitive.Primary.shade500)
        UIPageControl.appearance().pageIndicatorTintColor =
            UIColor(AppColor.Text.muted)
    }

    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                TabView(selection: $viewModel.index) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageContent(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                // The canvas is near-white, so the system's default white dots
                // need a tint; the appearance proxy keeps the dots native and
                // lets them render without a background pill.
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                Button(viewModel.buttonTitle) {
                    viewModel.primaryTapped()
                }
                .appButtonStyle(.primary)
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.top, AppSpacing.massive)
            .padding(.bottom, AppSpacing.xl)
            .overlay(alignment: .topTrailing) {
                if viewModel.isSkipVisible {
                    Button("Lewati") {
                        viewModel.skipTapped()
                    }
                    .buttonStyle(.glass)
                    .padding(.top, AppSpacing.sm)
                    .padding(.trailing, AppSpacing.md)
                }
            }
        }
    }
}

private struct OnboardingPageContent: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: page.systemImage)
                .font(AppFont.largeTitle)
                .imageScale(.large)
                .foregroundStyle(AppColor.Primitive.Primary.shade500)

            VStack(spacing: AppSpacing.sm) {
                Text(page.title)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.primary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Text.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}
