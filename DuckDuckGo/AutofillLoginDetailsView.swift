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

struct AutofillLoginDetailsView: View {
    @ObservedObject var viewModel: AutofillLoginDetailsViewModel
    @State private var cellMaxWidth: CGFloat?
    @State private var isShowingPassword: Bool = false
    
    var body: some View {
        List {
            switch viewModel.viewMode {
            case .edit:
                editingContentView
            case .view:
                viewingContentView
            case .new:
                editingContentView
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged({_ in
                viewModel.selectedCell = nil
            }))
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
                
                editableCell(UserText.autofillLoginDetailsPassword,
                             subtitle: $viewModel.password,
                             placeholderText: UserText.autofillLoginDetailsEditPasswordPlaceholder,
                             secure: true)
            }
            
            Section {
                editableCell(UserText.autofillLoginDetailsAddress,
                             subtitle: $viewModel.address,
                             placeholderText: UserText.autofillLoginDetailsEditURLPlaceholder,
                             keyboardType: .URL)
            }
        }
    }
    
    private var viewingContentView: some View {
        Group {
            Section {
                AutofillLoginDetailsHeaderView(viewModel: viewModel.headerViewModel)
            }
            
            Section {
                CopyableCell(title: UserText.autofillLoginDetailsUsername, subtitle: viewModel.username, selectedCell: $viewModel.selectedCell) {
                    viewModel.copyToPasteboard(.username)
                }

                CopyablePasswordCell(title: UserText.autofillLoginDetailsPassword,
                                     password: viewModel.userVisiblePassword,
                                     selectedCell: $viewModel.selectedCell,
                                     isPasswordHidden: $viewModel.isPasswordHidden) {
                    
                    viewModel.copyToPasteboard(.password)
                }
            }
            
            Section {
                CopyableCell(title: UserText.autofillLoginDetailsAddress,
                             subtitle: viewModel.address,
                             selectedCell: $viewModel.selectedCell) {
                    viewModel.copyToPasteboard(.address)
                }
            }
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
    }
}

struct ClearTextField: View {
    var placeholderText: String
    @Binding var text: String
    var autoCapitalizationType: UITextAutocapitalizationType = .none
    var disableAutoCorrection = true
    var keyboardType: UIKeyboardType = .default
    var secure = false

    @State private var closeButtonVisible = false
    
    var body: some View {
        HStack {
            TextField(placeholderText, text: $text) { editing in
                closeButtonVisible = editing
            } onCommit: {
                closeButtonVisible = false
            }
            .autocapitalization(autoCapitalizationType)
            .disableAutocorrection(disableAutoCorrection)
            .keyboardType(keyboardType)
            .label4Style(design: secure && text.count > 0 ? .monospaced : .default)
            
            Spacer()
            Image("ClearTextField")
                .opacity(closeButtonOpacity)
                .onTapGesture { self.text = "" }
        }
    }
    
    private var closeButtonOpacity: Double {
        if text == "" || !closeButtonVisible {
            return 0
        }
        return 1
    }
}

private struct CopyablePasswordCell: View {
    @State private var id = UUID()
    let title: String
    let password: String
    @Binding var selectedCell: UUID?
    @Binding var isPasswordHidden: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: Constants.verticalPadding) {
                    Text(title)
                        .label4Style()
                    HStack {
                        Text(password)
                            .label4Style(design: .monospaced,
                                         foregroundColorLight: ForegroundColor(isSelected: selectedCell == id).color,
                                         foregroundColorDark: .gray30)
                    }
                }
                Spacer(minLength: Constants.passwordImageSize)
            }
            .copyable(isSelected: selectedCell == id, menuTitle: title, menuAction: action) {
                self.selectedCell = self.id
            } menuClosedAction: {
                self.selectedCell = nil
            }

            HStack(alignment: .bottom) {
                Spacer()
                Button {
                    isPasswordHidden.toggle()
                    self.selectedCell = nil
                } label: {
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(isPasswordHidden ? "ShowPasswordEye" : "HidePasswordEye")
                                    .foregroundColor(Color(UIColor.label).opacity(Constants.passwordImageOpacity))
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(width: Constants.passwordImageSize, height: Constants.passwordImageSize)
                }
                .buttonStyle(.plain) // Prevent taps from being forwarded to the container view
                .background(BackgroundColor(isSelected: selectedCell == id).color)
                .accessibilityLabel(isPasswordHidden ? UserText.autofillShowPassword : UserText.autofillHidePassword)
            }
            .padding(.bottom, Constants.verticalPadding)
        }
        .selectableBackground(isSelected: selectedCell == id)
    }

}

private struct CopyableCell: View {
    @State private var id = UUID()
    let title: String
    let subtitle: String
    @Binding var selectedCell: UUID?
    let action: () -> Void
        
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.verticalPadding) {
                Text(title)
                    .label4Style()
                HStack {
                    Text(subtitle)
                        .label4Style(foregroundColorLight: ForegroundColor(isSelected: selectedCell == id).color, foregroundColorDark: .gray30)
                        .truncationMode(.middle)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .copyable(isSelected: selectedCell == id, menuTitle: title, menuAction: action) {
            self.selectedCell = self.id
        } menuClosedAction: {
            self.selectedCell = nil
        }
        .selectableBackground(isSelected: selectedCell == id)
    }
}

private struct SelectableBackground: ViewModifier {
    var isSelected: Bool
    
    public func body(content: Content) -> some View {
        content
            .listRowBackground(BackgroundColor(isSelected: isSelected).color)
    }
}

private struct Copyable: ViewModifier {
    var isSelected: Bool
    var menuTitle: String
    let menuAction: () -> Void
    let menuOpenedAction: () -> Void
    let menuClosedAction: () -> Void
    
    internal init(isSelected: Bool, menuTitle: String, menuAction: @escaping () -> Void, menuOpenedAction: @escaping () -> Void, menuClosedAction: @escaping () -> Void) {
        self.isSelected = isSelected
        self.menuTitle = menuTitle
        self.menuAction = menuAction
        self.menuOpenedAction = menuOpenedAction
        self.menuClosedAction = menuClosedAction
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .menuController("Copy \(menuTitle)",
                                action: menuAction,
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
    func copyable(isSelected: Bool, menuTitle: String, menuAction: @escaping () -> Void, menuOpenedAction: @escaping () -> Void, menuClosedAction: @escaping () -> Void) -> some View {
        modifier(Copyable(isSelected: isSelected,
                          menuTitle: menuTitle,
                          menuAction: menuAction,
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
            return Color("AutofillCellBackground")
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
    static let passwordImageOpacity: CGFloat = 0.84
    static let passwordImageSize: CGFloat = 44
}
