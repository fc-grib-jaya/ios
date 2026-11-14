import SwiftUI
import UIKit

extension View {
    /// Dismiss on scrolling or tapping outside a text input, without a toolbar.
    func dismissibleKeyboard() -> some View {
        self
            .scrollDismissesKeyboard(.interactively)
            .background(KeyboardDismissalArea())
    }
}

private struct KeyboardDismissalArea: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardDismissalView {
        KeyboardDismissalView()
    }

    func updateUIView(_ uiView: KeyboardDismissalView, context: Context) {}

    static func dismantleUIView(_ uiView: KeyboardDismissalView, coordinator: ()) {
        uiView.detachGesture()
    }
}

private final class KeyboardDismissalView: UIView, UIGestureRecognizerDelegate {
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    private weak var attachedWindow: UIWindow?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        detachGesture()
        guard let window else { return }
        isUserInteractionEnabled = false
        // Observe taps without consuming button actions or text-selection gestures.
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
        attachedWindow = window
    }

    func detachGesture() {
        attachedWindow?.removeGestureRecognizer(tap)
        attachedWindow = nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard bounds.contains(touch.location(in: self)) else { return false }
        var touchedView = touch.view
        while let view = touchedView {
            if view is UITextField || view is UITextView { return false }
            touchedView = view.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    @objc private func dismissKeyboard() {
        attachedWindow?.endEditing(true)
    }
}
