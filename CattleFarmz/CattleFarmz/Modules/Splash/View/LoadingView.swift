//
//  LoadingView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 06/11/26.
//

import SwiftUI

struct LoadingView: View {
    let onFinished: () -> Void

    @State private var stage = 0
    @State private var showFirstDot = true
    @State private var showSecondDot = false
    @State private var showTwoDots = false
    @State private var formationRotation: Double = 0
    @State private var loadingRotation: Double = 0
    @State private var isConverged = false
    @State private var isHidden = false

    init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            ZStack {
                if stage >= 2 {
                    ZStack {
                        circleDot
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .offset(x: isConverged ? 0 : -AppSpacing.xl)

                        circleDot
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .offset(x: isConverged ? 0 : AppSpacing.xl)
                    }
                    .rotationEffect(.degrees(formationRotation))
                }

                // Titik kedua: muncul di tengah, lalu bergerak ke kanan.
                if stage >= 1 {
                    circleDot
                        .scaleEffect(showSecondDot ? 1 : 0, anchor: .center)
                        .offset(
                            x: isConverged
                                ? 0
                            : (stage == 1 ? 0 : AppSpacing.xl)
                        )
                }

                // Titik pertama: dari tengah bergerak ke kiri.
                circleDot
                    .scaleEffect(showFirstDot ? 1 : 0, anchor: .center)
                    .offset(
                        x: isConverged
                            ? 0
                        : (stage >= 2 ? -AppSpacing.xl : 0)
                    )
            }
            .rotationEffect(.degrees(loadingRotation))
            .opacity(isHidden ? 0 : 1)
        }
        .task {
            await runAnimation()
        }
    }

    private func runAnimation() async {
        try? await Task.sleep(for: .milliseconds(200))
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.4)) {
            stage = 1
            showSecondDot = true
        }

        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            stage = 2
        }
        
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { return }
        showTwoDots = true

        try? await Task.sleep(for: .milliseconds(200))
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            formationRotation = 90
        }

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        for _ in 0..<2 {
            withAnimation(.easeInOut(duration: 0.8)) {
                loadingRotation += 360
            }

            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }

            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }
        }

        withAnimation(.easeInOut(duration: 0.6)) {
            loadingRotation += 180
            isConverged = true
        }

        try? await Task.sleep(for: .milliseconds(650))
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.35)) {
            isHidden = true
        }

        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }

        onFinished()
    }

    private var circleDot: some View {
        Circle()
            .fill(AppColor.Primitive.Primary.shade500)
            .frame(width: 30, height: 30)
    }
}

#Preview {
    LoadingView()
}
