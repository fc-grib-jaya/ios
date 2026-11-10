//
//  OnboardingNavigation.swift
//  CattleFarmz
//

/// Navigation intents the onboarding module exposes to the `App` layer.
///
/// The module does not know which screen opens; the default closure is a no-op
/// so previews build the view model without a coordinator.
nonisolated struct OnboardingNavigation {
    /// Opens the guest login sheet.
    var onGuestLoginTap: () -> Void = {}
}
