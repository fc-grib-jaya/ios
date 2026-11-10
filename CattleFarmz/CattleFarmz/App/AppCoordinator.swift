//
//  AppCoordinator.swift
//  CattleFarmz
//

import Observation
import UIKit

/// The top-level states the app can be in.
enum AppPhase {
    /// Startup screen shown before the main interface.
    case splash
    /// First-launch intro, shown until the user completes onboarding.
    case onboarding
    /// Main tab interface.
    case main
}

/// Owns app-level state: the visible phase and the navigation path of the Home tab.
///
/// Modules never create routes themselves. They request navigation through the
/// closures that this coordinator's methods are wired into by the `App` layer.
@Observable
@MainActor
final class AppCoordinator {
    /// Current top-level app phase.
    var phase: AppPhase = .splash
    var sheet: AppSheet?
    var cover: AppCover?

    /// Launch-time snapshot of the persisted onboarding state.
    private(set) var hasCompletedOnboarding: Bool

    init(hasCompletedOnboarding: Bool = false) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    /// Leaves the splash screen for onboarding or the main interface.
    func finishSplash() {
        phase = hasCompletedOnboarding ? .main : .onboarding
    }

    /// Navigation path of the Home tab, expressed as `AppRoute` values.
    var path: [AppRoute] = []

    /// Pushes the profile screen onto the Home navigation stack.
    func showProfile() {
        guard path.last != .profile else { return }

        path.append(.profile)
    }
    
    func goToCattleDetail(cattleID: String) {
        path.append(.cattleDetail(id: cattleID))
    }

    /// Pushes the add-cattle form onto the Home navigation stack.
    func showAddCattle() {
        path.append(.addCattle)
    }

    /// App Sheet handling

    func showExamplePickerSheet(
        current: String,
        onSelect: @escaping ([String]) -> Void
    ) {
        sheet = .examplePickerSheet(current: current, onSelect: onSelect)
    }

    func showEditCattleSheet(
        cattle: Cattle,
        onSave: @escaping (CattleEditValues) -> String?
    ) {
        sheet = .editCattle(cattle: cattle, onSave: onSave)
    }

    func dismissSheet() {
        sheet = nil
    }

    /// Opens the guest login sheet and dismisses it once `onDone` runs.
    func showGuestLoginSheet(onDone: @escaping () -> Void) {
        sheet = .guestLoginSheet { [weak self] in
            onDone()
            self?.dismissSheet()
        }
    }

    /// Marks onboarding complete and reveals the main tab interface.
    func finishOnboarding() {
        hasCompletedOnboarding = true
        sheet = nil
        phase = .main
    }

    /// App Cover handling

    /// True while the scan session is waiting for the window to rotate.
    @ObservationIgnored private var isPreparingScanSession = false

    /// Invalidates a pending portrait restore when a new session starts.
    @ObservationIgnored private var coverEpoch = 0

    /// Opens one scan session and dismisses the cover when the flow ends.
    /// `onFinish` receives the measurement, or `nil` when the user cancelled.
    func showScanSession(onFinish: @escaping (ScanResult?) -> Void) {
        guard cover == nil, !isPreparingScanSession else { return }
        isPreparingScanSession = true
        coverEpoch &+= 1

        // Rotate first, then present only after the window reports landscape
        // geometry. Presenting during the rotation builds the cover in
        // portrait, rebuilds it in landscape, and snapshots the AR view
        // repeatedly, which looks like a rotating shadow for about a second.
        OrientationController.shared.lock(to: .landscapeRight)
        Task { @MainActor [weak self] in
            await OrientationController.shared.waitForOrientation(
                .landscapeRight
            )
            guard let self else { return }
            self.isPreparingScanSession = false
            guard self.cover == nil else { return }
            self.cover = .scanSession { [weak self] result in
                onFinish(result)
                self?.dismissCover()
            }
        }
    }

    func dismissCover() {
        cover = nil
        // Restore portrait only after the dismissal transition finishes;
        // rotating while the cover animates out produces the same snapshots
        // and repeated rebuilds as opening did.
        coverEpoch &+= 1
        let epoch = coverEpoch
        Task { @MainActor [weak self] in
            await OrientationController.shared.waitForCoverDismissal()
            guard let self, self.coverEpoch == epoch, self.cover == nil else {
                return
            }
            OrientationController.shared.lock(to: .portrait)
        }
    }
}
