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
    case animation(name: String)
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
      
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image.daxLogo
                        .resizable()
                        .frame(width: 54, height: 54)
                    Triangle()
                        .frame(width: 15, height: 7)
                        .foregroundColor(Constants.Colors.background)
                }
                .padding(.leading, 24)
                
                VStack(spacing: 16) {
                    ForEach(model.content, id: \.self) { element in
                        switch element {
                        case .text(let text):
                            Text(text)
                                .font(Constants.Fonts.text)
                                .foregroundColor(Constants.Colors.text)
                                .lineSpacing(5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case .animation(let name):
                            LottieView(lottieFile: name)
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
                            .frame(height: 44)
                            .foregroundColor(Constants.Colors.borderedButtonText)
                            .background(Capsule().foregroundColor(Constants.Colors.borderedButtonBackground))
                        case .borderless:
                            Button(action: button.action, label: {
                                Text(button.label)
                                    .font(Constants.Fonts.button)
                                    .frame(maxHeight: .infinity)
                            })
                            .frame(height: 44)
                            .buttonStyle(.borderless)
                            .foregroundColor(Constants.Colors.borderlessButtonText)
                            .clipShape(Capsule())
                        }
                        
                    }

                }
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Constants.Colors.background)
                )
                
                Spacer()
                    .frame(height: 24)
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .if(verticalSizeClass == .regular) { view in
                view.padding(.bottom, 70)
            }
            .if(horizontalSizeClass == .regular) { view in
                view.frame(width: 380)
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

//    enum Spacing {
//        static let textClippingShapeOffset: CGFloat = -7
//        static let textTrailingPadding: CGFloat = 18
//    }
    
    enum Size {
//        static let animatIcon = CGSize(width: 22, height: 22)
//        static let animatedIconContainer = CGSize(width: 36, height: 36)
//        static let cancel = CGSize(width: 13, height: 13)
//        static let rowHeight: CGFloat = 76
    }
}

private extension Image {
    static let daxLogo = Image("Logo")
}
