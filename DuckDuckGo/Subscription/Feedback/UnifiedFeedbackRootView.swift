//
//  UnifiedFeedbackRootView.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

struct UnifiedFeedbackRootView: View {
    @StateObject var viewModel: UnifiedFeedbackFormViewModel

    var body: some View {
        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormTitle, sources: UnifiedFeedbackReportType.self, selection: $viewModel.selectedReportType) {
            if let selectedReportType = viewModel.selectedReportType {
                switch UnifiedFeedbackReportType(rawValue: selectedReportType) {
                case nil:
                    EmptyView()
                case .general:
                    DefaultIssueDescriptionFormView(viewModel: viewModel,
                                                    navigationTitle: UserText.browserFeedbackReportProblem,
                                                    label: UserText.browserFeedbackGeneralFeedback) {}
                case .requestFeature:
                    DefaultIssueDescriptionFormView(viewModel: viewModel,
                                                    navigationTitle: UserText.browserFeedbackRequestFeature,
                                                    label: UserText.browserFeedbackRequestFeature) {}
                case .reportIssue:
                    reportProblemView()
                }
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.process(action: .reportActions)
            }
        }
    }

    @ViewBuilder
    func reportProblemView() -> some View {
        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormReportProblemTitle, sources: UnifiedFeedbackCategory.self, selection: $viewModel.selectedCategory) {
            Group {
                if let selectedCategory = viewModel.selectedCategory {
                    switch UnifiedFeedbackCategory(rawValue: selectedCategory) {
                    case nil:
                        EmptyView()
                    case .subscription:
                        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormReportPProProblemTitle, sources: PrivacyProFeedbackSubcategory.self, selection: $viewModel.selectedSubcategory) {
                            VPNIssueDescriptionFormView(viewModel: viewModel) {}
                        }
                    case .vpn:
                        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormReportVPNProblemTitle, sources: VPNFeedbackSubcategory.self, selection: $viewModel.selectedSubcategory) {
                            VPNIssueDescriptionFormView(viewModel: viewModel) {}
                        }
                    case .pir:
                        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormReportPIRProblemTitle, sources: PIRFeedbackSubcategory.self, selection: $viewModel.selectedSubcategory) {
                            VPNIssueDescriptionFormView(viewModel: viewModel) {}
                        }
                    case .itr:
                        UnifiedFeedbackCategoryView(UserText.pproFeedbackFormReportITRProblemTitle, sources: ITRFeedbackSubcategory.self, selection: $viewModel.selectedSubcategory) {
                            VPNIssueDescriptionFormView(viewModel: viewModel) {}
                        }
                    }
                }
            }
            .onFirstAppear {
                Task {
                    await viewModel.process(action: .reportSubcategory)
                }
            }
        }
        .onFirstAppear {
            Task {
                await viewModel.process(action: .reportCategory)
            }
        }
    }
}

struct UnifiedFeedbackCategoryView<Category: FeedbackCategoryProviding, Destination: View>: View where Category.AllCases == [Category], Category.RawValue == String {
    let title: String
    let prompt: String
    let sources: Category.Type
    let selection: Binding<String?>
    let destination: () -> Destination

    init(_ title: String,
         prompt: String = UserText.pproFeedbackFormSelectCategoryTitle,
         sources: Category.Type,
         selection: Binding<String?>,
         @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.prompt = prompt
        self.sources = sources
        self.selection = selection
        self.destination = destination
    }

    var body: some View {
        VStack {
            List(selection: selection) {
                Section {
                    ForEach(sources.allCases) { option in
                        NavigationLink {
                            destination()
                        } label: {
                            Text(option.displayName)
                                .daxBodyRegular()
                                .foregroundColor(.init(designSystemColor: .textPrimary))
                        }
                        .tag(option.rawValue)
                    }
                } header: {
                    Text(prompt)
                }
            }
            .listRowBackground(Color(designSystemColor: .surface))
        }
        .applyInsetGroupedListStyle()
        .navigationTitle(title)
    }
}

private struct DefaultIssueDescriptionFormView: View {
    @ObservedObject var viewModel: UnifiedFeedbackFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool

    let navigationTitle: String
    let label: String

    var onDismiss: () -> Void

    var body: some View {
        configuredForm()
            .applyBackground()
            .navigationTitle(navigationTitle)
            .onFirstAppear {
                Task {
                    await viewModel.process(action: .reportSubmitShow)
                }
            }
    }

    @ViewBuilder
    private func form() -> some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
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
                    }
                    .foregroundColor(.secondary)
                    .background(Color(designSystemColor: .background))
                    .padding(16)
                    .daxFootnoteRegular()
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
    private func textEditor() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            TextEditor(text: $viewModel.feedbackFormText)
                .font(.body)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                .frame(height: 100)
                .fixedSize(horizontal: false, vertical: true)
                .onChange(of: viewModel.feedbackFormText) {
                    viewModel.feedbackFormText = String($0.prefix(1000))
                }
        }
    }

    @ViewBuilder
    private func submitButton() -> some View {
        Button {
            Task {
                _ = await viewModel.process(action: .submit)
            }
            dismiss()
            onDismiss()
        } label: {
            Text(UserText.vpnFeedbackFormButtonSubmit)
        }
        .buttonStyle(UnifiedFeedbackFormButtonStyle())
        .padding(16)
    }
}

private struct VPNIssueDescriptionFormView: View {
    @ObservedObject var viewModel: UnifiedFeedbackFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool

    var onDismiss: () -> Void

    var body: some View {
        configuredForm()
            .applyBackground()
            .navigationTitle(UserText.browserFeedbackReportProblem)
            .onFirstAppear {
                Task {
                    await viewModel.process(action: .reportSubmitShow)
                }
            }
    }

    @ViewBuilder
    private func form() -> some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        header()
                            .padding(.horizontal, 4)
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
                        footer()
                            .padding(.horizontal, 4)
                    }
                    .foregroundColor(.secondary)
                    .background(Color(designSystemColor: .background))
                    .padding(16)
                    .daxFootnoteRegular()
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
        Text(UserText.vpnFeedbackFormText1)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .onOpenURL { url in
                Task {
                    await viewModel.process(action: .reportFAQClick)
                    await UIApplication.shared.open(url)
                }
            }

        Spacer()
            .frame(height: 1)
            .id(1)
    }

    @ViewBuilder
    private func footer() -> some View {
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

    @ViewBuilder
    private func textEditor() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(UserText.pproFeedbackFormTextBoxTitle)
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            TextEditor(text: $viewModel.feedbackFormText)
                .font(.body)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                .frame(height: 100)
                .fixedSize(horizontal: false, vertical: true)
                .onChange(of: viewModel.feedbackFormText) {
                    viewModel.feedbackFormText = String($0.prefix(1000))
                }
        }
    }

    @ViewBuilder
    private func submitButton() -> some View {
        Button {
            Task {
                _ = await viewModel.process(action: .submit)
            }
            dismiss()
            onDismiss()
        } label: {
            Text(UserText.vpnFeedbackFormButtonSubmit)
        }
        .buttonStyle(UnifiedFeedbackFormButtonStyle())
        .padding(16)
    }
}

private struct UnifiedFeedbackFormButtonStyle: ButtonStyle {

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
