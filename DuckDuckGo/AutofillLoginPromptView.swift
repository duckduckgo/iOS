//
//  AutofillLoginPromptView.swift
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
import BrowserServicesKit

struct AutofillLoginPromptView: View {

    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: AutofillLoginPromptViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            mainView(geometry)
        }
    }
                    
    private func mainView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }

        return ZStack {
            AutofillViews.CloseButtonHeader(action: viewModel.dismissView)
                .offset(x: horizontalPadding)
                .zIndex(1)
            
            VStack {
                Spacer()
                    .frame(height: Const.Size.topPadding)
                AutofillViews.AppIconHeader()
                Spacer()
                    .frame(height: Const.Size.headlineTopPadding)
                AutofillViews.Headline(title: viewModel.message)
                contentSpacer
                accountButtons
                bottomSpacer
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

        if AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) {
            useScrollView = viewModel.contentHeight > frame.height
        } else if #available(iOS 16.0, *) {
            useScrollView = AutofillViews.contentHeightExceedsScreenHeight(viewModel.contentHeight)
        } else {
            useScrollView = viewModel.contentHeight > frame.height + Const.Size.ios15scrollOffset
        }

        return useScrollView
    }

    private var contentSpacer: some View {
        VStack {
            if AutofillViews.isIPhoneLandscape(verticalSizeClass) {
                Spacer(minLength: Const.Size.contentSpacerHeight)
            } else {
                if viewModel.expanded {
                    AutofillViews.LegacySpacerView(height: Const.Size.contentSpacerHeight, legacyHeight: Const.Size.contentSpacerHeight)
                } else {
                    AutofillViews.LegacySpacerView(height: Const.Size.contentSpacerHeight)
                }
            }
        }
    }

    private var horizontalPadding: CGFloat {
        guard AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) else {
            return Const.Size.closeButtonOffset
        }

        if AutofillViews.isSmallFrame(frame) {
            return Const.Size.closeButtonOffsetPortraitSmallFrame
        } else {
            return Const.Size.closeButtonOffsetPortrait
        }
    }

    private var bottomSpacer: some View {
        VStack {
            if AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) {
                AutofillViews.LegacySpacerView(height: Const.Size.bottomSpacerHeight)
            } else if AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) {
                AutofillViews.LegacySpacerView(height: Const.Size.bottomSpacerHeightIPad)
            } else {
                AutofillViews.LegacySpacerView()
            }
        }
    }

    private var accountButtons: some View {
        Group {
            let containsPartialMatches = viewModel.containsPartialMatches
            ForEach(viewModel.accountMatchesViewModels.indices, id: \.self) { group in
                VStack(spacing: Const.Size.buttonVerticalSpacing) {
                    if containsPartialMatches {
                        buttonGroupTitle(for: viewModel.accountMatchesViewModels[group], groupIndex: group)
                    }
                    ForEach(viewModel.accountMatchesViewModels[group].accounts.indices, id: \.self) { index in
                        let accountViewModel = viewModel.accountMatchesViewModels[group].accounts[index]
                        accountButton(for: accountViewModel,
                                      style: index == 0 && group == 0 ? .primary : .secondary)
                    }
                }
            }
            if viewModel.showMoreOptions {
                moreOptionsButton
            }
        }
    }

    private func buttonGroupTitle(for accountViewModelGroup: AccountMatchesViewModel, groupIndex: Int) -> some View {
        HStack(alignment: .bottom) {
            Text(accountViewModelGroup.title)
                .daxFootnoteRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .truncationMode(.middle)
                .lineLimit(1)
        }
        .padding(.top, groupIndex == 0 ? 0 : Const.Size.buttonGroupTitleTopPadding)
    }

    private enum AccountButtonStyle {
        case primary
        case secondary
    }

    @ViewBuilder
    private func accountButton(for accountViewModel: AccountViewModel, style: AccountButtonStyle) -> some View {

        switch style {
        case .primary:
            AutofillViews.PrimaryButton(title: accountViewModel.displayString,
                                        action: { viewModel.didSelectAccount(accountViewModel.account) })
        case .secondary:
            AutofillViews.SecondaryButton(title: accountViewModel.displayString,
                                          action: { viewModel.didSelectAccount(accountViewModel.account) })
        }
    }

    private var moreOptionsButton: some View {
        AutofillViews.TertiaryButton(title: viewModel.moreOptionsButtonString, action: viewModel.didExpand)
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
        static let contentSpacerHeight: CGFloat = 40.0
        static let contentSpacerHeightLandscape: CGFloat = 24.0
        static let buttonVerticalSpacing: CGFloat = 12.0
        static let buttonGroupTitleTopPadding: CGFloat = 22.0
        static let bottomSpacerHeight: CGFloat = 40.0
        static let bottomSpacerHeightIPad: CGFloat = 60.0
    }
}

// MARK: - Preview

struct AutofillLoginPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.light)
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.dark)
    }
}
