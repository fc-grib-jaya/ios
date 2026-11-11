//
//  RationPlanningView.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 09/11/26.
//

import SwiftUI

struct RationPlanningView: View {
    @Bindable private var rationVM: RationPlanningViewModel
    @State private var showsFeedCatalog = false
    let cattleName: String
    let cattleDetails: String
    
    private let onShowAnalysis: (RationCalculationResult) -> Void

    init(
        rationVM: RationPlanningViewModel,
        cattleName: String = "Profil sapi",
        cattleDetails: String = "",
        onShowAnalysis: @escaping (RationCalculationResult) -> Void
    ) {
        _rationVM = Bindable(wrappedValue: rationVM)
        self.cattleName = cattleName
        self.cattleDetails = cattleDetails
        self.onShowAnalysis = onShowAnalysis
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ADGCard(
                    cattleName: cattleName,
                    cattleDetails: cattleDetails,
                    estimatedWeightKilograms: Double(rationVM.bodyWeightText.replacingOccurrences(of: ",", with: ".")),
                    targetADG: Binding(
                        get: { Double(rationVM.dailyWeightGainText) ?? 0.5 },
                        set: { rationVM.dailyWeightGainText = String($0) }
                    ),
                    targetRange: 0.2...2,
                    targetStep: 0.1,
                    referenceADG: nil
                )
                
                HStack {
                    Text("Bobot sapi (kg)")
                    TextField("Masukkan bobot", text: $rationVM.bodyWeightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                FeedAmountsCard(
                    rationVM: rationVM,
                    onTap: {showsFeedCatalog = true}
                )
                
                HStack {
                    Text("Total pemberian")

                    Spacer()

                    if let total = rationVM.totalFeedKilogramsPerAnimalPerDay {
                        Text(
                            total.formatted(
                                .number.precision(.fractionLength(0...2))
                            )
                        )
                        .font(AppFont.largeTitle)
                        Text("kg / hari")
                    } else {
                        Text("Periksa jumlah pakan")
                    }
                }
                .padding(AppSpacing.md)
                .background{
                    // MARK: belum make AppRadius
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColor.Card.background)
                        .shadow(
                            color: .black.opacity(0.1),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                }
                
                Button {
                    rationVM.calculate()
                    if let result = rationVM.result {
                        onShowAnalysis(result)
                    }
                } label: {
                    Text("Evaluasi pakan")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500).interactive(), in: Capsule())
                .disabled(rationVM.selectedFeeds.isEmpty)
                
                if let error = rationVM.errorMessage {
                    Text(error)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Text.secondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .navigationTitle("Pakan Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsFeedCatalog, content: {
            NavigationStack {
                FeedCatalogView(rationVM: rationVM)
                    .presentationDragIndicator(.visible)
            }
        })
        .task {
            rationVM.load()
        }
    }
}

#Preview {
    RationPlanningPreview()
}

#if DEBUG
private struct RationPlanningPreview: View {
    @State private var coordinator = AppCoordinator()
    @State private var analysisResult: RationCalculationResult?
    @State private var rationVM = DIContainer.preview.makeRationPlanningViewModel()

    var body: some View {
        NavigationStack(path: $coordinator.rationPath) {
            RationPlanningView(
                rationVM: rationVM,
                onShowAnalysis: { result in
                    analysisResult = result
                    coordinator.goToRationAnalysis()
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                if let result = analysisResult {
                    switch route {
                    case .rationAnalysis:
                        RationAnalysisView(
                            result: result,
                            onShowDetails: coordinator.goToRationAnalysisDetail
                        )
                    case .rationAnalysisDetail:
                        DetailAnalysisView(result: result)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
#endif
