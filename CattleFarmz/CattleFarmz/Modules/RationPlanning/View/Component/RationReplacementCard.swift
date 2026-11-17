import SwiftUI

struct RationReplacementCard: View {
    @Bindable var viewModel: RationRecommendationViewModel
    @State private var isExpanded = true
    @FocusState private var isPortionFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(viewModel.selected.removedIngredient.name + " → " + viewModel.selected.addedIngredient.name)
                .font(AppFont.title)
            DisclosureGroup("Opsi pilihan perbaikan", isExpanded: $isExpanded) {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.alternatives) { option in
                        Button { viewModel.select(option) } label: {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: option.id == viewModel.selected.id ? "smallcircle.filled.circle.fill" : "circle.fill")
                                    .foregroundStyle(option.id == viewModel.selected.id ? AppColor.Primitive.Primary.shade500 : AppColor.Primitive.Primary.shade200)
                                Text(option.addedIngredient.name).font(AppFont.headline)
                                Spacer(minLength: AppSpacing.xs)
                                Text(option.addedIngredient.nutrients.totalDigestibleNutrientsPercent.map { "TDN " + evaluationNumber($0) + "%" } ?? "TDN —")
                                    .foregroundStyle(AppColor.Text.secondary)
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(option.id == viewModel.selected.id ? .isSelected : [])
                    }
                }
                .padding(.top, AppSpacing.sm)
            }
            .tint(AppColor.Text.primary)
            .padding(AppSpacing.md)
            .background(AppColor.Surface.inset, in: RoundedRectangle(cornerRadius: AppRadius.large))
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Porsi yang diganti").font(AppFont.headline)
                    Text("Dari " + evaluationNumber(viewModel.sourceAmount) + " kg/hari").font(AppFont.body)
                }
                Spacer()
                HStack(spacing: AppSpacing.xs) {
                    TextField("0", text: Binding(
                        get: { viewModel.portionText },
                        set: { viewModel.updatePortion($0) }
                    ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($isPortionFocused)
                        .onSubmit { viewModel.finishEditingPortion() }
                        .accessibilityLabel("Porsi yang diganti dalam kilogram")
                    Text("kg").foregroundStyle(AppColor.Text.secondary)
                }
                .font(AppFont.body)
                .frame(width: 76)
                .frame(minHeight: 44)
                .padding(.horizontal, AppSpacing.sm)
                .background(AppColor.Surface.inset, in: RoundedRectangle(cornerRadius: AppRadius.small))
                .overlay { RoundedRectangle(cornerRadius: AppRadius.small).stroke(AppColor.Primitive.Primary.shade500) }
                .contentShape(Rectangle())
                .onTapGesture { isPortionFocused = true }
                .onChange(of: isPortionFocused) { _, focused in
                    if !focused { viewModel.finishEditingPortion() }
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).font(AppFont.caption).foregroundStyle(AppColor.Primitive.Secondary.shade600)
            }
        }
        .evaluationCard()
    }
}

#if DEBUG
#Preview {
    RationReplacementCard(viewModel: RationRecommendationPreviewData.viewModel())
        .padding(AppSpacing.md)
}
#endif
