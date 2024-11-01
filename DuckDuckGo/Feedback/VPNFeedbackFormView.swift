//
//  VPNFeedbackFormView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import NetworkProtection

struct VPNFeedbackFormCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    let collector = DefaultVPNMetadataCollector(
        statusObserver: AppDependencyProvider.shared.connectionObserver,
        serverInfoObserver: AppDependencyProvider.shared.serverInfoObserver
    )

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(VPNFeedbackCategory.allCases, id: \.self) { category in
                        NavigationLink {
                            VPNFeedbackFormView(viewModel: VPNFeedbackFormViewModel(metadataCollector: collector, category: category)) {
                                dismiss()
                                DispatchQueue.main.async {
                                    ActionMessageView.present(message: UserText.vpnFeedbackFormSubmittedMessage,
                                                              presentationLocation: .withoutBottomBar)
                                }
                            }
                        } label: {
                            Text(category.displayName)
                                .daxBodyRegular()
                                .foregroundColor(.init(designSystemColor: .textPrimary))
                        }
                    }
                } header: {
                    header()
                }
                .increaseHeaderProminence()
            }
            .listRowBackground(Color(designSystemColor: .surface))
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(UserText.netPStatusViewShareFeedback)
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            Spacer(minLength: 0)
            VStack(alignment: .center, spacing: 8) {
                Text(UserText.vpnFeedbackFormTitle)
                    .daxHeadline()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textPrimary))
                Text(UserText.vpnFeedbackFormCategorySelect)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textSecondary))
            }
            .padding(.vertical, 16)
            .background(Color(designSystemColor: .background))
            Spacer(minLength: 0)
        }
    }
}

struct VPNFeedbackFormView: View {
    @StateObject var viewModel: VPNFeedbackFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool

    var onDismiss: () -> Void

    var body: some View {
        configuredForm()
        .applyBackground()
        .navigationTitle(UserText.netPStatusViewShareFeedback)
    }

    @ViewBuilder
    private func form() -> some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    header()
                    textEditor()
                        .focused($isTextEditorFocused)
                        .onChange(of: isTextEditorFocused) { isFocused in
                            guard isFocused else { return }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    scrollView.scrollTo(1, anchor: .top)
                                }
                            }
                        }
                    submitButton()
                        .disabled(!viewModel.submitButtonEnabled)
                }
            }
        }
    }

    @ViewBuilder
    private func configuredForm() -> some View {
        if #available(iOS 16, *) {
            form().scrollDismissesKeyboard(.interactively)
        } else {
            form()
        }
    }

    @ViewBuilder
    private func header() -> some View {
        HStack {
            Spacer(minLength: 0)
            VStack(alignment: .center, spacing: 8) {
                Text(UserText.vpnFeedbackFormTitle)
                    .daxHeadline()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textPrimary))
                Text(viewModel.categoryName)
                    .daxFootnoteRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.init(designSystemColor: .textSecondary))
            }
            .padding(.vertical, 16)
            .background(Color(designSystemColor: .background))
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func textEditor() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(UserText.vpnFeedbackFormText1)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
                .frame(height: 1)
                .id(1)

            TextEditor(text: $viewModel.feedbackFormText)
                .font(.body)
                .foregroundColor(.primary)
                .frame(height: 100)
                .fixedSize(horizontal: false, vertical: true)
                .onChange(of: viewModel.feedbackFormText) {
                    viewModel.feedbackFormText = String($0.prefix(1000))
                }
                .padding(EdgeInsets(top: 3.0, leading: 6.0, bottom: 5.0, trailing: 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color(designSystemColor: .textPrimary), lineWidth: 0.4)
                        RoundedRectangle(cornerRadius: 8.0)
                            .fill(Color(designSystemColor: .panel))
                    }
                )

            Text(UserText.vpnFeedbackFormText2)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading) {
                Text(UserText.vpnFeedbackFormText3)
                Text(UserText.vpnFeedbackFormText4)
            }

            Text(UserText.vpnFeedbackFormText5)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(.secondary)
        .background(Color(designSystemColor: .background))
        .padding(16)
        .daxFootnoteRegular()
    }

    @ViewBuilder
    private func submitButton() -> some View {
        Button {
            Task {
                _ = await viewModel.sendFeedback()
            }
            dismiss()
            onDismiss()
        } label: {
            Text(UserText.vpnFeedbackFormButtonSubmit)
        }
        .buttonStyle(VPNFeedbackFormButtonStyle())
        .padding(16)
    }
}

private struct VPNFeedbackFormButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color(designSystemColor: .accent))
            .cornerRadius(8)
            .daxButton()
            .opacity(isEnabled ? 1.0 : 0.4)

    }

}
