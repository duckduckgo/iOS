//
//  EmailSignupPromptView.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

struct EmailSignupPromptView: View {

    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: EmailSignupPromptViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
    }

    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }

        return ZStack {
            AutofillViews.CloseButtonHeader(action: viewModel.closeButtonPressed)
                .offset(x: horizontalPadding)
                .zIndex(1)

                VStack {
                    Spacer()
                        .frame(height: Const.Size.topPadding)
                    IconAndTitle()
                    Spacer()
                        .frame(height: Const.Size.headlineTopPadding)
                    AutofillViews.Headline(title: UserText.emailSignupPromptTitle)
                    Spacer()
                        .frame(height: Const.Size.headlineTopPadding)
                    AutofillViews.Description(text: UserText.emailSignupPromptSubtitle)
                    contentViewSpacer
                    ctaView
                        .padding(.bottom, AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) ? Const.Size.bottomPaddingIPad
                                                                                                       : Const.Size.bottomPadding)
                }
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async { viewModel.contentHeight = proxy.size.height }
                    return Color.clear
                })
                .useScrollView(shouldUseScrollView(), minHeight: frame.height)

        }
        .padding(.horizontal, horizontalPadding)
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

    private struct IconAndTitle: View {
        var body: some View {
            HStack {
                Image.logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: Const.Size.logoImage, height: Const.Size.logoImage)
                Text(UserText.emailProtection)
                    .daxFootnoteRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
            }
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

    private var ctaView: some View {
        VStack(spacing: Const.Size.ctaVerticalSpacing) {
            AutofillViews.PrimaryButton(title: UserText.emailSignupPromptSignUpButton,
                                        action: viewModel.continueSignupPressed)

            AutofillViews.TertiaryButton(title: UserText.emailSignupPromptDoNotSignUpButton,
                                         action: viewModel.rejectSignupPressed)
        }
    }

    private var horizontalPadding: CGFloat {
        if AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) {
            if AutofillViews.isSmallFrame(frame) {
                return Const.Size.closeButtonOffsetPortraitSmallFrame
            } else {
                return Const.Size.closeButtonOffsetPortrait
            }
        } else {
            return Const.Size.closeButtonOffset
        }
    }
}

// MARK: - Constants

private enum Const {

    enum Size {
        static let closeButtonOffset: CGFloat = 48.0
        static let closeButtonOffsetPortrait: CGFloat = 44.0
        static let closeButtonOffsetPortraitSmallFrame: CGFloat = 16.0
        static let topPadding: CGFloat = 56.0
        static let headlineTopPadding: CGFloat = 24.0
        static let ios15scrollOffset: CGFloat = 80.0
        static let contentSpacerHeight: CGFloat = 24.0
        static let contentSpacerHeightLandscape: CGFloat = 30.0
        static let ctaVerticalSpacing: CGFloat = 8.0
        static let bottomPadding: CGFloat = 12.0
        static let bottomPaddingIPad: CGFloat = 24.0
        static let logoImage: CGFloat = 20.0
    }
}

private extension Image {
    static let logo = Image("Logo")
}

struct EmailSignupPromptView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = EmailSignupPromptViewModel()
        EmailSignupPromptView(viewModel: viewModel)
    }
}
