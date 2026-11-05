//
//  AppCover.swift
//  CattleFarmz
//

/// Full-screen covers presented above the main tab interface.
///
/// A cover case carries its result closure, so the caller never references the
/// cover view and modules stay decoupled. `Identifiable` only: closures
/// prevent `Hashable`.
enum AppCover: Identifiable {
    /// One complete scan flow: camera, capture, then measurement.
    /// `onFinish` receives the measurement, or `nil` when the user cancelled.
    case scanSession(onFinish: (ScanResult?) -> Void)

    var id: String {
        switch self {
        case .scanSession: "scanSession"
        }
    }
}
