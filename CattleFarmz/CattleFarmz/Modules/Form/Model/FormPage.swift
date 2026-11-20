//
//  FormPage.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//


enum Field: Hashable {
    case name, age, weight, notes
}

nonisolated struct FormPage: Identifiable, Hashable {
    let id: Int

    /// Placeholder copy; replaced when the real onboarding content arrives.
    static let all: [FormPage] = [
        FormPage(
            id: 0
        ),
        FormPage(
            id: 1
        ),
        FormPage(
            id: 2
        )
    ]
}
