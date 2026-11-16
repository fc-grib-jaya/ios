//
//  OnboardingPage.swift
//  CattleFarmz
//

import Foundation

/// One page of the intro shown on first launch. Each page's visual content
/// lives in a dedicated custom view under `View/Component`, selected by `id`.
nonisolated struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String

    /// Placeholder copy; replaced when the real onboarding content arrives.
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Estimasi Bobot Sapi",
            subtitle: "Mudah, Cepat, dan Akurat."
        ),
        OnboardingPage(
            id: 1,
            title: "Nutrisi pakan sudah pas?",
            subtitle: "Nutrisi tepat bikin tumbuh optimal, kesehatan terjaga, dan gemuk ideal."
        ),
        OnboardingPage(
            id: 2,
            title: "Susun rencana pakan",
            subtitle: "Hitung kebutuhan nutrisi harian dari pakan yang tersedia."
        ),
        // Hidden for now; the ration planning page is the last slide.
        // OnboardingPage(
        //     id: 3,
        //     title: "Pantau pertumbuhan",
        //     subtitle: "Lihat riwayat bobot dan data sapi kapan saja."
        // )
    ]
}
