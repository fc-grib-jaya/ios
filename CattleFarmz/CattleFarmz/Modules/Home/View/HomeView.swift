//
//  HomeView.swift
//  CattleFarmz
//

import SwiftUI

/// Home screen with an entry point to the profile page and cattle detail pages.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cattlesViewModel: CattlesViewModel
    private let onProfileTap: () -> Void
    private let onExamplePickerTap: () -> Void
    private let onScanTap: () -> Void
    private let onCardTap: (String) -> Void
    private let onAddCattleTap: () -> Void

    init(
        viewModel: HomeViewModel,
        cattlesViewModel: CattlesViewModel,
        onProfileTap: @escaping () -> Void,
        onExamplePickerTap: @escaping () -> Void,
        onScanTap: @escaping () -> Void,
        onCardTap: @escaping (String) -> Void,
        onAddCattleTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.onProfileTap = onProfileTap
        self.onExamplePickerTap = onExamplePickerTap
        self.onScanTap = onScanTap
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
                        AppColor.Surface.canvas
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
                    VStack(spacing: AppSpacing.xs) {
                        HStack(alignment: .bottom) {
                            Text(
                                """
                                \(Calendar.current.component(.hour, from: Date()) < 11
                                    ? "Pagi"
                                    : Calendar.current.component(.hour, from: Date()) < 15
                                        ? "Siang"
                                        : Calendar.current.component(.hour, from: Date()) < 19
                                            ? "Sore"
                                            : "Malam"),\nBapak Tono!
                                """
                            )
                            .font(AppFont.title)
                            .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                            
                            Spacer()
                            
                            cattlesViewModel.listSubtitle
                                .font(AppFont.body)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.top, AppSpacing.md)
                        .padding(.horizontal, AppSpacing.md)
                        
                        AddCattleButton(onTap: onAddCattleTap)
                            .padding(.vertical, AppSpacing.md)
                    }
                    .background(AppColor.Card.background)
                    .cornerRadius(AppSpacing.Card.compact)
//                    .shadow(radius: 10, x: 0, y: 2)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                    
                    HStack {
                        Text("Sapi Sapi Bapak")
                            .font(AppFont.mediumBody)
                            .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                        
                        Spacer()
                        
                        Menu {
                            Section {
                                Button {
                                    cattlesViewModel.sortAscending = true
                                } label: {
                                    if cattlesViewModel.sortAscending {
                                        Label("Ascending", systemImage: "checkmark")
                                    } else {
                                        Text("Ascending")
                                    }
                                }

                                Button {
                                    cattlesViewModel.sortAscending = false
                                } label: {
                                    if !cattlesViewModel.sortAscending {
                                        Label("Descending", systemImage: "checkmark")
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

                                Button {
                                    cattlesViewModel.selectSort(.age)
                                } label: {
                                    if cattlesViewModel.sortOption == .age {
                                        Label("Umur", systemImage: "checkmark")
                                    } else {
                                        Text("Umur")
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: AppSpacing.xxxs) {
                                Text("Sort")
                                Image(systemName: "arrow.up.arrow.down")
                            }
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Primary.shade500)
                        }
                        .accessibilityLabel("Urutkan")
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.sm)

                    
                    if cattlesViewModel.hasNoVisibleCattle || cattlesViewModel.filteredItems.isEmpty {
                        NoCattleCard(onAddTap: onAddCattleTap)
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
                    Text("Lemb")
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
                .accessibilityLabel("Lemboo")
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
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(haptics: NoopHaptics()),
            cattlesViewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            ),
            onProfileTap: {},
            onExamplePickerTap: {},
            onScanTap: {},
            onCardTap: { _ in },
            onAddCattleTap: {}
        )
    }
}
