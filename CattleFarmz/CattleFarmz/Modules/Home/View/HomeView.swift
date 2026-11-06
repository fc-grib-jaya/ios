//
//  HomeView.swift
//  CattleFarmz
//

import SwiftUI

/// Home screen placeholder with an entry point to the profile page.
///
/// The view never references the profile screen; it asks the `App` layer to
/// navigate by calling `onProfileTap`.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cattlesViewModel: CattlesViewModel
    private let onProfileTap: () -> Void
    private let onExamplePickerTap: () -> Void

    init(
        viewModel: HomeViewModel,
        cattlesViewModel: CattlesViewModel,
        onProfileTap: @escaping () -> Void,
        onExamplePickerTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.onProfileTap = onProfileTap
        self.onExamplePickerTap = onExamplePickerTap
    }

    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            VStack {
                if #available(iOS 26.0, *) {
                    Button("Test haptics") {
                        viewModel.startScan()
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    Button("Test haptics") {
                        viewModel.startScan()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                CattlesView(viewModel: cattlesViewModel)
            }

        }
        .navigationTitle(viewModel.title)
        //        .navigationSubtitle("Urus sapimu sing nggenah")
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {

                    Menu {
                        Button("Opsi 1", systemImage: "star") {
                            // Aksi opsi 1
                        }
                        Button("Opsi 2", systemImage: "gear") {
                            // Aksi opsi 2
                        }
                        Divider()
                        Button(
                            "Hapus",
                            systemImage: "trash",
                            role: .destructive
                        ) {
                            // Delete
                        }
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal.decrease")
                    }
                }
            )
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startScan()
                    onProfileTap()
                } label: {
                    Image(systemName: "camera.fill")
                }
                .accessibilityLabel("Profile")
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    onExamplePickerTap()
                } label: {
                    Label("done", systemImage: "plus")
                }
                .tint(.green)
                .accessibilityLabel("Pick Example")
            }
        }
    }
}

struct SankeyNode: Identifiable {
    let id: String
    let x: CGFloat
    let y: CGFloat
    let height: CGFloat
    let color: Color
    let label: String?
}

struct SankeyFlow: Identifiable {
    let id: String
    let startY: CGFloat
    let endY: CGFloat
    let startHeight: CGFloat
    let endHeight: CGFloat
    let colors: [Color]
}



#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(haptics: NoopHaptics()),
            cattlesViewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            ),
            onProfileTap: {},
            onExamplePickerTap: {}
        )
    }
}

