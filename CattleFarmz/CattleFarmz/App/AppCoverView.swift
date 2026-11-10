//
//  AppCoverView.swift
//  CattleFarmz
//

import SwiftUI

/// Builds the view for the active `AppCover` through `DIContainer` factories.
///
/// `AppCoordinator` stays unaware of dependency injection and views; this is
/// the only place that maps a cover case to a screen.
struct AppCoverView: View {
    let cover: AppCover
    let container: DIContainer

    var body: some View {
        switch cover {
        case .scanLoading:
            LoadingView()
        case .scanSession(let onFinish):
            ScanSessionView(
                viewModel: container.makeScanSessionViewModel(onFinish: onFinish)
            )
        }
    }
}
