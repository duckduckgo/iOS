//
//  CredentialProviderListDetailsView.swift
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
import DuckUI
import DesignResourcesKit

struct CredentialProviderListDetailsView: View {

    @ObservedObject var viewModel: CredentialProviderListDetailsViewModel

    var body: some View {
        listWithBackground
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
            viewingContentView
        }
        .simultaneousGesture(
            DragGesture().onChanged({_ in
                viewModel.selectedCell = nil
            }))
        .listStyle(.insetGrouped)
    }

    private var viewingContentView: some View {
        Group {
            Section {
                Header(viewModel: viewModel.headerViewModel)
            }

            Section {
                usernameCell()
                    .onTapGesture {
                        if viewModel.shouldProvideTextToInsert {
                            viewModel.textToReturn(.username)
                        }
                    }

                passwordCell()
                    .onTapGesture {
                        if viewModel.shouldProvideTextToInsert {
                            viewModel.textToReturn(.password)
                        }
                    }
            }

            Section {
                addressCell()
            }

            Section {
                notesCell()
            }
        }
    }

    private func usernameCell() -> some View {
        CopyableCell(title: UserText.credentialProviderDetailsUsername,
                     subtitle: viewModel.usernameDisplayString,
                     selectedCell: $viewModel.selectedCell,
                     buttonImageName: "Copy-24",
                     buttonAccessibilityLabel: UserText.credentialProviderDetailsCopyPrompt(for: UserText.credentialProviderDetailsUsername),
                     buttonAction: { viewModel.copyToPasteboard(.username) })
    }

    private func passwordCell() -> some View {
        CopyableCell(title: UserText.credentialProviderDetailsPassword,
                     subtitle: viewModel.userVisiblePassword,
                     selectedCell: $viewModel.selectedCell,
                     isMonospaced: true,
                     buttonImageName: viewModel.isPasswordHidden ? "Eye-24" : "Eye-Closed-24",
                     buttonAccessibilityLabel: viewModel.isPasswordHidden ? UserText.credentialProviderDetailsShowPassword : UserText.credentialProviderDetailsHidePassword,
                     buttonAction: { viewModel.isPasswordHidden.toggle() },
                     secondaryButtonImageName: "Copy-24",
                     secondaryButtonAccessibilityLabel: UserText.credentialProviderDetailsCopyPrompt(for: UserText.credentialProviderDetailsPassword),
                     secondaryButtonAction: { viewModel.copyToPasteboard(.password) })
    }

    private func addressCell() -> some View {
        CopyableCell(title: UserText.credentialProviderDetailsAddress,
                     subtitle: viewModel.address,
                     selectedCell: $viewModel.selectedCell,
                     truncationMode: .middle,
                     buttonImageName: "Copy-24",
                     buttonAccessibilityLabel: UserText.credentialProviderDetailsCopyPrompt(for: UserText.credentialProviderDetailsAddress),
                     buttonAction: { viewModel.copyToPasteboard(.address) })
    }

    private func notesCell() -> some View {
        CopyableCell(title: UserText.credentialProviderDetailsNotes,
                     subtitle: viewModel.notes,
                     selectedCell: $viewModel.selectedCell,
                     truncationMode: .middle,
                     multiLine: true)
    }

}

private struct Header: View {

    @Environment(\.colorScheme) private var colorScheme

    private struct Constants {
        static let imageSize: CGFloat = 32
        static let horizontalStackSpacing: CGFloat = 12
        static let verticalStackSpacing: CGFloat = 1
        static let viewHeight: CGFloat = 60
        static let insets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    }

    var viewModel: CredentialProviderListDetailsHeaderViewModel

    var body: some View {
        HStack(spacing: Constants.horizontalStackSpacing) {
            Image(uiImage: viewModel.favicon)
                .resizable()
                .cornerRadius(4)
                .scaledToFit()
                .frame(width: Constants.imageSize, height: Constants.imageSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Constants.verticalStackSpacing) {
                Text(viewModel.title)
                    .font(.callout)
                    .foregroundColor(colorScheme == .light ? .gray90 : .white)
                    .truncationMode(.middle)
                    .lineLimit(1)

                Text(viewModel.subtitle)
                    .font(.footnote)
                    .foregroundColor(colorScheme == .light ? .gray50 : .gray20)
            }

            Spacer()
        }
        .frame(minHeight: Constants.viewHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .listRowBackground(Color(designSystemColor: .surface))
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

    var buttonImageName: String?
    var buttonAccessibilityLabel: String?
    var buttonAction: (() -> Void)?

    var secondaryButtonImageName: String?
    var secondaryButtonAccessibilityLabel: String?
    var secondaryButtonAction: (() -> Void)?

    var shouldProvideTextToInsertAction: (() -> Void)?

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
                                .textSelection(.enabled)
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

                if secondaryButtonImageName != nil {
                    Spacer(minLength: Constants.textFieldImageSize * 2 + 8)
                } else {
                    Spacer(minLength: buttonImageName != nil ? Constants.textFieldImageSize : 8)
                }
            }

            if let buttonImageName = buttonImageName, let buttonAccessibilityLabel = buttonAccessibilityLabel {
                let differenceBetweenImageSizeAndTapAreaPerEdge = (Constants.textFieldTapSize - Constants.textFieldImageSize) / 2.0
                HStack(alignment: .center, spacing: 0) {
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
                    // can't use .clear here or else both button padded area and container both respond to tap events
                    .background(BackgroundColor(isSelected: selectedCell == id).color.opacity(0))
                    .accessibilityLabel(buttonAccessibilityLabel)
                    .contentShape(Rectangle())
                    .frame(width: Constants.textFieldTapSize, height: Constants.textFieldTapSize)

                    if let secondaryButtonImageName = secondaryButtonImageName,
                        let secondaryButtonAccessibilityLabel = secondaryButtonAccessibilityLabel {
                        Button {
                            secondaryButtonAction?()
                            self.selectedCell = nil
                        } label: {
                            VStack(alignment: .trailing) {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(secondaryButtonImageName)
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
                        .background(BackgroundColor(isSelected: selectedCell == id).color.opacity(0))
                        .accessibilityLabel(secondaryButtonAccessibilityLabel)
                        .contentShape(Rectangle())
                        .frame(width: Constants.textFieldTapSize, height: Constants.textFieldTapSize)
                    }

                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -differenceBetweenImageSizeAndTapAreaPerEdge))
            }
        }
        .selectableBackground(isSelected: selectedCell == id)
    }
}

private extension View {
    func copyable(isSelected: Bool) -> some View {
        modifier(Copyable(isSelected: isSelected))
    }

    func selectableBackground(isSelected: Bool) -> some View {
        modifier(SelectableBackground(isSelected: isSelected))
    }
}

private struct Copyable: ViewModifier {
    var isSelected: Bool

    public func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)

            content
                .allowsHitTesting(false)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .frame(minHeight: Constants.minRowHeight)
        }
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

private struct Constants {
    static let verticalPadding: CGFloat = 4
    static let minRowHeight: CGFloat = 60
    static let textFieldImageOpacity: CGFloat = 0.84
    static let textFieldImageSize: CGFloat = 24
    static let textFieldTapSize: CGFloat = 36
    static let insets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
}
