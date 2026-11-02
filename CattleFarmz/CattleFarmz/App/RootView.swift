//
//  RootView.swift
//  CattleFarmz
//

import SwiftUI

/// Top-level view that swaps between the splash screen and the main tab interface.
struct RootView: View {
    let container: DIContainer
    let coordinator: AppCoordinator

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
            case .main:
                MainTabView(container: container, coordinator: coordinator)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    RootView(container: DIContainer.preview, coordinator: AppCoordinator())
}
