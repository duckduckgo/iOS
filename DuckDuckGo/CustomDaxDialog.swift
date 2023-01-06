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

struct DialogModel {
    let content: [DialogContentItem]
    let buttons: [DialogButtonItem]
}

struct CustomDaxDialog: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var model: DialogModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.5)
      
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image.daxLogo
                        .resizable()
                        .frame(width: 54, height: 54)
                    Triangle()
                        .frame(width: 15, height: 7)
                        .foregroundColor(.white)
                }
                .padding(.leading, 24)
                
                VStack(spacing: 16) {
                    ForEach(model.content, id: \.self) { element in
                        switch element {
                        case .text(let text):
                            Text(text).frame(maxWidth: .infinity, alignment: .leading)
                        case .animation(let name):
                            Image(systemName: name)
                                .font(.largeTitle)
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
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            })
                            .frame(height: 44)
                            .foregroundColor(.white)
                            .background(Capsule().foregroundColor(Color.yellow))
                        case .borderless:
                            Button(action: button.action, label: {
                                Text(button.label)
                                    .frame(maxHeight: .infinity)
                            })
                            .frame(height: 44)
                            .buttonStyle(.borderless)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                        }
                        
                    }

                }
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(.white)
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

struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

private extension Image {
    static let daxLogo = Image("Logo")
}
