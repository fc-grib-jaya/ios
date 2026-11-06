//
//  ScanningNavigation.swift
//  CattleFarmz
//

/// Navigation intents the Scanning tab exposes to the `App` layer.
///
/// The module does not know which screen opens; the default closure is a no-op
/// so previews build the view model without a coordinator.
struct ScanningNavigation {
    /// Starts a scan session. The callback receives the finished measurement,
    /// or `nil` when the session was cancelled.
    var onScanTap: (@escaping (ScanResult?) -> Void) -> Void = { _ in }
}
