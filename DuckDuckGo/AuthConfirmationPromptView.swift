//
//  AuthConfirmationPromptView.swift
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

struct AuthConfirmationPromptView: View {
    
    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: AuthConfirmationPromptViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
    }
    
    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        
        return VStack {
            HStack {
                Button {
                    viewModel.cancelButtonPressed()
                } label: {
                    Text(UserText.actionCancel)
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                }
                Spacer()
            }
            .padding([.top, .leading], Const.Size.closeButtonPadding)
            
            Group {
                Spacer()
                    .frame(height: Const.Size.topPadding)
                Image
                    .lock
                Spacer()
                    .frame(height: Const.Size.headlineTopPadding)
                AutofillViews.Headline(title: UserText.autofillDeleteAllPasswordsAuthenticationPromptTitle)
                contentViewSpacer
                AutofillViews.PrimaryButton(title: UserText.autofillDeleteAllPasswordsAuthenticationPromptButton,
                                            action: { viewModel.authenticatePressed() })
                .padding(.bottom, AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) ? Const.Size.bottomPaddingIPad
                         : Const.Size.bottomPadding)
            }
            .padding(.horizontal, horizontalPadding)
        }
        .background(GeometryReader { proxy -> Color in
            DispatchQueue.main.async { viewModel.contentHeight = proxy.size.height }
            return Color.clear
        })
        .useScrollView(shouldUseScrollView(), minHeight: frame.height)
    }
    
    private var horizontalPadding: CGFloat {
        if AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) {
            if AutofillViews.isSmallFrame(frame) {
                return Const.Size.horizontalPaddingPortraitSmallFrame
            } else {
                return Const.Size.horizontalPaddingPortrait
            }
        } else {
            return Const.Size.horizontalPadding
        }
    }
    
    private var contentViewSpacer: some View {
        VStack {
            if AutofillViews.isIPhoneLandscape(verticalSizeClass) {
                AutofillViews.LegacySpacerView(height: Const.Size.contentSpacerHeightLandscape)
            } else {
                AutofillViews.LegacySpacerView(height: Const.Size.contentSpacerHeight)
            }
        }
    }
    
    private func shouldUseScrollView() -> Bool {
        var useScrollView: Bool = false
        
        if #available(iOS 16.0, *) {
            useScrollView = AutofillViews.contentHeightExceedsScreenHeight(viewModel.contentHeight)
        } else {
            useScrollView = viewModel.contentHeight > frame.height + Const.Size.ios15scrollOffset
        }
        
        return useScrollView
    }
}

private enum Const {
    enum Size {
        static let closeButtonPadding: CGFloat = 16.0
        static let horizontalPadding: CGFloat = 48.0
        static let horizontalPaddingPortrait: CGFloat = 44.0
        static let horizontalPaddingPortraitSmallFrame: CGFloat = 16.0
        static let topPadding: CGFloat = 36.0
        static let headlineTopPadding: CGFloat = 24.0
        static let ios15scrollOffset: CGFloat = 80.0
        static let contentSpacerHeight: CGFloat = 44.0
        static let contentSpacerHeightLandscape: CGFloat = 50.0
        static let bottomPadding: CGFloat = 12.0
        static let bottomPaddingIPad: CGFloat = 24.0
    }
}

private extension Image {
    static let lock = Image("AutofillLock")
}

#Preview {
    AuthConfirmationPromptView(viewModel: AuthConfirmationPromptViewModel())
}
