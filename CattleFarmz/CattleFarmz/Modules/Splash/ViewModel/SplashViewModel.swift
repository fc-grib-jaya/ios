//
//  SplashViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Drives the splash screen: exposes the displayed name and reports when the
/// startup delay has elapsed.
@Observable
@MainActor
final class SplashViewModel {
    /// Name shown while the splash screen is visible.
    let appName: String
    
    /// Invoked once the splash delay elapses. The `App` layer wires it to the
    /// coordinator's splash-to-main transition.
    var onFinished: () -> Void
    
    private(set) var isPreparing = false
    private(set) var errorMessage: String?
    
    @ObservationIgnored
    private let prepareCatalog: () throws -> Void
    
    /// Time the splash screen stays visible.
    @ObservationIgnored
    private let displayDuration: Duration
    
    @ObservationIgnored
    private var hasFinished = false
    
    init(
        appName: String = "CattleFarmz",
        displayDuration: Duration = .seconds(1.5),
        prepareCatalog: @escaping () throws -> Void = {},
        onFinished: @escaping () -> Void = {}
    ) {
        self.appName = appName
        self.displayDuration = displayDuration
        self.prepareCatalog = prepareCatalog
        self.onFinished = onFinished
    }
    
    /// Waits for the splash delay, then notifies the caller. Cancellation (for
    /// example when the view disappears early) skips the notification.
    func start() async {
        guard !isPreparing, !hasFinished else {
            return
        }
        
        isPreparing = true
        errorMessage = nil
        
        defer {
            isPreparing = false
        }
        
        do {
            try Task.checkCancellation()
            
            try prepareCatalog()
            
            try await Task.sleep(for: displayDuration)
            
            try Task.checkCancellation()
            
            hasFinished = true
            onFinished()
        } catch is CancellationError {
            // A later appearance may retry.
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
