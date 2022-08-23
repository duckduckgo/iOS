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
        
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .label3AltStyle()
            
            HStack {
                if secure {
                    SecureField(placeholderText, text: subtitle)
                        .label3Style(design: .monospaced)
                } else {
                    ClearTextField(placeholderText: placeholderText,
                                   text: subtitle,
                                   autoCapitalizationType: autoCapitalizationType,
                                   disableAutoCorrection: disableAutoCorrection,
                                   keyboardType: keyboardType)
                    .label4Style()
                }
            }
        }.frame(height: 60)
    }
}

struct ClearTextField: View {
    var placeholderText: String
    @Binding var text: String
    var autoCapitalizationType: UITextAutocapitalizationType = .none
    var disableAutoCorrection = true
    var keyboardType: UIKeyboardType = .default
    
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
            
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.secondary)
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .label3AltStyle()
                    HStack {
                        Text(password)
                            .label3Style(design: .monospaced)
                    }
                }
                Spacer()
            }
            .copyable(isSelected: selectedCell == id, menuTitle: title, menuAction: action) {
                self.selectedCell = self.id
            } menuClosedAction: {
                self.selectedCell = nil
            }

            HStack {
                Spacer()
                Button {
                    isPasswordHidden.toggle()
                    self.selectedCell = nil
                } label: {
                    HStack {
                        Spacer()
                        Image(isPasswordHidden ? "ShowPasswordEye": "HidePasswordEye")
                            .foregroundColor(.primary)
                    }
                    .contentShape(Rectangle())
                    .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain) // Prevent taps from being forwarded to the container view
                .background(BackgroundColor(isSelected: selectedCell == id).color)
                
            }
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
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .label3AltStyle()
                HStack {
                    Text(subtitle)
                        .label4Style()
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
                .frame(height: 60)
            
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
