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
            AppColor.Primitive.Secondary.shade100
                .ignoresSafeArea()

            ZStack {
                if stage >= 1 {
                    ZStack {
                        circleDot()
                            .offset(
                                x: isConverged
                                    ? 0
                                    : (showTwoDots ? -AppSpacing.lg : 0)
                            )

                        circleDot()
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .offset(x: isConverged ? 0 : AppSpacing.lg)
                        
                        circleDot()
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .offset(x:0,y: isConverged ? 0 : -AppSpacing.lg)

                        circleDot()
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .offset(x:0,y: isConverged ? 0 : AppSpacing.lg)
                    }
                    .rotationEffect(.degrees(formationRotation))
                }
            }
            .rotationEffect(.degrees(loadingRotation))
            .opacity(isHidden ? 0 : 1)
        }
        .task {
            while !Task.isCancelled {
                await runAnimation()
            }
        }
    }

    private func runAnimation() async {
        stage = 0
        showTwoDots = false
        formationRotation = 0
        loadingRotation = 0
        isConverged = false
        isHidden = false

        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }
//        withAnimation(.easeIn(duration: 0.35)) {
//            isHidden = false
//        }
        
        withAnimation(.easeIn(duration: 1.2)) {
            stage = 1
            loadingRotation += 180
            isConverged = false
        }

        try? await Task.sleep(for: .milliseconds(700))
        guard !Task.isCancelled else { return }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
            showTwoDots = true
            stage = 2
        }

        try? await Task.sleep(for: .milliseconds(200))
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            formationRotation = 90
        }

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        for _ in 0..<2 {
            withAnimation(.spring(response: 2, dampingFraction: 0.55)) {
                loadingRotation += 390
            }

            try? await Task.sleep(for: .milliseconds(1100))
            guard !Task.isCancelled else { return }

            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
        }

        withAnimation(.easeInOut(duration: 0.6)) {
            loadingRotation += 240
            isConverged = true
        }

        try? await Task.sleep(for: .milliseconds(650))
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            isHidden = true
        }

        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }

        onFinished()
    }
}

#Preview {
    LoadingView()
}
