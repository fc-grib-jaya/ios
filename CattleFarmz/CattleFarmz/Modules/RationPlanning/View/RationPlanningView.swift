//
//  RationPlanningView.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//


import SwiftUI

struct RationPlanningView: View {
    @State private var viewModel: RationPlanningViewModel
    @State private var showsFeedCatalog = false

    init(viewModel: RationPlanningViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            profileSection
            selectedFeedsSection

            Section {
                GlassPrimaryButton("Calculate nutrients") {
                    viewModel.calculate()
                }
                .disabled(viewModel.selectedFeeds.isEmpty)
            }

            if let result = viewModel.result {
                resultSections(result)
            }
        }
        .navigationTitle("Ration planning")
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showsFeedCatalog) {
            NavigationStack {
                feedCatalog
            }
        }
        .task {
            viewModel.load()
        }
        .alert(
            "Check your input",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: {
                    if !$0 {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var profileSection: some View {
        Section("Cattle profile") {
            Picker(
                "Production type",
                selection: Binding(
                    get: { viewModel.profile.productionType },
                    set: { viewModel.selectProductionType($0) }
                )
            ) {
                ForEach(CattleProductionType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker(
                "Sex",
                selection: Binding(
                    get: { viewModel.profile.sex },
                    set: { viewModel.selectSex($0) }
                )
            ) {
                ForEach(CattleSex.allCases) { sex in
                    Text(sex.rawValue).tag(sex)
                }
            }

            Picker(
                "Production stage",
                selection: Binding(
                    get: { viewModel.profile.stage },
                    set: { viewModel.selectStage($0) }
                )
            ) {
                ForEach(viewModel.profile.availableStages) { stage in
                    Text(stage.rawValue).tag(stage)
                }
            }

            numberField(
                "Body weight (kg)",
                text: $viewModel.bodyWeightText
            )

            HStack {
                Text("Number of cattle")

                TextField(
                    "Animals",
                    text: $viewModel.animalCountText
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
            }

            if viewModel.profile.usesWeightGainTarget {
                numberField(
                    "Target gain (kg/day)",
                    text: $viewModel.dailyWeightGainText
                )
            }

            if viewModel.profile.usesMilkProduction {
                numberField(
                    "Milk production (liters/day)",
                    text: $viewModel.milkProductionText
                )
            }
        }
    }
    
    private var selectedFeedsSection: some View {
        Section {
            Button {
                showsFeedCatalog = true
            } label: {
                Label("Choose feeds", systemImage: "plus.circle")
            }

            if viewModel.selectedFeeds.isEmpty {
                Text("Choose at least one feed to begin.")
                    .foregroundStyle(AppColor.Text.secondary)
            }

            ForEach(viewModel.selectedFeeds) { feed in
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.sm
                ) {
                    HStack {
                        Text(feed.name)
                            .font(AppFont.headline)

                        Spacer()

                        Button {
                            viewModel.removeFeed(feed)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Remove \(feed.name)")
                    }

                    numberField(
                        "Kilograms",
                        text: Binding(
                            get: {
                                viewModel.amountText(for: feed)
                            },
                            set: {
                                viewModel.updateAmount($0, for: feed)
                            }
                        )
                    )
                }
            }
        } header: {
            Text("Feed amounts")
        } footer: {
            Text("Enter kilograms per animal per day.")
        }
    }
    
    private var feedCatalog: some View {
        List {
            Section {
                Picker(
                    "Category",
                    selection: $viewModel.selectedCategory
                ) {
                    Text("All").tag(FeedCategory?.none)

                    ForEach(FeedCategory.allCases) { category in
                        Text(category.rawValue)
                            .tag(Optional(category))
                    }
                }

                Text(
                    "\(viewModel.filteredFeeds.count) feeds · "
                    + "\(viewModel.selectedFeedIDs.count) selected"
                )
                .font(AppFont.caption)
                .foregroundStyle(AppColor.Text.secondary)
            }

            ForEach(viewModel.filteredFeeds) { feed in
                Section {
                    Button {
                        viewModel.toggleFeed(feed)
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(
                                systemName:
                                    viewModel.selectedFeedIDs.contains(feed.id)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )

                            VStack(
                                alignment: .leading,
                                spacing: AppSpacing.xs
                            ) {
                                Text(feed.name)
                                    .foregroundStyle(AppColor.Text.primary)

                                Text(feed.category.rawValue)
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.Text.secondary)
                            }
                        }
                    }
                    .accessibilityLabel(
                        viewModel.selectedFeedIDs.contains(feed.id)
                        ? "Deselect \(feed.name)"
                        : "Select \(feed.name)"
                    )

                    DisclosureGroup("Nutrient content") {
                        feedNutrientRows(feed.nutrients)
                    }
                }
            }

            if viewModel.filteredFeeds.isEmpty {
                Text("No feeds match your search.")
                    .foregroundStyle(AppColor.Text.secondary)
            }
        }
        .navigationTitle("Choose feeds")
        .searchable(
            text: $viewModel.searchText,
            prompt: "Search feed names"
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    showsFeedCatalog = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func resultSections(
        _ result: RationCalculationResult
    ) -> some View {
        Section("Daily totals") {
            LabeledContent(
                "Number of cattle",
                value: result.profile.animalCount.formatted()
            )

            LabeledContent(
                "Feed per animal",
                value: "\(resultNumber(result.kilogramsPerAnimalPerDay)) kg"
            )

            LabeledContent(
                "Feed for herd",
                value: "\(resultNumber(result.kilogramsPerHerdPerDay)) kg"
            )

            LabeledContent(
                "Crude protein per animal",
                value: "\(resultNumber(result.proteinKilogramsPerAnimalPerDay)) kg"
            )

            LabeledContent(
                "TDN per animal",
                value: "\(resultNumber(result.tdnKilogramsPerAnimalPerDay)) kg"
            )
        }

        Section("Composition · per animal / day") {
            ForEach(result.items) { item in
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.sm
                ) {
                    Text(item.ingredient.name)
                        .font(AppFont.headline)

                    LabeledContent(
                        "Feed per animal",
                        value: "\(resultNumber(item.kilogramsPerAnimalPerDay)) kg"
                    )

                    LabeledContent(
                        "Feed for herd",
                        value: "\(resultNumber(item.kilogramsPerAnimalPerDay * Double(result.profile.animalCount))) kg"
                    )

                    LabeledContent(
                        "Crude protein per animal",
                        value: "\(resultNumber(item.kilogramsPerAnimalPerDay * (item.ingredient.nutrients.crudeProteinPercent / 100))) kg"
                    )

                    LabeledContent(
                        "TDN per animal",
                        value: "\(resultNumber( (item.ingredient.nutrients.totalDigestibleNutrientsPercent / 100))) kg"
                    )
                }
            }
        }

        Section {
            nutrientComparisonRows(result)
        } header: {
            Text("Nutrient comparison")
        } footer: {
            Text(
                "Concentrations retain the source dataset basis. "
                + "Meeting reference minima does not establish "
                + "complete nutritional balance or feed safety."
            )
        }

        Section("Feed proportions") {
            ForEach(FeedCategory.allCases) { category in
                LabeledContent(
                    category.rawValue,
                    value: "\(resultNumber(result.sharePercent(for: category)))%"
                )
            }
        }

        if !result.warnings.isEmpty {
            Section("Warnings") {
                ForEach(result.warnings, id: \.self) { warning in
                    Label(
                        warning,
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(Color.primary)
                }
            }
        }
    }
    
    private func nutrientComparisonRows(
        _ result: RationCalculationResult
    ) -> some View {
        let actual = result.nutrients
        let required = result.requirements

        let rows: [(String, Double?, Double?, String)] = [
            (
                "Crude protein",
                actual.crudeProteinPercent,
                required.crudeProteinPercent,
                "%"
            ),
            (
                "TDN",
                actual.totalDigestibleNutrientsPercent,
                required.totalDigestibleNutrientsPercent,
                "%"
            ),
            (
                "Calcium",
                actual.calciumPercent,
                required.calciumPercent,
                "%"
            ),
            (
                "Phosphorus",
                actual.phosphorusPercent,
                required.phosphorusPercent,
                "%"
            ),
            (
                "Magnesium",
                actual.magnesiumPercent,
                required.magnesiumPercent,
                "%"
            ),
            ("Iron", actual.ironPPM, required.ironPPM, "ppm"),
            ("Copper", actual.copperPPM, required.copperPPM, "ppm"),
            ("Zinc", actual.zincPPM, required.zincPPM, "ppm")
        ]

        return ForEach(rows, id: \.0) { row in
            LabeledContent {
                VStack(
                    alignment: .trailing,
                    spacing: AppSpacing.xs
                ) {
                    Text(resultMeasurement(row.1, unit: row.3))

                    Text(
                        "Reference: \(resultMeasurement(row.2, unit: row.3))"
                    )
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Text.secondary)

                    if let actualValue = row.1,
                       let referenceValue = row.2 {
                        Text(
                            actualValue < referenceValue
                            ? "Below reference"
                            : "At or above reference"
                        )
                        .font(AppFont.caption)
                        .foregroundStyle(
                            actualValue < referenceValue
                            ? AppColor.Text.primary
                            : AppColor.Text.secondary
                        )
                    } else {
                        Text("Comparison unavailable")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.Text.secondary)
                    }
                }
            } label: {
                Text(row.0)
            }
        }
    }

    private func resultNumber(_ value: Double) -> String {
        value.formatted(
            .number.precision(.fractionLength(2))
        )
    }

    private func resultMeasurement(
        _ value: Double?,
        unit: String
    ) -> String {
        guard let value else {
            return "Not available"
        }

        return "\(resultNumber(value)) \(unit)"
    }
    
    private func feedNutrientRows(
        _ nutrients: NutrientContent
    ) -> some View {
        let rows: [(String, Double?, String)] = [
            ("Crude protein", nutrients.crudeProteinPercent, "%"),
            ("TDN", nutrients.totalDigestibleNutrientsPercent, "%"),
            ("Calcium", nutrients.calciumPercent, "%"),
            ("Phosphorus", nutrients.phosphorusPercent, "%"),
            ("Magnesium", nutrients.magnesiumPercent, "%"),
            ("Iron", nutrients.ironPPM, "ppm"),
            ("Copper", nutrients.copperPPM, "ppm"),
            ("Zinc", nutrients.zincPPM, "ppm")
        ]

        return ForEach(rows, id: \.0) { row in
            LabeledContent(
                row.0,
                value: nutrientText(row.1, unit: row.2)
            )
        }
    }

    private func nutrientText(
        _ value: Double?,
        unit: String
    ) -> String {
        guard let value else {
            return "Not available"
        }

        let number = value.formatted(
            .number.precision(.fractionLength(2))
        )

        return "\(number) \(unit)"
    }
    

    private func numberField(
        _ title: String,
        text: Binding<String>
    ) -> some View {
        HStack {
            Text(title)

            TextField(title, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        RationPlanningView(
            viewModel: RationPlanningViewModel(
                feedProvider: {
                    let text = try BundledFeedCSVReader().read()
                    let ingredients = try FeedCSVParser().parse(text)

                    return Array(ingredients.prefix(3))
                },
                calculator: ManualRationCalculator { profile in
                    CattleNutritionDefaults.requirements(
                        for: profile.productionType,
                        stage: profile.stage
                    )
                }
            )
        )
    }
}
