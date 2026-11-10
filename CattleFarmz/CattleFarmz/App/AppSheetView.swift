//
//  AppSheetView.swift
//  CattleFarmz
//

import SwiftUI

/// Builds the view for the active `AppSheet` through `DIContainer` factories.
struct AppSheetView: View {
    let sheet: AppSheet
    let container: DIContainer

    var body: some View {
        switch sheet {
        case .examplePickerSheet(let current, let onSelect):
            ExamplePickerSheetView(
                viewModel: container.makeExamplePickerSheetViewModel(
                    current: current,
                    onSelect: onSelect
                )
            )
        case .guestLoginSheet(let onDone):
            GuestLoginSheetView(
                viewModel: container.makeGuestLoginSheetViewModel(onDone: onDone)
            )
        case .editCattle(let cattle, let onSave):
            NavigationStack {
                CattlesEditForm(cattle: cattle, onSave: onSave)
            }
        }
    }
}
