//
//  ExamplePickerSheetView.swift
//  CattleFarmz
//

import SwiftUI

/// Sheet that lets the user pick one of the available example options.
struct ExamplePickerSheetView: View {
    @State private var viewModel: ExamplePickerSheetViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ExamplePickerSheetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.options, id: \.self) { option in
                Button {
                    viewModel.select(option)
                    dismiss()
                } label: {
                    HStack {
                        Text(option)
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)
                        Spacer()
                        if option == viewModel.current {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppColor.Button.Primary.background)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ExamplePickerSheetView(
        viewModel: ExamplePickerSheetViewModel(
            current: "Sapi 1",
            options: ["Sapi 1", "Sapi 2", "Sapi 3"],
            onSelect: { _ in }
        )
    )
}
