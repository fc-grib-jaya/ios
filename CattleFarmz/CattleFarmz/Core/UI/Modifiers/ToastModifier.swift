//
//  ToastModifier.swift
//  CattleFarmz
//

import SwiftUI

/// Presents the manager's active toast above the modified view.
///
/// The overlay stays centered horizontally, respects the safe area, and never
/// intercepts touches. Attach it once to the root container of the app; a
/// regular overlay cannot appear above sheets, full-screen covers, or separate
/// windows presented from that hierarchy.
struct ToastModifier: ViewModifier {
    let manager: ToastManager
    let configuration: ToastConfiguration

    @State private var availableWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack(alignment: .top) {
                    if let item = manager.current {
                        ToastView(
                            item: item,
                            configuration: configuration,
                            availableWidth: availableWidth,
                            isDismissRequested: manager.exitRequestID == item.id,
                            onOvershoot: { manager.playOvershootFeedback() },
                            onExitComplete: { manager.finish(item.id) }
                        )
                        .id(item.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .safeAreaPadding(.top, configuration.topInset)
                .allowsHitTesting(false)
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.width },
                    action: { availableWidth = $0 }
                )
            }
    }
}
