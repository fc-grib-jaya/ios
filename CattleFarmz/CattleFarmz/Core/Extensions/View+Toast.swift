//
//  View+Toast.swift
//  CattleFarmz
//

import SwiftUI

extension View {
    /// Presents toasts requested through `manager` above this view.
    ///
    /// Attach once to the root container so every screen shares one queue. The
    /// overlay cannot appear above sheets, full-screen covers, or separate
    /// windows presented from this hierarchy; `MainTabView` attaches it below
    /// its own sheet and cover.
    func toast(manager: ToastManager) -> some View {
        toast(manager: manager, configuration: ToastConfiguration())
    }

    /// Presents toasts requested through `manager`, capped at `maxWidth`.
    func toast(manager: ToastManager, maxWidth: CGFloat) -> some View {
        toast(
            manager: manager,
            configuration: ToastConfiguration(maxWidth: maxWidth)
        )
    }

    /// Presents toasts with a fully customized configuration.
    func toast(
        manager: ToastManager,
        configuration: ToastConfiguration
    ) -> some View {
        modifier(ToastModifier(manager: manager, configuration: configuration))
    }
}
