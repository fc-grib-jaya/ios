//
//  OnboardingViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation
import SwiftUI

/// Drives the first-launch intro: page selection and the primary action.
@Observable
@MainActor
final class OnboardingViewModel {
    let pages: [OnboardingPage]
    var index = 0
    private let navigation: OnboardingNavigation

    init(
        navigation: OnboardingNavigation = OnboardingNavigation(),
        pages: [OnboardingPage] = OnboardingPage.all
    ) {
        self.navigation = navigation
        self.pages = pages
    }

    var isLastPage: Bool { index >= pages.count - 1 }
    var buttonTitle: String { isLastPage ? "Masuk sebagai tamu" : "Lanjut" }

    /// Advances one page, or opens the guest login sheet on the last page.
    func primaryTapped() {
        if isLastPage {
            navigation.onGuestLoginTap()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                index += 1
            }
        }
    }
}
