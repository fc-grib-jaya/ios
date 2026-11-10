//
//  SplashView.swift
//  CattleFarmz
//

import SwiftUI

/// Startup screen showing the app name until the app switches to the main interface.
struct SplashView: View {
    @State private var viewModel: SplashViewModel

    /// - Parameters:
    ///   - viewModel: View model created by the `App` layer.
    ///   - onFinished: Called when the splash delay elapses.
    init(viewModel: SplashViewModel, onFinished: @escaping () -> Void) {
        viewModel.onFinished = onFinished
        _viewModel = State(initialValue: viewModel)
    }
    
    @State private var stage = 0
    @State private var isFalling = false
    @State private var isStanding = false
    @State private var showFirstDot = true
    @State private var showSecondDot = false
    @State private var showTwoDots = false
    @State private var showMouth = false
    @State private var dotPulseScale: CGFloat = 1
    @State private var formationRotation: Double = 0
    @State private var loadingRotation: Double = 0
    @State private var isConverged = false
    @State private var isHidden = false


    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(AppColor.Primitive.Primary.shade500)
                    .rotationEffect(.degrees(135))
                    .frame(width: 80, height: 30)
                    .offset(x: -AppSpacing.md, y: -AppSpacing.md)
                    .scaleEffect(showMouth ? 1 : 0, anchor: .top)
                    .opacity(showMouth ? 1 : 0)
                    .scaleEffect(dotPulseScale)
                
                if stage >= 2 {
                    ZStack {
                        circleDot()
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .scaleEffect(dotPulseScale)
                            .offset(y: isConverged ? 0 : -AppSpacing.xxl)

                        circleDot()
                            .overlay {
                                if showMouth {
                                    Circle()
                                        .fill(AppColor.Primitive.Base.white)
                                }
                            }
                            .scaleEffect(showTwoDots ? 1 : 0)
                            .scaleEffect(dotPulseScale)
                            .offset(y: isConverged ? 0 : AppSpacing.xxl)
                            
                    }
                    .rotationEffect(.degrees(formationRotation))
                }

                // Titik kedua: muncul di tengah, lalu bergerak ke kanan.
                if showSecondDot {
                    circleDot()
                        .scaleEffect(showSecondDot ? 1 : 0, anchor: .center)
                        .scaleEffect(dotPulseScale)
                        .offset(
                            x: isConverged
                                ? 0
                                : (stage == 1 ? AppSpacing.xxl : 0),
                            y: isStanding ? AppSpacing.xxl : 0
                        )
                }

                // Titik pertama: dari tengah bergerak ke kiri.
                circleDot()
                    .overlay {
                        if showMouth {
                            Circle()
                                .fill(AppColor.Primitive.Base.white)
                        }
                    }
                    .scaleEffect(showFirstDot ? 1 : 0, anchor: .center)
                    .scaleEffect(dotPulseScale)
                    .offset(
                        x: isConverged
                            ? 0
                        : (stage == 1 ? -AppSpacing.xxl : 0),
                        y: isStanding ? -AppSpacing.xxl : (stage == 1 ? 0 : (isFalling ? 0 : -300))
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
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled else { return }
        
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 14)) {
            stage = 0
            isFalling = true
        }
        
        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }
        showSecondDot = true
        try? await Task.sleep(for: .milliseconds(200))
        guard !Task.isCancelled else { return }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
            stage = 1
        }
        
        try? await Task.sleep(for: .milliseconds(600))
        guard !Task.isCancelled else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            stage = 2
            isStanding = true
        }
        
        try? await Task.sleep(for: .milliseconds(100))
        guard !Task.isCancelled else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            formationRotation = 90
            showTwoDots = true
        }

        try? await Task.sleep(for: .milliseconds(400))
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
        
        withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
            loadingRotation += 165
        }
        
        try? await Task.sleep(for: .milliseconds(1500))
        guard !Task.isCancelled else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showMouth = true
        }

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.5)) {
            dotPulseScale = 1.1
        }

        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            dotPulseScale = 1
        }

        try? await Task.sleep(for: .milliseconds(1300))
        guard !Task.isCancelled else { return }

        viewModel.onFinished()
    }
}
#Preview {
    SplashView(viewModel: SplashViewModel(), onFinished: {})
}
