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

@available(iOS 14.0, *)
struct AutofillLoginDetailsView: View {
    @ObservedObject var viewModel: AutofillLoginDetailsViewModel
    @State private var cellMaxWidth: CGFloat?
    @State private var isShowingPassword: Bool = false
    
    var body: some View {
        List {
            switch viewModel.viewMode {
            case .edit:
                editModeContentView
            case .view:
                viewModeContentView
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged({_ in
                viewModel.selectedCell = nil
            }))
    }
    
    private var editModeContentView: some View {
        Group {
            Section {
                editableCell("Login Name", subtitle: $viewModel.title)
            }
    
            Section {
                editableCell("Username", subtitle: $viewModel.username)
                editableCell("Password", subtitle: $viewModel.password, secure: true)
            }
            
            Section {
                editableCell("Address", subtitle: $viewModel.address)
            }
        }
    }
    
    private var viewModeContentView: some View {
        Group {
            Section {
                AutofillLoginDetailsHeaderView(viewModel: viewModel.headerViewModel)
            }
            
            Section {
                CopyableCell(title: "Username", subtitle: viewModel.username, selectedCell: $viewModel.selectedCell) {
                    viewModel.copyToPasteboard(.username)
                    viewModel.selectedCell = nil
                }

                CopyablePasswordCell(title: "Password", password: viewModel.userVisiblePassword,
                                     selectedCell: $viewModel.selectedCell,
                                     isPasswordHidden: $viewModel.isPasswordHidden) {
                    
                    viewModel.copyToPasteboard(.password)
                    viewModel.selectedCell = nil
                }
            }
            
            Section {
                CopyableCell(title: "Address", subtitle: viewModel.address, selectedCell: $viewModel.selectedCell) {
                    viewModel.copyToPasteboard(.address)
                    viewModel.selectedCell = nil
                }
            }
        }
    }
    
    private func editableCell(_ title: String, subtitle: Binding<String>, secure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .label3AltStyle()
            
            HStack {
                if secure {
                    SecureField("", text: subtitle)
                        .label3Style(design: .monospaced)
                } else {
                    ClearTextField(text: subtitle)
                        .label4Style()
                }
            }
        }.frame(height: 60)
    }
}

struct ClearTextField: View {
    @Binding var text: String
    @State private var closeButtonVisible = false
    
    var body: some View {
        HStack {
            TextField("", text: $text) { editing in
                closeButtonVisible = editing
            } onCommit: {
                closeButtonVisible = false
            }
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
                        .disabled(true)
                    
                    HStack {
                        Text(password)
                            .label3Style(design: .monospaced)
                    }
                }
                Spacer()
            }
            .copyable(isSelected: selectedCell == id, menuTitle: title, menuAction: {
                self.action()
            }, tapAction: {
                self.selectedCell = self.id
            })
            
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
                .buttonStyle(.plain)
                .background(BackgroundColor(isSelected: selectedCell == id).color)
                // Prevent taps from being forwarded
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
                    .disabled(true)
                
                HStack {
                    Text(subtitle)
                        .label4Style()
                }
            }
            Spacer()
        }
        .copyable(isSelected: selectedCell == id, menuTitle: title, menuAction: {
            self.action()
        }, tapAction: {
            self.selectedCell = self.id
        })
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
    let tapAction: () -> Void
    
    internal init(isSelected: Bool, menuTitle: String, menuAction: @escaping () -> Void, tapAction: @escaping () -> Void) {
        self.isSelected = isSelected
        self.menuTitle = menuTitle
        self.menuAction = menuAction
        self.tapAction = tapAction
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .menuController("Copy \(menuTitle)", action: menuAction)
            
            content
                .allowsHitTesting(false)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            
        }
        .highPriorityGesture(
            TapGesture().onEnded({ _ in
                tapAction()
            }))
    }
}

private extension View {
    func copyable(isSelected: Bool, menuTitle: String, menuAction: @escaping () -> Void, tapAction: @escaping () -> Void) -> some View {
        modifier(Copyable(isSelected: isSelected, menuTitle: menuTitle, menuAction: menuAction, tapAction: tapAction))
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
