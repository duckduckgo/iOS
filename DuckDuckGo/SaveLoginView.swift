//
//  SaveLoginView.swift
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

struct SaveLoginView: View {
    enum LayoutType {
        case newUser
        case saveLogin
        case savePassword
        case saveAdditionalLogin
        case updateUsername
        case updatePassword
    }
    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: SaveLoginViewModel
    var layoutType: LayoutType {
        viewModel.layoutType
    }
    
    private var title: String {
        switch layoutType {
        case .newUser:
            return UserText.autofillSaveLoginTitleNewUser
        case .saveLogin, .saveAdditionalLogin:
            return UserText.autofillSaveLoginTitle
        case .savePassword:
            return UserText.autofillSavePasswordTitle
        case .updateUsername:
            return UserText.autofillUpdateUsernameTitle
        case .updatePassword:
            return UserText.autofillUpdatePasswordTitle
        }
    }
    
    private var confirmButton: String {
        switch layoutType {
        case .newUser, .saveLogin, .saveAdditionalLogin:
            return UserText.autofillSaveLoginSaveCTA
        case .savePassword:
            return UserText.autofillSavePasswordSaveCTA
        case .updateUsername:
            return UserText.autofillUpdateLoginSaveCTA
        case .updatePassword:
            return UserText.autofillUpdatePasswordSaveCTA
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
    }
    
    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        
        return ZStack {
            closeButtonHeader
            
            VStack(spacing: 0) {
                titleHeaderView
                contentView
                ctaView
                Spacer()
            }
            .frame(width: Const.Size.contentWidth)
            .padding(.top, isSmallFrame ? 19 : 43)
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
            viewModel.cancel()
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
        VStack {
            HStack {
                Image(uiImage: viewModel.faviconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(viewModel.accountDomain)
                    .font(Const.Fonts.titleCaption)
                    .foregroundColor(Const.Colors.SecondaryTextColor)
            }
            
            VStack {
                Text(title)
                    .font(Const.Fonts.title)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, isSmallFrame ? 15 : 25)
        }
    }
    
    var ctaView: some View {
        SaveLoginCTAStackView(confirmLabel: confirmButton,
                              cancelLabel: UserText.autofillSaveLoginNotNowCTA,
                              confirmAction: {
            viewModel.save()
        }, cancelAction: {
            viewModel.cancel()
        })
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch layoutType {
        case .newUser:
            newUserContentView
        case .saveLogin, .savePassword:
            saveContentView
        case .saveAdditionalLogin:
            additionalLoginContentView
        case .updateUsername, .updatePassword:
            updateContentView
        }
    }
    
    private var newUserContentView: some View {
        Text(UserText.autofillSaveLoginMessageNewUser)
            .font(Const.Fonts.subtitle)
            .foregroundColor(Const.Colors.SecondaryTextColor)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, isSmallFrame ? 28 : 30)
            .padding(.top, isSmallFrame ? 10 : 24)
            .padding(.bottom, isSmallFrame ? 15 : 40)
    }
    
    private var saveContentView: some View {
        Spacer(minLength: 60)
    }
    
    private var updateContentView: some View {
        Text(verbatim: layoutType == .updatePassword ? viewModel.hiddenPassword : viewModel.username)
            .font(Const.Fonts.userInfo)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    private var additionalLoginContentView: some View {
        Text(verbatim: UserText.autofillAdditionalLoginInfoMessage)
            .font(Const.Fonts.subtitle)
            .foregroundColor(Const.Colors.SecondaryTextColor)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    // We have specific layouts for the smaller iPhones
    private var isSmallFrame: Bool {
        frame.width <= 320 || frame.height <= 320
    }
}

struct SaveLoginView_Previews: PreviewProvider {
    private struct MockManager: AutofillCredentialManagerProtocol {
        var username: String { "dax@duck.com" }
        var visiblePassword: String { "supersecurepasswordquack" }
        var isNewAccount: Bool { false }
        var accountDomain: String { "duck.com" }
        var isUsernameOnlyAccount: Bool { false }
        var isPasswordOnlyAccount: Bool { false }
        var hasOtherCredentialsOnSameDomain: Bool { false }
        static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws { }
    }
    
    static var previews: some View {
        Group {
            VStack {
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .newUser)
                SaveLoginView(viewModel: viewModel)
                
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .saveLogin)
                SaveLoginView(viewModel: viewModel)
            }
            
            VStack {
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .updatePassword)
                SaveLoginView(viewModel: viewModel)
                
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .updateUsername)
                SaveLoginView(viewModel: viewModel)
            }
            
            VStack {
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .saveAdditionalLogin)
                SaveLoginView(viewModel: viewModel)
                
                let viewModel = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .savePassword)
                SaveLoginView(viewModel: viewModel)
            }
        }
        
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
    }
}

extension Color {
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}

private struct SaveLoginCTAStackView: View {
    let confirmLabel: String
    let cancelLabel: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void
    
    var body: some View {
        VStack {
            Button {
                confirmAction()
            } label: {
                Text(confirmLabel)
                    .font(Const.Fonts.CTA)
                    .foregroundColor(Const.Colors.CTAPrimaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                    .background(Const.Colors.CTAPrimaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.CornerRadius.CTA)
            }
            
            Button {
                cancelAction()
            } label: {
                Text(cancelLabel)
                    .font(Const.Fonts.CTA)
                    .foregroundColor(Const.Colors.CTASecondaryForeground)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Const.Size.CTAButtonMaxHeight)
                    .background(Const.Colors.CTASecondaryBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(Const.CornerRadius.CTA)
            }
        }
    }
}

struct SaveLoginCTAStackView_Previews: PreviewProvider {
    static var previews: some View {
        SaveLoginCTAStackView(confirmLabel: "Save Login", cancelLabel: "Not Now", confirmAction: {}, cancelAction: {})
    }
}
