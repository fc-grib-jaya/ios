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
    let sounds: any SoundPlaying
    private let cattleRepository: any CattleRepository
    private let userProfileRepository: any UserProfileRepository
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
        sounds: any SoundPlaying,
        cattleRepository: any CattleRepository,
        userProfileRepository: any UserProfileRepository,
        weightCalculation: any WeightCalculation,
        feedProvider: @escaping () throws -> [FeedIngredient],
        rationCalculator: any RationCalculating,
        prepareCatalog: @escaping () throws -> Void = {}
    ) {
        self.haptics = haptics
        self.sounds = sounds
        self.toastManager = ToastManager(haptics: haptics, sounds: sounds)
        self.cattleRepository = cattleRepository
        self.userProfileRepository = userProfileRepository
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
            sounds: BundleSoundPlayer(),
            cattleRepository: SwiftDataCattleRepository(context: modelContext),
            userProfileRepository: SwiftDataUserProfileRepository(
                context: modelContext
            ),
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
            sounds: NoopSoundPlayer(),
            cattleRepository: MockCattleRepository(),
            userProfileRepository: MockUserProfileRepository(),
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
            displayDuration: .zero,
            prepareCatalog: prepareCatalog
        )
    }
    
    /// Creates the home screen view model.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(haptics: haptics)
    }

    /// Returns the stored farmer name for screens that greet the user.
    func farmerName() -> String {
        (try? userProfileRepository.profile())?.name ?? "Bapak"
    }
    
    /// Creates the profile screen view model.
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(repository: userProfileRepository)
    }
    
    /// Creates the cattles screen view model.
    func makeCattlesViewModel() -> CattlesViewModel {
        CattlesViewModel(repository: cattleRepository, calculation: weightCalculation, toast: toastManager)
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

    /// Reads onboarding state once at launch; cheap single-row fetch.
    func hasCompletedOnboarding() -> Bool {
        (try? userProfileRepository.profile())?.isOnboarded ?? false
    }

    /// Creates the onboarding view model.
    func makeOnboardingViewModel(
        navigation: OnboardingNavigation
    ) -> OnboardingViewModel {
        OnboardingViewModel(navigation: navigation)
    }

    /// Creates the guest login sheet view model.
    func makeGuestLoginSheetViewModel(
        onDone: @escaping () -> Void
    ) -> GuestLoginSheetViewModel {
        GuestLoginSheetViewModel(
            repository: userProfileRepository,
            onDone: onDone
        )
    }

    /// Creates the scanning tab view model.
    func makeScanningViewModel(navigation: ScanningNavigation) -> ScanningViewModel {
        ScanningViewModel(navigation: navigation)
    }

    /// Creates the view model for one full-screen scan session.
    func makeScanSessionViewModel(
        onFinish: @escaping (ScanResult?) -> Void,
        onCameraAccessDenied: @escaping () -> Void
    ) -> ScanSessionViewModel {
        ScanSessionViewModel(
            service: scanCapture,
            haptics: haptics,
            makeMeasurement: makeMeasurementViewModel(capture:),
            onFinish: onFinish,
            onCameraAccessDenied: onCameraAccessDenied
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
