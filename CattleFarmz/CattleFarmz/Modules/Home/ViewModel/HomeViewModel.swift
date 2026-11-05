//
//  HomeViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the home screen.
@Observable
@MainActor
final class HomeViewModel {
    /// Navigation title of the home screen.
    let title = "Lemoo"

    /// Placeholder copy shown until the home content is implemented.
    let placeholder = "Home screen placeholder"
}
