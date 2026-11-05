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

@MainActor
final class DIContainer {
    let haptics: any HapticProviding
    private let cattleRepository: any CattleRepository
    private let weightCalculation: any WeightCalculation

    /// LiDAR capture service shared by every scan session.
    ///
    /// Created on first use, so launching the app never allocates an AR
    /// session or asks for camera permission.
    private(set) lazy var scanCapture: any ScanCapturing = CaptureService()

    init(
        haptics: any HapticProviding,
        cattleRepository: any CattleRepository,
        weightCalculation: any WeightCalculation
    ) {
        self.haptics = haptics
        self.cattleRepository = cattleRepository
        self.weightCalculation = weightCalculation
    }

    /// Live environment backed by SwiftData.
    static func live(modelContext: ModelContext) -> DIContainer {
        DIContainer(
            haptics: CoreHapticsService(),
            cattleRepository: SwiftDataCattleRepository(context: modelContext),
            weightCalculation: WeightCalculator()
        )
    }

    /// Preview environment backed by in-memory mocks.
    @MainActor
    static var preview: DIContainer {
        DIContainer(
            haptics: NoopHaptics(),
            cattleRepository: MockCattleRepository(),
            weightCalculation: WeightCalculator()
        )
    }

    /// Creates the splash screen view model.
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel()
    }

    /// Creates the home screen view model.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(haptics: haptics)
    }

    /// Creates the profile screen view model.
    func makeProfileViewModel() -> ProfileViewModel {
        // ProfileViewModel(arService: arService)
        ProfileViewModel()
    }

    /// Creates the cattles screen view model.
    func makeCattlesViewModel() -> CattlesViewModel {
        CattlesViewModel(repository: cattleRepository, calculation: weightCalculation)
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

    /// Creates the scanning tab view model.
    func makeScanningViewModel(navigation: ScanningNavigation) -> ScanningViewModel {
        ScanningViewModel(navigation: navigation)
    }

    /// Creates the view model for one full-screen scan session.
    func makeScanSessionViewModel(
        onFinish: @escaping (ScanResult?) -> Void
    ) -> ScanSessionViewModel {
        ScanSessionViewModel(
            service: scanCapture,
            makeMeasurement: makeMeasurementViewModel(capture:),
            onFinish: onFinish
        )
    }

    /// Creates the measurement view model for one captured frame.
    func makeMeasurementViewModel(capture: Capture) -> MeasurementViewModel {
        MeasurementViewModel(capture: capture, renderer: DepthRenderer())
    }
}
