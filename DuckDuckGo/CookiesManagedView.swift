//
//  CookiesManagedOmniBarNotificationView.swift
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

final class BadgeNotificationAnimationModel: ObservableObject {
    let duration: CGFloat
    let secondPhaseDelay: CGFloat
    @Published var state: AnimationState = .unstarted

    init(duration: CGFloat = AnimationDefaultConsts.totalDuration, secondPhaseDelay: CGFloat = AnimationDefaultConsts.secondPhaseDelay) {
        self.duration = duration
        self.secondPhaseDelay = secondPhaseDelay
    }
    
    enum AnimationState {
        case unstarted
        case expanded
        case retracted
    }
}

private enum AnimationDefaultConsts {
    static let totalDuration: CGFloat = 0.3
    static let secondPhaseDelay: CGFloat = 3.0
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

struct BadgeAnimationView: View {
    var animationModel: BadgeNotificationAnimationModel = BadgeNotificationAnimationModel()
    let iconView: AnyView
    let text: String
    @State var textSize: CGSize = .zero
    @State var textOffset: CGFloat = -999  // -Consts.View.textScrollerOffset
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ExpandableRectangle(animationModel: animationModel)
                    .frame(width: geometry.size.height, height: geometry.size.height)
                
                HStack {
                    Text(text)
                        .foregroundColor(.primary)
                        .font(.body)
                        .offset(x: textOffset)
                        .onReceive(animationModel.$state, perform: { state in
                            switch state {
                            case .expanded:
                                withAnimation(.easeInOut(duration: animationModel.duration)) {
                                    textOffset = 0
                                }
                            case .retracted:
                                withAnimation(.easeInOut(duration: animationModel.duration)) {
                                    textOffset = -textSize.width // -Consts.View.textScrollerOffset
                                }
                            default:
                                break
                            }
                        })
//                        .padding(.leading, geometry.size.height)
                        .background(ViewGeometry())
                        .onPreferenceChange(ViewSizeKey.self) {
                            textSize = $0
                            textOffset = -$0.width
                        }
                        
                    
                    Spacer()
                }.clipped()
                
                // Opaque view
//                HStack {
//                    Rectangle()
//                        .foregroundColor(Color.blue10)
//                        .cornerRadius(Consts.View.cornerRadius)
//                        .frame(width: geometry.size.height - Consts.View.opaqueViewOffset, height: geometry.size.height)
//                    Spacer()
//                }
                
//                HStack {
//                    iconView
//                        .frame(width: geometry.size.height, height: geometry.size.height)
//                    Spacer()
//                }
            }
        }
    }
}

struct ExpandableRectangle: View {
    @ObservedObject var animationModel: BadgeNotificationAnimationModel
    @State var width: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.orange)
                .cornerRadius(Consts.View.cornerRadius)
                .frame(width: geometry.size.height + width, height: geometry.size.height)
                .onReceive(animationModel.$state, perform: { state in
                    switch state {
                    case .expanded:
                        withAnimation(.easeInOut(duration: animationModel.duration)) {
                            width = geometry.size.width - geometry.size.height
                        }
                        
                    case .retracted:
                        withAnimation(.easeInOut(duration: animationModel.duration)) {
                                width = 0
                        }
                    default:
                        break
                    }
                })
        }
    }
}

struct BadgeAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 11.0, *) {
            BadgeAnimationView(animationModel: BadgeNotificationAnimationModel(),
                               iconView: AnyView(Image(systemName: "globle")),
                                                 text: "Test")
            .frame(width: 100, height: 30)
        } else {
            Text("No Preview")
        }
    }
}

private enum Consts {
    enum View {
        static let cornerRadius: CGFloat = 5
        static let opaqueViewOffset: CGFloat = 8
        static let textScrollerOffset: CGFloat = 120
    }
    
    enum Colors {
        static let badgeBackgroundColor = Color.red //  Color("URLNotificationBadgeBackground")
    }
}
