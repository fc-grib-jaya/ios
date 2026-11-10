//
//  RootView.swift
//  CattleFarmz
//

import SwiftUI

/// Top-level view that swaps between the splash, onboarding, and main tab interface.
struct RootView: View {
    let container: DIContainer
    @Bindable var coordinator: AppCoordinator

    init(container: DIContainer, coordinator: AppCoordinator) {
        self.container = container
        _coordinator = Bindable(wrappedValue: coordinator)
    }

    var body: some View {
        ZStack {
            switch coordinator.phase {
            case .splash:
                SplashView(
                    viewModel: container.makeSplashViewModel(),
                    onFinished: {
                        withAnimation {
                            coordinator.finishSplash()
                        }
                    }
                )
                .transition(.opacity)
            case .onboarding:
                OnboardingView(
                    viewModel: container.makeOnboardingViewModel(
                        navigation: OnboardingNavigation(
                            onGuestLoginTap: {
                                coordinator.showGuestLoginSheet(
                                    onDone: coordinator.finishOnboarding
                                )
                            }
                        )
                    )
                )
                .transition(.opacity)
                .sheet(item: $coordinator.sheet) { sheet in
                    AppSheetView(sheet: sheet, container: container)
                }
            case .main:
                MainTabView(container: container, coordinator: coordinator)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    RootView(container: DIContainer.preview, coordinator: AppCoordinator())
}
