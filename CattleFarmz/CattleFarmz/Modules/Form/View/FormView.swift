//
//  FormView.swift
//  CattleFarmz
//

import SwiftUI

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
        onScanSession: @escaping (@escaping (ScanResult?) -> Void) -> Void = { _ in },
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
            return !namaCattle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && usiaSapi != nil
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

            VStack(spacing: AppSpacing.xl) {
                TabView(selection: $viewModel.index) {
                    ForEach(viewModel.pages) { page in
                        FormPageContent(
                            page: page,
                            isActive: viewModel.index == page.id,
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
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: viewModel.index) { oldIndex, newIndex in
                    guard newIndex > oldIndex,
                          !isPageValid(oldIndex)
                    else {
                        return
                    }

                    viewModel.index = oldIndex
                }

                Button(viewModel.buttonTitle) {
                    primaryButtonTapped()
                }
                .appButtonStyle(.primary)
                .disabled(!isCurrentPageValid)
                .opacity(isCurrentPageValid ? 1 : 0.5)
                .padding(.horizontal, AppSpacing.md)

                HStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.pages.indices, id: \.self) { pageIndex in
                        Capsule()
                            .fill(
                                pageIndex == viewModel.index
                                    ? AppColor.Primitive.Primary.shade500
                                    : AppColor.Text.muted
                            )
                            .frame(
                                width: pageIndex == viewModel.index ? 24 : 8,
                                height: 8
                            )
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.index)
            }
            .padding(.bottom, AppSpacing.xl)
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
                name: namaCattle.trimmingCharacters(in: .whitespacesAndNewlines),
                dateAcquired: Date(),
                breed: jenisSapi,
                gender: genderSapi,
                recordedAge: usiaSapi,
                bodyWeight: bobotCattle,
                chestGirth: scanResult?.girth,
                bodyLength: scanResult?.lengthCM,
                cattleImage: cattlePhoto,
                notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
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

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var pageVisual: some View {
        switch page.id {
        case 0:
            CattlesNameAgeForm(
                namaCattle: $namaCattle,
                usiaSapi: $usiaSapi,
                isActive: isActive
            )
        case 1:
            CattlesBreedGenderForm(
                jenisSapi: $jenisSapi,
                genderSapi: $genderSapi
            )
        case 2:
            CattlesWeightForm(
                bobotCattle: $bobotCattle,
                cattlePhoto: $cattlePhoto,
                scanResult: $scanResult,
                jenisSapi: $jenisSapi,
                genderSapi: $genderSapi,
                isActive: isActive,
                onScanSession: onScanSession
            )
        default:
            CattlesNotesForm(notes: $notes, isActive: isActive)
        }
    }
}

#Preview {
    FormView(viewModel: FormViewModel())
}
