//
//  ExamplePickerSheetViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the example picker sheet.
@Observable
@MainActor
final class ExamplePickerSheetViewModel {
    /// Navigation title of the sheet.
    let title = "Pick an Example"

    /// Currently selected value passed in when the sheet was opened.
    let current: String

    /// Options the user can choose from.
    let options: [String]

    /// Called with the selected value(s) when the user picks an option.
    private let onSelect: ([String]) -> Void

    init(
        current: String,
        options: [String],
        onSelect: @escaping ([String]) -> Void
    ) {
        self.current = current
        self.options = options
        self.onSelect = onSelect
    }

    /// Handles a selection and hands the result back to the caller.
    func select(_ item: String) {
        onSelect([item])
    }
}
