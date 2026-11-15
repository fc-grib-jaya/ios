//
//  ToastItem.swift
//  CattleFarmz
//

import Foundation
import SwiftUI

/// A single toast request.
///
/// The model is independent of animation state: the view derives every visual
/// value from the item plus its own timeline. Identity is a `UUID`, so the same
/// message requested twice produces two distinct toasts.
struct ToastItem: Identifiable, Equatable {
    let id: UUID
    let message: String
    let icon: String
    let accentColor: Color
    let duration: Duration

    init(
        id: UUID = UUID(),
        message: String,
        icon: String = "checkmark",
        accentColor: Color = AppColor.Primitive.Primary.shade500,
        duration: Duration = .seconds(3)
    ) {
        self.id = id
        self.message = message
        self.icon = icon
        self.accentColor = accentColor
        self.duration = duration
    }
}
