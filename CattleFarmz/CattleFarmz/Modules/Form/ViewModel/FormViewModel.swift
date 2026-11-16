//
//  FormViewModel.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import Foundation
import Observation
import SwiftUI

/// Drives the first-launch intro: page selection and the primary action.
@Observable
@MainActor
final class FormViewModel {
    let pages: [FormPage]
    var index = 0
    private let navigation: FormNavigation

    init(
        navigation: FormNavigation = FormNavigation(),
        pages: [FormPage] = FormPage.all
    ) {
        self.navigation = navigation
        self.pages = pages
    }

    var isLastPage: Bool { index >= pages.count - 1 }
    var buttonTitle: String { isLastPage ? "Simpan" : "Lanjut" }

    /// Advances one page, or opens the guest login sheet on the last page.
    func primaryTapped() {
        if isLastPage {
            navigation.onAddTap()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                index += 1
            }
        }
    }
}
