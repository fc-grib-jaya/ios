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

    /// Toast queue shared by every screen. Attached once in `MainTabView`.
    let toastManager: ToastManager

    
    private let feedProvider: () throws ->[FeedIngredient]
    private let rationCalculator: any RationCalculating
    
    private let prepareCatalog: () throws -> Void
    
    init(
        haptics: any HapticProviding,
        cattleRepository: any CattleRepository,
        weightCalculation: any WeightCalculation,
        feedProvider: @escaping () throws -> [FeedIngredient],
        rationCalculator: any RationCalculating,
        prepareCatalog: @escaping () throws -> Void = {}
    ) {
        self.haptics = haptics
        self.toastManager = ToastManager(haptics: haptics)
        self.cattleRepository = cattleRepository
        self.weightCalculation = weightCalculation
        self.feedProvider = feedProvider
        self.rationCalculator = rationCalculator
        self.prepareCatalog = prepareCatalog
    }
    
    /// Live environment backed by SwiftData.
    static func live(modelContext: ModelContext) -> DIContainer {
        let seeder = FeedCatalogSeeder(
            container: modelContext.container,
            reader: BundledFeedCSVReader(),
            parser: FeedCSVParser()
        )
        
        let feedRepository: any FeedRepository =
        SwiftDataFeedRepository(
            context: modelContext
        )
        
        return DIContainer(
            haptics: CoreHapticsService(),
            cattleRepository: SwiftDataCattleRepository(context: modelContext),
            weightCalculation: WeightCalculator(),
            feedProvider: {
                try feedRepository.ingredients()
            },
            rationCalculator: makeRationCalculator(),
            prepareCatalog: {
                try seeder.seedIfNeeded()
            }
        )
    }
    
    /// Preview environment backed by in-memory mocks.
    @MainActor
    static var preview: DIContainer {
        DIContainer(
            haptics: NoopHaptics(),
            cattleRepository: MockCattleRepository(),
            weightCalculation: WeightCalculator(),
            feedProvider: {
                let text = try BundledFeedCSVReader().read()
                return try FeedCSVParser().parse(text)
            },
            rationCalculator: makeRationCalculator()
        )
    }
    
    private static func makeRationCalculator()
    -> any RationCalculating {
        ManualRationCalculator { profile in
            CattleNutritionDefaults.requirements(
                for: profile.productionType,
                stage: profile.stage
            )
        }
    }
    
    /// Creates the splash screen view model.
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(
            prepareCatalog: prepareCatalog
        )
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

    /// Creates the add-cattle form view model.
    func makeCattleFormViewModel() -> CattleFormViewModel {
        CattleFormViewModel(calculation: weightCalculation)
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
    
    func makeRationPlanningViewModel()
    -> RationPlanningViewModel {
        RationPlanningViewModel(
            feedProvider: feedProvider,
            calculator: rationCalculator
        )
    }
}
