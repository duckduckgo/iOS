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
import DesignResourcesKit

struct SaveLoginView: View {
    enum LayoutType {
        case newUser
        case saveLogin
        case savePassword
        case updateUsername
        case updatePassword
    }
    @State var frame: CGSize = .zero
    @ObservedObject var viewModel: SaveLoginViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var orientation = UIDevice.current.orientation

    private var layoutType: LayoutType {
        viewModel.layoutType
    }

    private var usernameDisplayString: String {
        AutofillInterfaceUsernameTruncator.truncateUsername(viewModel.username, maxLength: 50)
    }

    private var title: String {
        switch layoutType {
        case .newUser, .saveLogin, .savePassword:
            return UserText.autofillSaveLoginTitleNewUser
        case .updateUsername:
            return UserText.autofillUpdateUsernameTitle
        case .updatePassword:
            return UserText.autofillUpdatePassword(for: usernameDisplayString)
        }
    }
    
    private var confirmButton: String {
        switch layoutType {
        case .newUser, .saveLogin, .savePassword:
            return UserText.autofillSavePasswordSaveCTA
        case .updateUsername:
            return UserText.autofillUpdateUsernameSaveCTA
        case .updatePassword:
            return UserText.autofillUpdatePasswordSaveCTA
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            makeBodyView(geometry)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }
    
    private func makeBodyView(_ geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.frame = geometry.size }
        
        return ZStack {
            AutofillViews.CloseButtonHeader(action: viewModel.cancelButtonPressed)
                .offset(x: horizontalPadding)
                .zIndex(1)

            VStack {
                Spacer()
                    .frame(height: Const.Size.topPadding)
                AutofillViews.AppIconHeader()
                Spacer()
                    .frame(height: Const.Size.headlineTopPadding)
                AutofillViews.Headline(title: title)
                if #available(iOS 16.0, *) {
                    contentView
                        .padding([.top, .bottom], contentPadding)
                } else {
                    Spacer()
                    contentView
                    Spacer()
                }
                ctaView
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

        if #available(iOS 16.0, *) {
            useScrollView = AutofillViews.contentHeightExceedsScreenHeight(viewModel.contentHeight)
        } else {
            useScrollView = viewModel.contentHeight > frame.height + Const.Size.ios15scrollOffset
        }

        return useScrollView
    }

    private var contentPadding: CGFloat {
        if AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) {
            return Const.Size.contentSpacerHeight
        } else if AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) {
            return Const.Size.contentSpacerHeightIPad
        } else {
            return Const.Size.contentSpacerHeightLandscape
        }
    }

    private var ctaView: some View {
        VStack(spacing: Const.Size.ctaVerticalSpacing) {
            AutofillViews.PrimaryButton(title: confirmButton,
                                        action: viewModel.save)

            AutofillViews.TertiaryButton(title: UserText.autofillSaveLoginNeverPromptCTA,
                                         action: viewModel.neverPrompt)
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

    private var bottomSpacer: some View {
        VStack {
            if AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) {
                AutofillViews.LegacySpacerView(height: Const.Size.bottomSpacerHeight, legacyHeight: Const.Size.bottomSpacerLegacyHeight)
            } else if AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass) {
                AutofillViews.LegacySpacerView(height: Const.Size.bottomSpacerHeightIPad,
                                               legacyHeight: orientation == .portrait ? Const.Size.bottomSpacerHeightIPad
                                                                                      : Const.Size.bottomSpacerLegacyHeightIPad)
            } else {
                AutofillViews.LegacySpacerView(height: Const.Size.bottomSpacerHeight,
                                               legacyHeight: Const.Size.bottomSpacerLegacyHeightLandscape)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch layoutType {
        case .newUser, .saveLogin, .savePassword, .updatePassword:
            let text = layoutType == .updatePassword ? UserText.autoUpdatePasswordMessage : UserText.autofillSaveLoginMessageNewUser
            AutofillViews.Description(text: text)
        case .updateUsername:
            updateUsernameContentView
        }
    }

    private var updateUsernameContentView: some View {
        Text(verbatim: viewModel.usernameTruncated)
            .font(Const.Fonts.userInfo)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
}

private enum Const {
    enum Fonts {
        static let userInfo = Font.system(.footnote).weight(.bold)
    }

    enum Size {
        static let closeButtonOffset: CGFloat = 48.0
        static let closeButtonOffsetPortrait: CGFloat = 44.0
        static let closeButtonOffsetPortraitSmallFrame: CGFloat = 16.0
        static let topPadding: CGFloat = 56.0
        static let headlineTopPadding: CGFloat = 24.0
        static let ios15scrollOffset: CGFloat = 80.0
        static let contentSpacerHeight: CGFloat = 24.0
        static let contentSpacerHeightIPad: CGFloat = 34.0
        static let contentSpacerHeightLandscape: CGFloat = 44.0
        static let ctaVerticalSpacing: CGFloat = 8.0
        static let bottomSpacerHeight: CGFloat = 12.0
        static let bottomSpacerHeightIPad: CGFloat = 24.0
        static let bottomSpacerLegacyHeight: CGFloat = 16.0
        static let bottomSpacerLegacyHeightIPad: CGFloat = 64.0
        static let bottomSpacerLegacyHeightLandscape: CGFloat = 44.0
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
        
        static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: AutofillVaultFactory) throws -> Int64 { return 0 }
    }
    
    static var previews: some View {
        Group {
            let viewModelNewUser = SaveLoginViewModel(credentialManager: MockManager(),
                                                      appSettings: AppDependencyProvider.shared.appSettings,
                                                      layoutType: .newUser)
            let viewModelSaveLogin = SaveLoginViewModel(credentialManager: MockManager(),
                                                        appSettings: AppDependencyProvider.shared.appSettings,
                                                        layoutType: .saveLogin)

            VStack {
                SaveLoginView(viewModel: viewModelNewUser)
                SaveLoginView(viewModel: viewModelSaveLogin)
            }.preferredColorScheme(.dark)
            
            VStack {
                SaveLoginView(viewModel: viewModelNewUser)
                SaveLoginView(viewModel: viewModelSaveLogin)
            }.preferredColorScheme(.light)
            
            VStack {
                let viewModelUpdatePassword = SaveLoginViewModel(credentialManager: MockManager(),
                                                                 appSettings: AppDependencyProvider.shared.appSettings,
                                                                 layoutType: .updatePassword)
                SaveLoginView(viewModel: viewModelUpdatePassword)
                
                let viewModelUpdateUsername = SaveLoginViewModel(credentialManager: MockManager(),
                                                                 appSettings: AppDependencyProvider.shared.appSettings,
                                                                 layoutType: .updateUsername)
                SaveLoginView(viewModel: viewModelUpdateUsername)
            }
            
            VStack {
                let viewModelAdditionalLogin = SaveLoginViewModel(credentialManager: MockManager(),
                                                                  appSettings: AppDependencyProvider.shared.appSettings,
                                                                  layoutType: .saveLogin)
                SaveLoginView(viewModel: viewModelAdditionalLogin)
                
                let viewModelSavePassword = SaveLoginViewModel(credentialManager: MockManager(),
                                                               appSettings: AppDependencyProvider.shared.appSettings,
                                                               layoutType: .savePassword)
                SaveLoginView(viewModel: viewModelSavePassword)
            }
        }
    }
}
