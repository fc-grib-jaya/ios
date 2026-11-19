import SwiftUI

/// Plays a bundled guide without retaining all 120 full-resolution frames.
struct AnimatedGuideGIF: View {
    let resourceName: String
    @State private var frame: CGImage?
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityPlayAnimatedImages) private var playAnimatedImages

    private var shouldAnimate: Bool {
        scenePhase == .active && !reduceMotion && playAnimatedImages
    }

    var body: some View {
        Group {
            if let frame {
                Image(decorative: frame, scale: 1)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(resourceName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .accessibilityHidden(true)
        .task(id: "\(resourceName)-\(shouldAnimate)") {
            frame = nil
            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "gif"),
                  let decoder = GIFFrameSource(url: url) else { return }
            let animate = shouldAnimate
            // The final frame shows the whole animal and the highlighted point.
            var index = animate ? 0 : decoder.frameCount - 1
            let clock = ContinuousClock()
            do {
                repeat {
                    let started = clock.now
                    guard let decoded = await decoder.frame(at: index) else { return }
                    try Task.checkCancellation()
                    frame = decoded.image
                    guard animate else { return }
                    try await clock.sleep(until: started.advanced(by: .seconds(decoded.duration)))
                    index = (index + 1) % decoder.frameCount
                } while !Task.isCancelled
            } catch {
                // Closing the hint or leaving the screen cancels playback.
            }
        }
    }
}
