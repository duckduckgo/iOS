//
//  OmniBarNotification.swift
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

struct OmniBarNotification: View {
    
    @ObservedObject var viewModel: OmniBarNotificationViewModel
    
    @State var isAnimatingCookie: Bool = false
    
    @State var textOffset: CGFloat = 0
    @State var textWidth: CGFloat = 0
    
    @State var opacity: Double = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                animation
                
                text
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Constants.Colors.background)
                    .offset(x: textOffset)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var animation: some View {
        LottieView(lottieFile: viewModel.animationName,
                   isAnimating: $isAnimatingCookie)
        .frame(width: Constants.Size.animatedIcon.width, height: Constants.Size.animatedIcon.height)
    }
    
    @ViewBuilder
    private var text: some View {
        Text(viewModel.text)
            .font(Constants.Fonts.text)
            .foregroundColor(Constants.Colors.text)
            .lineLimit(1)
            .offset(x: textOffset)
            .padding(.trailing, Constants.Spacing.textTrailingPadding)
            .clipShape(Rectangle().inset(by: Constants.Spacing.textClippingShapeOffset))
            .onReceive(viewModel.$isOpen) { isOpen in
                withAnimation(.easeInOut(duration: OmniBarNotificationViewModel.Duration.notificationSlide)) {
                    textOffset = isOpen ? 0 : -textWidth
                }
            }
            .onReceive(viewModel.$animateCookie) { animateCookie in
                isAnimatingCookie = animateCookie
            }
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                textWidth = $0.width
                textOffset = -textWidth
            }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

private enum Constants {
    
    enum Fonts {
        static let text = Font(UIFont.systemFont(ofSize: 16))
    }
    
    enum Colors {
        static let text = Color("OmniBarNotificationTextColor")
        static let background = Color("OmniBarNotificationBackgroundColor")
    }

    enum Spacing {
        static let textClippingShapeOffset: CGFloat = -7
        static let textTrailingPadding: CGFloat = 12
    }
    
    enum Size {
        static let animatedIcon = CGSize(width: 36, height: 36)
        static let cancel = CGSize(width: 13, height: 13)
        static let rowHeight: CGFloat = 76
    }
}
