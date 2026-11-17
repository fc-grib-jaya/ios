//
//  OnboardingView.swift
//  CattleFarmz
//

import SwiftUI

/// Paged first-launch intro with the primary action pinned below the page dots.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()

            TabView(selection: $viewModel.index) {
                ForEach(viewModel.pages) { page in
                    OnboardingPageContent(
                        page: page,
                        isActive: page.id == viewModel.index
                    )
                    .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 24)

            VStack(spacing: AppSpacing.xl) {

                Spacer()

                Button(viewModel.buttonTitle) {
                    viewModel.primaryTapped()
                }
                .appButtonStyle(.primary)
                .padding(.horizontal, AppSpacing.md)

                // Custom page indicator: the active page is an elongated
                // capsule, inactive pages stay circular dots.
                HStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(
                                i == viewModel.index
                                    ? AppColor.Primitive.Primary.shade500
                                    : AppColor.Text.muted
                            )
                            .frame(
                                width: i == viewModel.index ? 24 : 8,
                                height: 8
                            )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.index)

            }
            .padding(.top, AppSpacing.massive)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

private struct OnboardingPageContent: View {
    let page: OnboardingPage
    /// True while this page is the selected one; visuals use it to hold
    /// their entrance until the page is actually shown.
    let isActive: Bool

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text(page.title)
                .font(.custom("PlusJakartaSans-ExtraBold", size: 48))
                .foregroundStyle(AppColor.Text.primary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
                .multilineTextAlignment(.center)

            // Per-page visual, pinned top-left so there is room beneath it.
            pageVisual
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var pageVisual: some View {
        switch page.id {
        case 0: OnboardingWeightEstimationView()
        case 1: OnboardingNutritionPlanningView(isActive: isActive)
        default: OnboardingFeedPlanView(isActive: isActive)
            // Hidden for now; the ration planning page is the last slide.
            // case 2: OnboardingFeedPlanView(isActive: isActive)
            // default: OnboardingGrowthTrackingView()
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}
