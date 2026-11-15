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

            VStack(spacing: AppSpacing.xl) {
                TabView(selection: $viewModel.index) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageContent(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

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

                Button(viewModel.buttonTitle) {
                    viewModel.primaryTapped()
                }
                .appButtonStyle(.primary)
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.top, AppSpacing.massive)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}

private struct OnboardingPageContent: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Text(page.title)
                .font(AppFont.title)
                .foregroundStyle(AppColor.Text.primary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
                .multilineTextAlignment(.center)

            Image(systemName: page.systemImage)
                .font(AppFont.largeTitle)
                .imageScale(.large)
                .foregroundStyle(AppColor.Primitive.Primary.shade500)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}
