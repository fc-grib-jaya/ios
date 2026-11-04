//
//  DIContainer.swift
//  CattleFarmz
//

import SwiftData

/// Builds the view models the `App` layer passes into each module's views.
///
/// Shared services that outlive a single screen (for example a LiDAR scan
/// service) belong here as `lazy var` properties, referenced through protocols
/// declared in `Core/Contracts`, and injected into the factories below.
final class DIContainer {
    private let cattleRepository: any CattleRepository

    init(cattleRepository: any CattleRepository) {
        self.cattleRepository = cattleRepository
    }

    /// Live environment backed by SwiftData.
    static func live(modelContext: ModelContext) -> DIContainer {
        DIContainer(
            cattleRepository: SwiftDataCattleRepository(context: modelContext)
        )
    }

    /// Preview environment backed by in-memory mocks.
    @MainActor
    static var preview: DIContainer {
        DIContainer(
            cattleRepository: MockCattleRepository()
        )
    }

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
        // ProfileViewModel(arService: arService)
        ProfileViewModel()
    }

    /// Creates the cattles screen view model.
    func makeCattlesViewModel() -> CattlesViewModel {
        CattlesViewModel(repository: cattleRepository)
    }

    /// Creates the example picker sheet view model.
    func makeExamplePickerSheetViewModel(
        current: String,
        onSelect: @escaping ([String]) -> Void
    ) -> ExamplePickerSheetViewModel {
        ExamplePickerSheetViewModel(
            current: current,
            options: ["Sapi 1", "Sapi 2", "Sapi 3"],
            onSelect: onSelect
        )
    }
}
