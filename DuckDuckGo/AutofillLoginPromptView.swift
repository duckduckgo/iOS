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

@available(iOS 14.0, *)
struct AutofillLoginPromptView: View {
    @ObservedObject var viewModel: AutofillLoginPromptViewModel
    
    var body: some View {
        mainView()
            .ignoresSafeArea()
    }
    
    //TODO gonna have to test 14
        
    //TODO steal fernando's email trimming logic
        
    private func mainView() -> some View {
        ZStack {
            closeButtonHeader
            
            VStack {
            VStack(spacing: 0) {
                titleHeaderView
                Spacer()
                accountButtons
                Spacer()
            }
            .padding(.top, 43)
                
            keyboardButtonFooter
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
                Image(uiImage: viewModel.faviconImage)
                    .resizable()
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
            .foregroundColor(.black)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
            .foregroundColor(.primary)
            .cornerRadius(Const.Size.CTAButtonCornerRadius)
    }
    
    var accountButtons: some View {
        VStack {
            if viewModel.accountsViewModels.count <= 3 {
                ForEach(viewModel.accountsViewModels.indices, id: \.self) { index in
                    let accountViewModel = viewModel.accountsViewModels[index]
                    accountButton(for: accountViewModel, style: index == 0 ? .primary : .secondary)
                }
            } else {
                if !viewModel.expanded {
                    accountButton(for: viewModel.accountsViewModels[0], style: .primary)
                    accountButton(for: viewModel.accountsViewModels[1], style: .secondary)
                    moreOptionsButton
                } else {
                    ScrollView {
                        VStack {
                            ForEach(viewModel.accountsViewModels.indices, id: \.self) { index in
                                let accountViewModel = viewModel.accountsViewModels[index]
                                accountButton(for: accountViewModel, style: index == 0 ? .primary : .secondary)
                            }
                        }
                    }
                    .padding(.trailing, 8)
                    .padding(.leading, 8)
                }
            }
        }
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
                Text(accountViewModel.displayString) // TODO email formatting
                    .font(Const.Fonts.CTA)
                    .foregroundColor(style == .primary ? Const.Colors.CTAPrimaryForeground : Const.Colors.CTASecondaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                    .background(style == .primary ? Const.Colors.CTAPrimaryBackground : Const.Colors.CTASecondaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.Size.CTAButtonCornerRadius)
            }
            .frame(width: Const.Size.contentWidth)
            
            Spacer()
        }
    }
    
    var moreOptionsButton: some View {
        Button {
            viewModel.didExpand()
        } label: {
            Text(viewModel.moreOptionsButtonString) // TODO email formatting
                .font(Const.Fonts.CTA)
                .foregroundColor(Const.Colors.CTASecondaryForeground)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                .background(Color.clear)
                .foregroundColor(.primary)
                .cornerRadius(Const.Size.CTAButtonCornerRadius)
        }
    }
    
    var keyboardButtonFooter: some View {
        HStack {
            keyboardButton
                .padding(.leading, 20)
                .padding(.bottom, 18)
            Spacer()
        }
    }
    
    private var keyboardButton: some View {
        Button {
            viewModel.dismissView()
        } label: {
            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: Const.Size.keyboardButtonWidth, height: Const.Size.keyboardButtonHeight)
                .foregroundColor(Const.Colors.keyboardColor)
        }
        .frame(width: Const.Size.keyboardButtonTappableArea, height: Const.Size.keyboardButtonTappableArea)
        .contentShape(Rectangle())
    }
}

// MARK: - Constants

private enum Const {
    enum Fonts {
        static let title = Font.system(size: 20).weight(.bold)
        static let titleCaption = Font.system(size: 13)
        static let CTA = Font(UIFont.boldAppFont(ofSize: 16))
    }
    
    enum Colors {
        static let CTAPrimaryBackground = Color("CTAPrimaryBackground")
        static let CTASecondaryBackground = Color("CTASecondaryBackground")
        static let CTAPrimaryForeground = Color("CTAPrimaryForeground")
        static let CTASecondaryForeground = Color("CTASecondaryForeground")
        static let SecondaryTextColor = Color("SecondaryTextColor")
        static let keyboardColor = Color("AutofillPromptKeyboard")
    }
    
    enum Size {
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
        static let contentWidth: CGFloat = 286
        static let closeButtonSize: CGFloat = 13
        static let closeButtonTappableArea: CGFloat = 44
        static let keyboardButtonWidth: CGFloat = 30
        static let keyboardButtonHeight: CGFloat = 26
        static let keyboardButtonTappableArea: CGFloat = 44
    }
}

// MARK: - Preview

@available(iOS 14.0, *)
struct AutofillLoginPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.light)
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.dark)
    }
}
