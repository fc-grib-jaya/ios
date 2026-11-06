//
//  ScanningViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the Scanning tab.
///
/// The tab only requests a scan session; the finished measurement comes back
/// through the navigation closure and is kept here, never in `App/*`.
@Observable
@MainActor
final class ScanningViewModel {
    /// Measurement from the most recent finished session.
    private(set) var finalResult: ScanResult?

    private let navigation: ScanningNavigation

    init(navigation: ScanningNavigation) {
        self.navigation = navigation
    }

    func startScan() {
        navigation.onScanTap { [weak self] result in
            guard let result else { return }
            print(result)

            self?.finalResult = result
        }
    }
}
