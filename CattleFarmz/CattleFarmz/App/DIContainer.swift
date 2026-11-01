//
//  DIContainer.swift
//  CattleFarmz
//

/// Builds the view models the `App` layer passes into each module's views.
///
/// Shared services that outlive a single screen (for example a LiDAR scan
/// service) belong here as `lazy var` properties, referenced through protocols
/// declared in `Core/Contracts`, and injected into the factories below.
/// No real services exist yet.
final class DIContainer {
    /// Creates the splash screen view model.
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel()
    }

    /// Creates the home screen view model.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }

    /// Creates the profile screen view model.
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel()
    }
}
