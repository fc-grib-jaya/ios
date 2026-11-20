//
//  FormView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

struct FormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: FormViewModel
    @State private var namaCattle = ""
    @State private var jenisSapi: CattleBreed?
    @State private var genderSapi: CattleGender?
    @State private var bobotCattle: Double?
    @State private var cattlePhoto: UIImage?
    @State private var scanResult: ScanResult?
    @State private var usiaSapi: Int?
    @State private var notes: String?
    @State private var saveError: String?

    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    let onSave: (CattleFormValues) async throws -> Void

    init(
        onScanSession: @escaping (@escaping (ScanResult?) -> Void) -> Void = {
            _ in
        },
        viewModel: FormViewModel,
        onSave: @escaping (CattleFormValues) async throws -> Void = { _ in }
    ) {
        self.onScanSession = onScanSession
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }

    private var isCurrentPageValid: Bool {
        isPageValid(viewModel.index)
    }

    private func isPageValid(_ pageIndex: Int) -> Bool {
        switch pageIndex {
        case 0:
            return !namaCattle.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty && usiaSapi != nil
        case 1:
            return jenisSapi != nil && genderSapi != nil
        case 2:
            guard let bobotCattle else { return false }
            return bobotCattle > 0 && bobotCattle.isFinite
        default:
            return true
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()

            VStack {
                FormPageContent(
                    page: viewModel.pages[viewModel.index],
                    isActive: true,
                    namaCattle: $namaCattle,
                    jenisSapi: $jenisSapi,
                    genderSapi: $genderSapi,
                    bobotCattle: $bobotCattle,
                    cattlePhoto: $cattlePhoto,
                    scanResult: $scanResult,
                    usiaSapi: $usiaSapi,
                    onScanSession: { completion in
                        onScanSession { result in
                            viewModel.index = 2
                            completion(result)
                        }
                    },
                    notes: $notes
                )
                
                Button(viewModel.buttonTitle) {
                    primaryButtonTapped()
                }
                .appButtonStyle(.primary)
                .disabled(!isCurrentPageValid)
                .opacity(isCurrentPageValid ? 1 : 0.5)
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .background(KeyboardDismissOverlay())
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .onChange(of: viewModel.index) { _, _ in
            dismissKeyboard()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if viewModel.index > 0 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.index -= 1
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: viewModel.index > 0 ? "chevron.left" : "xmark")
                }
                .accessibilityLabel(viewModel.index > 0 ? "Kembali" : "Tutup")
            }

            ToolbarItem(placement: .topBarTrailing) {
                PageCount(pageNum: viewModel.index + 1, totalPage: viewModel.pages.count)
                    .accessibilityLabel(
                        "Form \(viewModel.index + 1) dari \(viewModel.pages.count)"
                    )
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .alert(
            "Gagal menyimpan sapi",
            isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                saveError = nil
            }
        } message: {
            Text(saveError ?? "Terjadi kesalahan.")
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func primaryButtonTapped() {
        guard isCurrentPageValid else { return }

        if viewModel.isLastPage {
            guard let jenisSapi,
                let genderSapi,
                let bobotCattle,
                let usiaSapi
            else {
                return
            }

            let values = CattleFormValues(
                name: namaCattle.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                dateAcquired: Date(),
                breed: jenisSapi,
                gender: genderSapi,
                recordedAge: usiaSapi,
                bodyWeight: bobotCattle,
                chestGirth: scanResult?.girth,
                bodyLength: scanResult?.lengthCM,
                cattleImage: cattlePhoto,
                notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty == true
                    ? nil
                    : notes
            )

            Task {
                do {
                    try await onSave(values)
                    dismiss()
                } catch {
                    saveError = error.localizedDescription
                }
            }
        } else {
            viewModel.primaryTapped()
        }
    }
}

private struct KeyboardDismissOverlay: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        DispatchQueue.main.async {
            context.coordinator.install(in: view.window)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.install(in: uiView.window)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.remove()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var window: UIWindow?
        private weak var gestureRecognizer: UITapGestureRecognizer?

        func install(in window: UIWindow?) {
            guard let window, self.window !== window else {
                return
            }

            remove()

            let gestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self

            window.addGestureRecognizer(gestureRecognizer)
            self.window = window
            self.gestureRecognizer = gestureRecognizer
        }

        func remove() {
            if let gestureRecognizer {
                window?.removeGestureRecognizer(gestureRecognizer)
            }

            gestureRecognizer = nil
            window = nil
        }

        @objc
        private func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var view = touch.view

            while let currentView = view {
                if currentView is UITextField || currentView is UITextView {
                    return false
                }

                view = currentView.superview
            }

            return true
        }
    }
}

private struct FormPageContent: View {
    let page: FormPage
    let isActive: Bool
    @Binding var namaCattle: String
    @Binding var jenisSapi: CattleBreed?
    @Binding var genderSapi: CattleGender?
    @Binding var bobotCattle: Double?
    @Binding var cattlePhoto: UIImage?
    @Binding var scanResult: ScanResult?
    @Binding var usiaSapi: Int?
    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    @Binding var notes: String?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            pageVisual
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var pageVisual: some View {
        switch page.id {
        case 0:
            FirstPageForm(
                cattlePhoto: $cattlePhoto,
                cattleName: $namaCattle,
                cattleAge: $usiaSapi,
                notes: $notes
            )
        case 1:
            SecondPageForm(
                cattleBreed: $jenisSapi,
                cattleGender: $genderSapi
            )
        default:
            ThirdPageForm(
                bobotCattle: $bobotCattle,
                cattlePhoto: $cattlePhoto,
                scanResult: $scanResult,
                jenisSapi: $jenisSapi,
                genderSapi: $genderSapi,
                isActive: isActive,
                onScanSession: onScanSession
            )
        }
    }
}

#Preview {
    NavigationStack {
        FormView(viewModel: FormViewModel())
    }
}
