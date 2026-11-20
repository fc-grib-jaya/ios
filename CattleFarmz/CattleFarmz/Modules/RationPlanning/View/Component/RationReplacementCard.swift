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
                        optionRow(option, target: viewModel.focusTarget)
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
    private func optionRow(_ option: RationRecommendation, target: RationRecommendationTarget) -> some View {
        let isSelected = viewModel.selected.id == option.id
        return Button { viewModel.select(option) } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "smallcircle.filled.circle.fill" : "circle.fill")
                    .foregroundStyle(isSelected ? AppColor.Primitive.Primary.shade500 : AppColor.Primitive.Primary.shade200)
                Text(viewModel.hasDifferentSources
                     ? option.removedIngredient.name + " → " + option.addedIngredient.name
                     : option.addedIngredient.name)
                    .font(AppFont.headline)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: AppSpacing.xs)
                Text(target.value(in: option.addedIngredient.nutrients)
                    .map { target.displayName + " " + evaluationNumber($0) + "%" }
                    ?? (target.displayName + " —"))
                    .foregroundStyle(AppColor.Text.secondary)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

}

#if DEBUG
#Preview {
    RationReplacementCard(viewModel: RationRecommendationPreviewData.viewModel())
        .padding(AppSpacing.md)
}
#endif
