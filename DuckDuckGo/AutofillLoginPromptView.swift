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
    
    //TODO can we tell if a user swiped up/expoanded? cos then we should show the full list
    //also special behabiour for when swipe up and there's more
    
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
            .frame(width: Const.Size.contentWidth)
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
            .background(Color.saveButton)
            .foregroundColor(.primary)
            .cornerRadius(Const.CornerRadius.CTA)
    }
    
    var accountButtons: some View {
        VStack {
            if viewModel.accountsViewModels.count <= 3 {
                ForEach(viewModel.accountsViewModels.indices, id: \.self) { index in
                    let accountViewModel = viewModel.accountsViewModels[index]
                    accountButton(for: accountViewModel, style: index == 0 ? .primary : .secondary)
                }
            } else {
                accountButton(for: viewModel.accountsViewModels[0], style: .primary)
                accountButton(for: viewModel.accountsViewModels[0], style: .secondary)
                //TODO other button
            }
        }
    }
    
    private enum AccountButtonStyle {
        case primary
        case secondary
    }
    
    private func accountButton(for accountViewModel: AccountViewModel, style: AccountButtonStyle) -> some View {
        Button {
            viewModel.didSelectAccount(accountViewModel.account)
        } label: {
            Text(accountViewModel.displayString) // TODO email formatting
                .font(.CTA)
                .foregroundColor(style == .primary ? Const.Colors.CTAPrimaryForeground : Const.Colors.CTASecondaryForeground)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Constants.CTAButtonMaxHeight)
                .background(style == .primary ? Const.Colors.CTAPrimaryBackground : Const.Colors.CTASecondaryBackground)
                .foregroundColor(.primary)
                .cornerRadius(Constants.CTAButtonCornerRadius)
        }
    }
    
    var keyboardButtonFooter: some View {
        HStack {
            keyboardButton
                .padding(.leading, 20)//8.5)
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
                .foregroundColor(.keyboardColor)
        }
        .frame(width: Const.Size.closeButtonTappableArea, height: Const.Size.closeButtonTappableArea)
        .contentShape(Rectangle())
    }
}

// MARK: - Constants

private extension Color {
    static let saveButton = Color("CTAPrimaryColor")
    static let cancelButton = Color("FormSecondaryBackgroundColor")
    static let formBackground = Color("FormSecondaryBackgroundColor")
    static let keyboardColor = Color("AutofillPromptKeyboard")
}

@available(iOS 14.0, *)
private extension AutofillLoginPromptView {
    private struct Constants {
        static let formPadding: CGFloat = 45
        static let formBackgroundCornerRadius: CGFloat = 13
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
    }
}

private enum Const {
    enum Fonts {
        static let title = Font.system(size: 20).weight(.bold)
        static let subtitle = Font.system(size: 13.0)
        static let updatedInfo = Font.system(size: 16)
        static let titleCaption = Font.system(size: 13)
        static let userInfo = Font.system(size: 13).weight(.bold)
        static let CTA = Font(UIFont.boldAppFont(ofSize: 16))
        
    }
    
    enum CornerRadius {
        static let CTA: CGFloat = 12
    }
    
    enum Colors {
        static let CTAPrimaryBackground = Color("CTAPrimaryBackground")
        static let CTASecondaryBackground = Color("CTASecondaryBackground")
        static let CTAPrimaryForeground = Color("CTAPrimaryForeground")
        static let CTASecondaryForeground = Color("CTASecondaryForeground")
        static let SecondaryTextColor = Color("SecondaryTextColor")
    }
    
    enum Margin {
        static var closeButtonMargin: CGFloat {
            Const.Size.closeButtonOffset - 21
        }
    }
    
    enum Size {
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
        static let contentWidth: CGFloat = 286
        static let closeButtonSize: CGFloat = 13
        static let closeButtonTappableArea: CGFloat = 44
        static var closeButtonOffset: CGFloat {
            closeButtonTappableArea - closeButtonSize
        }
        static let keyboardButtonWidth: CGFloat = 30
        static let keyboardButtonHeight: CGFloat = 26
    }
}

extension Color {
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}

private extension Font {
    static let CTA = Font(uiFont: UIFont.boldAppFont(ofSize: 16))
}

// MARK: - Preview

@available(iOS 14.0, *)
struct AutofillLoginPromptView_Previews: PreviewProvider {
    static var previews: some View {
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.light)
        AutofillLoginPromptView(viewModel: AutofillLoginPromptViewModel.preview).preferredColorScheme(.dark)
    }
}
