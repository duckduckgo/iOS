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
    @ObservedObject var viewModel: AutofillLoginPromptViewModel
    
    var body: some View {
        mainView()
            .ignoresSafeArea()
    }
                    
    private func mainView() -> some View {
        ZStack {
            closeButtonHeader
            
            VStack {
                VStack(spacing: 0) {
                    titleHeaderView
                    Spacer()
                    accountButtonsContainer
                    Spacer()
                }
                .padding(.top, 43)
                    
                footer
            }
        }
    }
    
    var closeButtonHeader: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
                    .padding(5)
            }
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button {
            viewModel.dismissView()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: Const.Size.closeButtonSize, height: Const.Size.closeButtonSize)
                .foregroundColor(.primary)
        }
        .frame(width: Const.Size.closeButtonTappableArea, height: Const.Size.closeButtonTappableArea)
        .contentShape(Rectangle())
    }
    
    var titleHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                FaviconView(viewModel: FaviconViewModel(domain: viewModel.domain))
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(viewModel.domain)
                    .font(Const.Fonts.titleCaption)
                    .foregroundColor(Const.Colors.SecondaryTextColor)
            }
            
            VStack {
                messageView
            }
        }
    }
    
    var messageView: some View {
        Text(viewModel.message)
            .font(Const.Fonts.title)
            .minimumScaleFactor(0.5)
            .foregroundColor(Const.Colors.PrimaryTextColor)
            .padding()
            .lineLimit(1)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(.primary)
            .cornerRadius(Const.Size.CTAButtonCornerRadius)
    }
    
    var accountButtonsContainer: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: viewModel.shouldUseScrollView) {
                VStack {
                    accountButtons
                    if viewModel.expanded {
                        Spacer()
                    } else {
                        Spacer()
                            .frame(height: 44)
                    }
                }
                .frame(minHeight: geometry.size.height)
            }
            .padding(.trailing, 8 + Const.Size.buttonBorderWidth)
            .padding(.leading, 8 + Const.Size.buttonBorderWidth)
        }
    }
    
    var accountButtons: some View {
        Group {
            ForEach(viewModel.accountMatchesViewModels.indices, id: \.self) { group in
                VStack(spacing: 12) {
                    buttonGroupTitle(for: viewModel.accountMatchesViewModels[group])
                    ForEach(viewModel.accountMatchesViewModels[group].accounts.indices, id: \.self) { index in
                        let accountViewModel = viewModel.accountMatchesViewModels[group].accounts[index]
                        let isPerfectMatch = viewModel.accountMatchesViewModels[group].isPerfectMatch
                        accountButton(for: accountViewModel,
                                      style: index == 0 && isPerfectMatch ? .primary : .secondary)
                    }
                }
            }
            if viewModel.showMoreOptions {
                moreOptionsButton
            }
        }
    }

    private func buttonGroupTitle(for accountViewModelGroup: AccountMatchesViewModel) -> some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(accountViewModelGroup.title)
                        .font(Const.Fonts.titleCaption)
                        .foregroundColor(Const.Colors.SecondaryTextColor)
                        .truncationMode(.middle)
                        .frame(width: Const.Size.contentWidth - 64)
                        .lineLimit(1)
            }
        }
        .padding(.top, viewModel.expanded ? 22 : 0)
    }

    private enum AccountButtonStyle {
        case primary
        case secondary
    }
    
    private func accountButton(for accountViewModel: AccountViewModel, style: AccountButtonStyle) -> some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.didSelectAccount(accountViewModel.account)
            } label: {
                Text(accountViewModel.displayString)
                    .font(Const.Fonts.CTA)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(style == .primary ? Const.Colors.CTAPrimaryForeground : Const.Colors.CTASecondaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight - Const.Size.buttonBorderWidth)
                    .background(style == .primary ? Const.Colors.CTAPrimaryBackground : Const.Colors.CTASecondaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.Size.CTAButtonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Const.Size.CTAButtonCornerRadius)
                            .stroke(style == .primary ? Const.Colors.CTAPrimaryBackground : Const.Colors.CTASecondaryBorder,
                                    lineWidth: Const.Size.buttonBorderWidth)
                    )
            }
            .frame(width: Const.Size.contentWidth - Const.Size.buttonBorderWidth)
            .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
            
            Spacer()
        }
    }
    
    var moreOptionsButton: some View {
        Button {
            viewModel.didExpand()
        } label: {
            Text(viewModel.moreOptionsButtonString)
                .font(Const.Fonts.CTA)
                .foregroundColor(Const.Colors.CTASecondaryForeground)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                .background(Const.Colors.CTATertiaryBackground)
                .foregroundColor(.primary)
                .cornerRadius(Const.Size.CTAButtonCornerRadius)
        }
        .frame(width: Const.Size.contentWidth - Const.Size.buttonBorderWidth)
    }
    
    var footer: some View {
        HStack {
            Spacer()
                .padding(.bottom, 44)
        }
    }
}

// MARK: - Constants

private enum Const {
    enum Fonts {
        static let title = Font.system(.title3).weight(.bold)
        static let titleCaption = Font.system(.footnote)
        static let CTA = Font(UIFont.boldAppFont(ofSize: 16))
    }
    
    enum Colors {
        static let CTAPrimaryBackground = Color("CTAPrimaryBackground")
        static let CTASecondaryBackground = Color("CTASecondaryBackground")
        static let CTATertiaryBackground = Color("CTATertiaryBackground")
        static let CTAPrimaryForeground = Color("CTAPrimaryForeground")
        static let CTASecondaryForeground = Color("CTASecondaryForeground")
        static let PrimaryTextColor = Color("PrimaryTextColor")
        static let SecondaryTextColor = Color("SecondaryTextColor")
        static let CTASecondaryBorder = Color("CTASecondaryBorder")
    }
    
    enum Size {
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
        static let contentWidth: CGFloat = 286
        static let closeButtonSize: CGFloat = 13
        static let closeButtonTappableArea: CGFloat = 44
        static let buttonBorderWidth: CGFloat = 2
    }
}

// MARK: - Preview

struct AutofillLoginPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.light)
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.dark)
    }
}
