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
import DuckUI
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var layoutType: LayoutType {
        viewModel.layoutType
    }
    
    private var title: String {
        switch layoutType {
        case .newUser, .saveLogin:
            return UserText.autofillSaveLoginTitleNewUser
        case .saveAdditionalLogin:
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
        .padding([.horizontal], isIPhonePortrait ? 16 : 48)
        .ignoresSafeArea()
    }
    
    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        // Workaround for the isSmallFrame property to return the correct value
        // .async to fix the "Modifying state during view update, this will cause undefined behavior." issue
        // TODO remove this for V2
        DispatchQueue.main.async { self.frame = geometry.size }
        
        return ZStack {
            closeButtonHeader
            
            VStack(spacing: 0) {
                titleHeaderView
                if isIPad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(maxHeight: isSmallFrame ? 8 : 24)
                }
                contentView
                if isIPad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(maxHeight: isSmallFrame ? 24 : 40)
                }
                ctaView
                if isIPhonePortrait {
                    Spacer()
                } else {
                    Spacer(minLength: isIPad ? 64 : 32)
                }
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
        VStack(spacing: 0) {
            HStack {
                FaviconView(viewModel: FaviconViewModel(domain: viewModel.accountDomain))
                    .scaledToFit()
                    .frame(width: Const.Size.logoImage, height: Const.Size.logoImage)
                Text(viewModel.accountDomain)
                    .secondaryTextStyle()
                    .font(Const.Fonts.titleCaption)
            }

            Text(title)
                .font(Const.Fonts.title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, isSmallFrame ? 2 : (isIPhonePortrait ? 25 : 29))
        }
        .frame(width: isIPhone ? Const.Size.contentWidth : frame.width)
        .padding(.top, isSmallFrame ? 20 : (isIPhonePortrait ? 40 : 54))
    }
    
    var ctaView: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.save()
            } label: {
                Text(confirmButton)
            }.buttonStyle(PrimaryButtonStyle())
            
            Button {
                viewModel.cancel()
            } label: {
                Text(UserText.autofillSaveLoginNotNowCTA)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(width: isIPhonePortrait ? Const.Size.contentWidth : frame.width)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch layoutType {
        case .newUser, .saveLogin, .savePassword:
            newUserContentView
        case .saveAdditionalLogin:
            additionalLoginContentView
        case .updateUsername, .updatePassword:
            updateContentView
        }
    }
    
    private var newUserContentView: some View {
        Text(UserText.autofillSaveLoginMessageNewUser)
            .font(Const.Fonts.subtitle)
            .secondaryTextStyle()
            .multilineTextAlignment(.center)
            .padding(.horizontal, isSmallFrame ? Const.Size.paddingSmallDevice : Const.Size.paddingDefault)
            .frame(width: isIPhonePortrait ? Const.Size.contentWidth : frame.width)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var updateContentView: some View {
        Text(verbatim: layoutType == .updatePassword ? viewModel.hiddenPassword : viewModel.username)
            .font(Const.Fonts.userInfo)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    private var additionalLoginContentView: some View {
        Text(verbatim: UserText.autofillAdditionalLoginInfoMessage)
            .font(Const.Fonts.subtitle)
            .secondaryTextStyle()
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    // We have specific layouts for the smaller iPhones
    private var isSmallFrame: Bool {
        frame.width <= Const.Size.smallDevice || frame.height <= Const.Size.smallDevice
    }

    private var isIPhonePortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var isIPhone: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .compact
    }

    private var isIPad: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .regular
    }
}

struct SaveLoginView_Previews: PreviewProvider {
    private struct MockManager: SaveAutofillLoginManagerProtocol {
        
        var username: String { "dax@duck.com" }
        var visiblePassword: String { "supersecurepasswordquack" }
        var isNewAccount: Bool { false }
        var accountDomain: String { "duck.com" }
        var isPasswordOnlyAccount: Bool { false }
        var hasOtherCredentialsOnSameDomain: Bool { false }
        var hasSavedMatchingPasswordWithoutUsername: Bool { false }
        var hasSavedMatchingUsername: Bool { false }
        
        static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws -> Int64 { return 0 }
    }
    
    static var previews: some View {
        Group {
            let viewModelNewUser = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .newUser)
            let viewModelSaveLogin = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .saveLogin)

            VStack {
                SaveLoginView(viewModel: viewModelNewUser)
                SaveLoginView(viewModel: viewModelSaveLogin)
            }.preferredColorScheme(.dark)
            
            VStack {
                SaveLoginView(viewModel: viewModelNewUser)
                SaveLoginView(viewModel: viewModelSaveLogin)
            }.preferredColorScheme(.light)
            
            VStack {
                let viewModelUpdatePassword = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .updatePassword)
                SaveLoginView(viewModel: viewModelUpdatePassword)
                
                let viewModelUpdateUsername = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .updateUsername)
                SaveLoginView(viewModel: viewModelUpdateUsername)
            }
            
            VStack {
                let viewModelAdditionalLogin = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .saveAdditionalLogin)
                SaveLoginView(viewModel: viewModelAdditionalLogin)
                
                let viewModelSavePassword = SaveLoginViewModel(credentialManager: MockManager(), layoutType: .savePassword)
                SaveLoginView(viewModel: viewModelSavePassword)
            }
        }
        
    }
}

private enum Const {
    enum Fonts {
        static let title = Font.system(.title3).weight(.bold)
        static let subtitle = Font.system(.footnote)
        static let updatedInfo = Font.system(.callout)
        static let titleCaption = Font.system(.footnote)
        static let userInfo = Font.system(.footnote).weight(.bold)
    }

    enum Margin {
        static var closeButtonMargin: CGFloat {
            Const.Size.closeButtonOffset - 21
        }
    }
    
    enum Size {
        static let contentWidth: CGFloat = 286
        static let closeButtonSize: CGFloat = 13
        static let closeButtonTappableArea: CGFloat = 44
        static let logoImage: CGFloat = 20
        static let smallDevice: CGFloat = 320
        static var closeButtonOffset: CGFloat {
            closeButtonTappableArea - closeButtonSize
        }
        static let paddingSmallDevice: CGFloat = 28
        static let paddingDefault: CGFloat = 30
    }
}
