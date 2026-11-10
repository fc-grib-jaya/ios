//
//  OnboardingPage.swift
//  CattleFarmz
//

import Foundation

/// One page of the intro shown on first launch.
nonisolated struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let systemImage: String
    let title: String
    let subtitle: String

    /// Placeholder copy; replaced when the real onboarding content arrives.
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            systemImage: "list.bullet",
            title: "Catat sapi ternak",
            subtitle: "Simpan data sapi, bobot, dan catatan dalam satu tempat."
        ),
        OnboardingPage(
            id: 1,
            systemImage: "camera.viewfinder",
            title: "Ukur bobot dengan kamera",
            subtitle: "Estimasi bobot sapi tanpa perlu menimbang manual."
        ),
        OnboardingPage(
            id: 2,
            systemImage: "leaf",
            title: "Susun rencana pakan",
            subtitle: "Hitung kebutuhan nutrisi harian dari pakan yang tersedia."
        ),
        OnboardingPage(
            id: 3,
            systemImage: "chart.line.uptrend.xyaxis",
            title: "Pantau pertumbuhan",
            subtitle: "Lihat riwayat bobot dan data sapi kapan saja."
        )
    ]
}
