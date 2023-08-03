//
//  AutofillLoginDetailsView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import DuckUI
import DesignResourcesKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length

struct AutofillLoginDetailsView: View {
    @ObservedObject var viewModel: AutofillLoginDetailsViewModel
    @State private var actionSheetConfirmDeletePresented: Bool = false

    var body: some View {
        listWithBackground
            .alert(isPresented: $viewModel.isShowingAddressUpdateConfirmAlert) {
                let btnLabel = Text(viewModel.toggleConfirmationAlert.button)
                let btnAction = viewModel.togglePrivateEmailStatus
                let button = Alert.Button.default(btnLabel, action: btnAction)
                let cancelBtnLabel = Text(UserText.autofillCancel)
                let cancelBtnAction = { viewModel.refreshprivateEmailStatusBool() }
                let cancelButton = Alert.Button.cancel(cancelBtnLabel, action: cancelBtnAction)
                return Alert(
                    title: Text(viewModel.toggleConfirmationAlert.title),
                    message: Text(viewModel.toggleConfirmationAlert.message),
                    primaryButton: button,
                    secondaryButton: cancelButton)
            }

    }

    
    @ViewBuilder
    private var listWithBackground: some View {
        if #available(iOS 16.0, *) {
            list
                .scrollContentBackground(.hidden)
                .background(Color(designSystemColor: .background))
        } else {
            list
                .background(Color(designSystemColor: .background))
        }
    }
    
    private var list: some View {
        List {
            switch viewModel.viewMode {
            case .edit:
                editingContentView
                    .listRowBackground(Color(designSystemColor: .surface))
            case .view:
                viewingContentView
            case .new:
                editingContentView
                    .listRowBackground(Color(designSystemColor: .surface))
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged({_ in
                viewModel.selectedCell = nil
            }))
        .listStyle(.insetGrouped)
        .animation(.easeInOut)
    }
    
    private var editingContentView: some View {
        Group {
            Section {
                editableCell(UserText.autofillLoginDetailsLoginName,
                             subtitle: $viewModel.title,
                             placeholderText: UserText.autofillLoginDetailsEditTitlePlaceholder,
                             autoCapitalizationType: .words,
                             disableAutoCorrection: false)
            }

            Section {
                editableCell(UserText.autofillLoginDetailsUsername,
                             subtitle: $viewModel.username,
                             placeholderText: UserText.autofillLoginDetailsEditUsernamePlaceholder,
                             keyboardType: .emailAddress)

                if viewModel.viewMode == .new {
                    editableCell(UserText.autofillLoginDetailsPassword,
                                 subtitle: $viewModel.password,
                                 placeholderText: UserText.autofillLoginDetailsEditPasswordPlaceholder,
                                 secure: true)
                } else {
                    EditablePasswordCell(title: UserText.autofillLoginDetailsPassword,
                                         placeholderText: UserText.autofillLoginDetailsEditPasswordPlaceholder,
                                         password: $viewModel.password,
                                         userVisiblePassword: .constant(viewModel.userVisiblePassword),
                                         isPasswordHidden: $viewModel.isPasswordHidden)
                }
            }
            
            Section {
                editableCell(UserText.autofillLoginDetailsAddress,
                             subtitle: $viewModel.address,
                             placeholderText: UserText.autofillLoginDetailsEditURLPlaceholder,
                             keyboardType: .URL)
            }
            
            Section {
                editableMultilineCell(UserText.autofillLoginDetailsNotes,
                                      subtitle: $viewModel.notes)
            }

            if viewModel.viewMode == .edit {
                deleteCell()
            }
        }
    }
    
    private var viewingContentView: some View {
        Group {
            Section {
                AutofillLoginDetailsHeaderView(viewModel: viewModel.headerViewModel)
            }

            if viewModel.usernameIsPrivateEmail {
                privateEmailCredentialsSection()
            } else {
                credentialsSection()
            }

            Section {
                CopyableCell(title: UserText.autofillLoginDetailsAddress,
                             subtitle: viewModel.address,
                             selectedCell: $viewModel.selectedCell,
                             truncationMode: .middle,
                             actionTitle: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsAddress),
                             action: { viewModel.copyToPasteboard(.address) },
                             secondaryActionTitle: viewModel.websiteIsValidUrl ? UserText.autofillOpenWebsitePrompt : nil,
                             secondaryAction: viewModel.websiteIsValidUrl ? { viewModel.openUrl() } : nil)
            }

            Section {
                CopyableCell(title: UserText.autofillLoginDetailsNotes,
                             subtitle: viewModel.notes,
                             selectedCell: $viewModel.selectedCell,
                             truncationMode: .middle,
                             multiLine: true,
                             actionTitle: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsNotes),
                             action: {
                    viewModel.copyToPasteboard(.notes)
                })
            }

            Section {
                deleteCell()
            }
        }
    }

    private func credentialsSection() -> some View {
        Section {
            usernameCell()
            passwordCell()
        }
    }

    @ViewBuilder
    private func privateEmailCredentialsSection() -> some View {

        // If the user is not signed in, we should show the cells separately + the footer message
        if !viewModel.isSignedIn {
            Section {
                usernameCell()
            } footer: {
                if !viewModel.isSignedIn {
                    if #available(iOS 15, *) {
                        var attributedString: AttributedString {
                            let text = String(format: UserText.autofillSignInToManageEmail, UserText.autofillEnableEmailProtection)
                            var attributedString = AttributedString(text)
                            if let range = attributedString.range(of: UserText.autofillEnableEmailProtection) {
                                attributedString[range].foregroundColor = Color(ThemeManager.shared.currentTheme.buttonTintColor)
                            }
                            return attributedString
                        }
                        Text(attributedString)
                            .font(.footnote)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(String(format: UserText.autofillSignInToManageEmail, UserText.autofillEnableEmailProtection))
                            .font(.footnote)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .onTapGesture {
                viewModel.openPrivateEmailURL()
            }

            Section {
                passwordCell()
            }

        // If signed in, we only show the separate sections if the email is manageable
        } else if viewModel.shouldAllowManagePrivateAddress {
            Group {
                Section {
                    usernameCell()
                    privateEmailCell()
                }
                Section {
                    passwordCell()
                }
            }.transition(.opacity)

        } else {
            Section {
                credentialsSection()
            }.transition(.opacity)
        }
    }
    
    private func editableCell(_ title: String,
                              subtitle: Binding<String>,
                              placeholderText: String,
                              secure: Bool = false,
                              autoCapitalizationType: UITextAutocapitalizationType = .none,
                              disableAutoCorrection: Bool = true,
                              keyboardType: UIKeyboardType = .default) -> some View {
        
        VStack(alignment: .leading, spacing: Constants.verticalPadding) {
            Text(title)
                .label4Style()
            
            HStack {
                if secure && viewModel.viewMode == .edit {
                    SecureField(placeholderText, text: subtitle)
                        .label4Style(design: .monospaced)
                } else {
                    ClearTextField(placeholderText: placeholderText,
                                   text: subtitle,
                                   autoCapitalizationType: autoCapitalizationType,
                                   disableAutoCorrection: disableAutoCorrection,
                                   keyboardType: keyboardType,
                                   secure: secure)
                }
            }
        }
        .frame(minHeight: Constants.minRowHeight)
        .listRowInsets(Constants.insets)
    }
    
    // This is seperate from editableCell() because TextEditor doesn't support placeholders, and we don't need placeholders for notes at the moment
    private func editableMultilineCell(_ title: String,
                                       subtitle: Binding<String>,
                                       autoCapitalizationType: UITextAutocapitalizationType = .none,
                                       disableAutoCorrection: Bool = true,
                                       keyboardType: UIKeyboardType = .default) -> some View {
        
        VStack(alignment: .leading, spacing: Constants.verticalPadding) {
            Text(title)
                .label4Style()
            
            MultilineTextEditor(text: subtitle)
        }
        .frame(minHeight: Constants.minRowHeight)
        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
    }

    private func deleteCell() -> some View {
        HStack {
            Button(UserText.autofillLoginDetailsDeleteButton) {
                actionSheetConfirmDeletePresented.toggle()
            }
            .actionSheet(isPresented: $actionSheetConfirmDeletePresented, content: {
                 let deleteAction = ActionSheet.Button.destructive(Text(UserText.autofillLoginDetailsDeleteConfirmationButtonTitle)) {
                     viewModel.delete()
                 }
                 return ActionSheet(title: Text(UserText.autofillLoginDetailsDeleteConfirmationTitle),
                                    message: nil,
                                    buttons: [deleteAction, ActionSheet.Button.cancel()])
             })
             .foregroundColor(Color.red)
        }
        .listRowBackground(Color(designSystemColor: .surface))
    }

    private func usernameCell() -> some View {
        CopyableCell(title: UserText.autofillLoginDetailsUsername,
                     subtitle: viewModel.usernameDisplayString,
                     selectedCell: $viewModel.selectedCell,
                     actionTitle: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsUsername),
                     action: { viewModel.copyToPasteboard(.username) },
                     buttonImageName: "Copy-24",
                     buttonAccessibilityLabel: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsUsername),
                     buttonAction: { viewModel.copyToPasteboard(.username) })

    }

    private func passwordCell() -> some View {
        CopyableCell(title: UserText.autofillLoginDetailsPassword,
                     subtitle: viewModel.userVisiblePassword,
                     selectedCell: $viewModel.selectedCell,
                     isMonospaced: true,
                     actionTitle: viewModel.isPasswordHidden ? UserText.autofillShowPassword : UserText.autofillHidePassword,
                     action: { viewModel.isPasswordHidden.toggle() },
                     secondaryActionTitle: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsPassword),
                     secondaryAction: { viewModel.copyToPasteboard(.password) },
                     buttonImageName: "Copy-24",
                     buttonAccessibilityLabel: UserText.autofillCopyPrompt(for: UserText.autofillLoginDetailsPassword),
                     buttonAction: { viewModel.copyToPasteboard(.password) })
    }


    private func privateEmailCell() -> some View {

        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Duck Address").label4Style()
                Text(viewModel.privateEmailMessage)
                    .font(.footnote)
                    .label4Style(design: .default, foregroundColorLight: .gray50, foregroundColorDark: .gray30)
                
            }
            Spacer(minLength: Constants.textFieldImageSize)
            if viewModel.privateEmailStatus == .active || viewModel.privateEmailStatus == .inactive {
                Toggle("", isOn: $viewModel.privateEmailStatusBool)
                    .frame(width: 80)
                    .toggleStyle(SwitchToggleStyle(tint: Color(ThemeManager.shared.currentTheme.buttonTintColor)))
            } else {
                Image("Alert-Color-16")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

            }
        }
    }

}

private struct MultilineTextEditor: View {
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: $text)
            .frame(maxHeight: .greatestFiniteMagnitude)
    }
}

private struct EditablePasswordCell: View {
    @State private var id = UUID()
    let title: String
    let placeholderText: String
    @Binding var password: String
    @Binding var userVisiblePassword: String
    @Binding var isPasswordHidden: Bool

    @State private var closeButtonVisible = false

    var body: some View {

        VStack(alignment: .leading, spacing: Constants.verticalPadding) {
            Text(title)
                .label4Style()

            HStack {
                TextField(placeholderText, text: isPasswordHidden ? $userVisiblePassword : $password) { editing in
                    closeButtonVisible = editing
                    isPasswordHidden = false
                } onCommit: {
                    closeButtonVisible = false
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.default)
                .label4Style(design: password.count > 0 ? .monospaced : .default)

                Spacer()

                if password.count > 0 {
                    if closeButtonVisible {
                        Image("Clear-16")
                            .onTapGesture {
                                self.password = ""
                            }
                    }
                }
            }
        }
        .frame(minHeight: Constants.minRowHeight)
        .listRowInsets(Constants.insets)
    }
}

private struct CopyableCell: View {
    @State private var id = UUID()
    let title: String
    let subtitle: String
    @Binding var selectedCell: UUID?
    var truncationMode: Text.TruncationMode = .tail
    var multiLine: Bool = false
    var isMonospaced: Bool = false
    
    var actionTitle: String
    let action: () -> Void
    
    var secondaryActionTitle: String?
    var secondaryAction: (() -> Void)?
    
    var buttonImageName: String?
    var buttonAccessibilityLabel: String?
    var buttonAction: (() -> Void)?

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: Constants.verticalPadding) {
                    Text(title)
                        .label4Style()
                    HStack {
                        if multiLine {
                            Text(subtitle)
                                .label4Style(design: isMonospaced ? .monospaced : .default,
                                             foregroundColorLight: ForegroundColor(isSelected: selectedCell == id).color,
                                             foregroundColorDark: .gray30)
                                .truncationMode(truncationMode)
                                .frame(maxHeight: .greatestFiniteMagnitude)
                        } else {
                            Text(subtitle)
                                .label4Style(design: isMonospaced ? .monospaced : .default,
                                             foregroundColorLight: ForegroundColor(isSelected: selectedCell == id).color,
                                             foregroundColorDark: .gray30)
                                .truncationMode(truncationMode)
                        }
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 8))
                
                Spacer(minLength: buttonImageName != nil ? Constants.textFieldImageSize : 8)
            }
            .copyable(isSelected: selectedCell == id,
                      menuTitle: actionTitle,
                      menuAction: action,
                      menuSecondaryTitle: secondaryActionTitle,
                      menuSecondaryAction: secondaryAction) {
                self.selectedCell = self.id
            } menuClosedAction: {
                self.selectedCell = nil
            }
            
            if let buttonImageName = buttonImageName, let buttonAccessibilityLabel = buttonAccessibilityLabel {
                let differenceBetweenImageSizeAndTapAreaPerEdge = (Constants.textFieldTapSize - Constants.textFieldImageSize) / 2.0
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        buttonAction?()
                        self.selectedCell = nil
                    } label: {
                        VStack(alignment: .trailing) {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(buttonImageName)
                                    .resizable()
                                    .frame(width: Constants.textFieldImageSize, height: Constants.textFieldImageSize)
                                    .foregroundColor(Color(UIColor.label).opacity(Constants.textFieldImageOpacity))
                                    .opacity(subtitle.isEmpty ? 0 : 1)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain) // Prevent taps from being forwarded to the container view
                    .background(BackgroundColor(isSelected: selectedCell == id).color)
                    .accessibilityLabel(buttonAccessibilityLabel)
                    .contentShape(Rectangle())
                    .frame(width: Constants.textFieldTapSize, height: Constants.textFieldTapSize)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -differenceBetweenImageSizeAndTapAreaPerEdge))
            }
        }
        .selectableBackground(isSelected: selectedCell == id)
    }
}

private struct SelectableBackground: ViewModifier {
    var isSelected: Bool
    
    public func body(content: Content) -> some View {
        content
            .listRowBackground(BackgroundColor(isSelected: isSelected).color)
            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

private struct Copyable: ViewModifier {
    var isSelected: Bool
    var menuTitle: String
    let menuSecondaryTitle: String?
    let menuAction: () -> Void
    let menuSecondaryAction: (() -> Void)?
    let menuOpenedAction: () -> Void
    let menuClosedAction: () -> Void
    
    internal init(isSelected: Bool, menuTitle: String, menuSecondaryTitle: String?, menuAction: @escaping () -> Void, menuSecondaryAction: (() -> Void)?, menuOpenedAction: @escaping () -> Void, menuClosedAction: @escaping () -> Void) {
        self.isSelected = isSelected
        self.menuTitle = menuTitle
        self.menuSecondaryTitle = menuSecondaryTitle
        self.menuAction = menuAction
        self.menuSecondaryAction = menuSecondaryAction
        self.menuOpenedAction = menuOpenedAction
        self.menuClosedAction = menuClosedAction
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .menuController(menuTitle,
                                secondaryTitle: menuSecondaryTitle,
                                action: menuAction,
                                secondaryAction: menuSecondaryAction,
                                onOpen: menuOpenedAction,
                                onClose: menuClosedAction)

            content
                .allowsHitTesting(false)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .frame(minHeight: Constants.minRowHeight)

        }
    }
}

private extension View {
    func copyable(isSelected: Bool, menuTitle: String, menuAction: @escaping () -> Void, menuSecondaryTitle: String? = "", menuSecondaryAction: (() -> Void)? = nil, menuOpenedAction: @escaping () -> Void, menuClosedAction: @escaping () -> Void) -> some View {
        modifier(Copyable(isSelected: isSelected,
                          menuTitle: menuTitle,
                          menuSecondaryTitle: menuSecondaryTitle,
                          menuAction: menuAction,
                          menuSecondaryAction: menuSecondaryAction,
                          menuOpenedAction: menuOpenedAction,
                          menuClosedAction: menuClosedAction))
    }
    
    func selectableBackground(isSelected: Bool) -> some View {
        modifier(SelectableBackground(isSelected: isSelected))
    }
}

private struct BackgroundColor {
    let isSelected: Bool
    
    var color: Color {
        if isSelected {
            return Color("AutofillCellSelectedBackground")
        } else {
            return Color(designSystemColor: .surface)
        }
    }
}

private struct ForegroundColor {
    let isSelected: Bool

    var color: Color {
        if isSelected {
            return .gray90
        } else {
            return .gray50
        }
    }
}

private struct Constants {
    static let verticalPadding: CGFloat = 4
    static let minRowHeight: CGFloat = 60
    static let textFieldImageOpacity: CGFloat = 0.84
    static let textFieldImageSize: CGFloat = 20
    static let textFieldTapSize: CGFloat = 44
    static let insets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
}

// swiftlint:enable type_body_length
