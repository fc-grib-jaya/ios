//
//  GuestLoginSheetView.swift
//  CattleFarmz
//

import SwiftUI

/// Short sheet collecting the guest name before entering the main interface.
struct GuestLoginSheetView: View {
    @State private var viewModel: GuestLoginSheetViewModel

    init(viewModel: GuestLoginSheetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading) {
                    HStack(spacing: 1) {
                        Text("Nama")
                            .foregroundStyle(AppColor.Text.primary)
                        Text("*")
                            .foregroundStyle(Color.red)
                    }
                    .font(AppFont.body)
                    .padding(.bottom, AppSpacing.xs)

                    TextField("Tuliskan Nama", text: $viewModel.name)
                        .font(AppFont.body)
                        .autocorrectionDisabled()
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Input.background)
                        )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppFont.caption)
                            .foregroundStyle(Color.red)
                            .padding(.top, AppSpacing.xs)
                    }
                }

                Spacer(minLength: 0)

                Button("Login sebagai tamu"){
                    viewModel.submit()
                }
                .appButtonStyle(.primary)
            }
            .padding(AppSpacing.md)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    GuestLoginSheetView(
        viewModel: GuestLoginSheetViewModel(
            repository: MockUserProfileRepository()
        )
    )
}
