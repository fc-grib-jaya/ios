//
//  HomeView.swift
//  CattleFarmz
//

import SwiftUI

/// Home screen with an entry point to the profile page and cattle detail pages.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cattlesViewModel: CattlesViewModel
    private let farmerName: String
    private let onProfileTap: () -> Void
    private let onExamplePickerTap: () -> Void
    private let onCardTap: (String) -> Void
    private let onAddCattleTap: () -> Void

    init(
        viewModel: HomeViewModel,
        cattlesViewModel: CattlesViewModel,
        farmerName: String,
        onProfileTap: @escaping () -> Void,
        onExamplePickerTap: @escaping () -> Void,
        onCardTap: @escaping (String) -> Void,
        onAddCattleTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.farmerName = farmerName
        self.onProfileTap = onProfileTap
        self.onExamplePickerTap = onExamplePickerTap
        self.onCardTap = onCardTap
        self.onAddCattleTap = onAddCattleTap
    }
    
    @State private var isFilterPresented = false
    
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
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    HomeCard(
                        Farmer: farmerName,
                        Subtitle: cattlesViewModel.listSubtitle,
                        onAddCattleTap: onAddCattleTap
                    )
                    
                    HStack {
                        Text("Sapi-Sapi Anda")
                            .font(AppFont.mediumBody)
                            .foregroundStyle(
                                AppColor.Primitive.Secondary.shade900
                            )
                        
                        Spacer()
                        
                        Menu {
                            Section {
                                Button {
                                    cattlesViewModel.sortAscending = true
                                } label: {
                                    if cattlesViewModel.sortAscending {
                                        Label(
                                            "Ascending",
                                            systemImage: "checkmark"
                                        )
                                    } else {
                                        Text("Ascending")
                                    }
                                }
                                
                                Button {
                                    cattlesViewModel.sortAscending = false
                                } label: {
                                    if !cattlesViewModel.sortAscending {
                                        Label(
                                            "Descending",
                                            systemImage: "checkmark"
                                        )
                                    } else {
                                        Text("Descending")
                                    }
                                }
                            }
                            
                            Section {
                                Button {
                                    cattlesViewModel.selectSort(.name)
                                } label: {
                                    if cattlesViewModel.sortOption == .name {
                                        Label("Nama", systemImage: "checkmark")
                                    } else {
                                        Text("Nama")
                                    }
                                }
                                
                                Button {
                                    cattlesViewModel.selectSort(.weight)
                                } label: {
                                    if cattlesViewModel.sortOption == .weight {
                                        Label("Bobot", systemImage: "checkmark")
                                    } else {
                                        Text("Bobot")
                                    }
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(AppColor.Primitive.Primary.shade500)
                    }
                    .padding(.horizontal, AppSpacing.md)

                if cattlesViewModel.hasNoVisibleCattle
                        || cattlesViewModel.filteredItems.isEmpty
                    {
                        NoCattleCard()
                            .padding(AppSpacing.md)
                        Spacer()
                    } else {
                        CattlesView(
                            viewModel: cattlesViewModel,
                            onCardTap: onCardTap
                        )
                    }
                }
            }
        }
        .task { await cattlesViewModel.load() }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text("Lem")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(AppColor.Text.primary)
                        .fixedSize()
                    
                    HStack(spacing: 3) {
                        Ellipse()
                            .fill(AppColor.Primitive.Primary.shade400)
                            .frame(width: 13, height: 15)
                        
                        Ellipse()
                            .fill(AppColor.Primitive.Primary.shade400)
                            .frame(width: 13, height: 15)
                    }
                    .padding(.bottom, 6)
                }
                .fixedSize()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Lemu")
            }
            .sharedBackgroundVisibility(.hidden)
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFilterPresented = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundStyle(
                            cattlesViewModel.hasActiveFilter
                            ? AppColor.Primitive.Base.white
                            : Color.black
                        )
                        .frame(width: 44, height: 44)
                        .background {
                            Circle()
                                .fill(
                                    cattlesViewModel.hasActiveFilter
                                    ? AppColor.Primitive.Primary.shade400
                                    : Color.clear
                                )
                        }
                        .glassEffect()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Filter sapi")
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                @Bindable var cattlesViewModel = cattlesViewModel
                CattlesFilterView(
                    selectedBreed: $cattlesViewModel.selectedBreeds,
                    selectedGender: $cattlesViewModel.selectedGenders,
                    selectedAgeRange: $cattlesViewModel.selectedAgeRanges
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var toastManager = ToastManager()
    
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(haptics: NoopHaptics()),
            cattlesViewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator(),
                toast: ToastManager()
            ),
            farmerName: "Dylan",
            onProfileTap: {},
            onExamplePickerTap: {},
            onCardTap: { _ in },
            onAddCattleTap: {}
        )
    }
}
