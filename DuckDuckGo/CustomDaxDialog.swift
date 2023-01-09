//
//  CustomDaxDialog.swift
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

enum DialogContentItem: Hashable {
    case text(text: String)
    case animation(name: String, delay: TimeInterval = 0)
}

struct DialogButtonItem: Hashable {
    let label: String
    let style: DialogButtonStyle
    let action: () -> Void
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
        hasher.combine(style)
    }
    
    static func == (lhs: DialogButtonItem, rhs: DialogButtonItem) -> Bool {
        lhs.label == rhs.label && lhs.style == rhs.style
    }
}

enum DialogButtonStyle {
    case bordered, borderless
}

struct CustomDaxDialogModel {
    let content: [DialogContentItem]
    let buttons: [DialogButtonItem]
}

struct CustomDaxDialog: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var model: CustomDaxDialogModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Constants.Colors.overlay)
            
            VStack(alignment: .leading, spacing: .zero) {
                Spacer()
                
                VStack(spacing: Constants.Spacing.daxLogoAndArrow) {
                    Image.daxLogo
                        .resizable()
                        .frame(width: Constants.Size.daxLogo.width, height: Constants.Size.daxLogo.height)
                    Triangle()
                        .frame(width: Constants.Size.bubbleArrow.width, height: Constants.Size.bubbleArrow.height)
                        .foregroundColor(Constants.Colors.background)
                }
                .padding(.leading, Constants.Padding.daxLogoAndArrow)
                
                VStack(spacing: Constants.Spacing.dialogElements) {
                    ForEach(model.content, id: \.self) { element in
                        switch element {
                        case .text(let text):
                            Text(text)
                                .font(Constants.Fonts.text)
                                .foregroundColor(Constants.Colors.text)
                                .lineSpacing(Constants.Spacing.textLineSpacing)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case .animation(let name, let delay):
                            LottieView(lottieFile: name, delay: delay)
                                .fixedSize()
                        }
                    }
                    
                    ForEach(model.buttons, id: \.self) { button in
                        switch button.style {
                        case .bordered:
                            Button(action: {
                                button.action()
                            },
                                   label: {
                                Text(button.label)
                                    .font(Constants.Fonts.button)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            })
                            .frame(height: Constants.Size.buttonHeight)
                            .foregroundColor(Constants.Colors.borderedButtonText)
                            .background(Capsule().foregroundColor(Constants.Colors.borderedButtonBackground))
                        case .borderless:
                            Button(action: button.action, label: {
                                Text(button.label)
                                    .font(Constants.Fonts.button)
                                    .frame(maxHeight: .infinity)
                            })
                            .frame(height: Constants.Size.buttonHeight)
                            .buttonStyle(.borderless)
                            .foregroundColor(Constants.Colors.borderlessButtonText)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(Constants.Padding.dialogInsets)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Size.dialogCornerRadius)
                        .foregroundColor(Constants.Colors.background)
                )
            }
            .padding([.leading, .trailing], Constants.Padding.dialogHorizontal)
            .if(verticalSizeClass == .regular) { view in
                view.padding(.bottom, Constants.Padding.dialogBottom)
            }
            .if(horizontalSizeClass == .regular) { view in
                view.frame(width: Constants.Size.fixedDialogWidth)
            }
        }
    }
}

private enum Constants {
    
    enum Fonts {
        static let text = Font(UIFont.appFont(ofSize: 17))
        static let button = Font(UIFont.boldAppFont(ofSize: 16))
    }
    
    enum Colors {
        static let overlay = Color("CustomDaxDialogOverlayColor")
        static let background = Color("CustomDaxDialogBackgroundColor")
        static let text = Color("CustomDaxDialogTextColor")
        static let borderedButtonText = Color("CustomDaxDialogBorderedButtonTextColor")
        static let borderlessButtonText = Color("CustomDaxDialogBorderlessButtonTextColor")
        static let borderedButtonBackground = Color("CustomDaxDialogBorderedButtonBackgroundColor")
    }

    enum Spacing {
        static let daxLogoAndArrow: CGFloat = 8
        static let dialogElements: CGFloat = 16
        static let textLineSpacing: CGFloat = 5
    }
    
    enum Padding {
        static let daxLogoAndArrow: CGFloat = 24
        static let dialogInsets = EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
        static let dialogHorizontal: CGFloat = 8
        static let dialogBottom: CGFloat = 92
    }
    
    enum Size {
        static let daxLogo = CGSize(width: 54, height: 54)
        static let bubbleArrow = CGSize(width: 15, height: 7)
        static let buttonHeight: CGFloat = 44
        static let fixedDialogWidth: CGFloat = 380
        static let dialogCornerRadius: CGFloat = 16
    }
}

private extension Image {
    static let daxLogo = Image("Logo")
}
