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
                Spacer(minLength: Const.Size.topPadding)
                AutofillViews.AppIconHeader()
                Spacer(minLength: Const.Size.contentSpacing)
                AutofillViews.Headline(title: title)
                Spacer(minLength: Const.Size.contentSpacing)
                contentView
                Spacer(minLength: Const.Size.contentSpacing)
                if case .newUser = layoutType {
                    featuresView.padding([.bottom], 16)
                }
                ctaView
            }
            .padding([.bottom], 24.0)
            .fixedSize(horizontal: false, vertical: shouldFixSize)
            .background(GeometryReader { proxy -> Color in
                DispatchQueue.main.async { viewModel.contentHeight = proxy.size.height }
                return Color.clear
            })
            .useScrollView(shouldUseScrollView(), minHeight: frame.height)
        }
        .padding(.horizontal, horizontalPadding)
    }

    var shouldFixSize: Bool {
        AutofillViews.isIPhonePortrait(verticalSizeClass, horizontalSizeClass) || AutofillViews.isIPad(verticalSizeClass, horizontalSizeClass)
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

    @ViewBuilder private func featuresListItem(imageTitle: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(imageTitle).frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(
                        .custom("SF Pro Text",
                                size: 13)
                        .weight(.bold)
                    )
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Text(subtitle)
                    .font(
                        .custom("SF Pro Text",
                                size: 13)
                    )
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder private var featuresView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Text(UserText.autofillOnboardingKeyFeaturesTitle)
                    .font(Font.custom("SF Pro Text", size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .frame(width: 255, alignment: .top)
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
            Rectangle()
                .fill(Color(designSystemColor: .container))
                .frame(height: 1)
            VStack(alignment: .leading, spacing: 12) {
                featuresListItem(
                    imageTitle: "Autofill-Color-24",
                    title: UserText.autofillOnboardingKeyFeaturesSignInsTitle,
                    subtitle: UserText.autofillOnboardingKeyFeaturesSignInsDescription
                )
                featuresListItem(
                    imageTitle: "Lock-Color-24",
                    title: UserText.autofillOnboardingKeyFeaturesSecureStorageTitle,
                    subtitle: viewModel.secureStorageDescription
                )
                featuresListItem(
                    imageTitle: "Sync-Color-24",
                    title: UserText.autofillOnboardingKeyFeaturesSyncTitle,
                    subtitle: UserText.autofillOnboardingKeyFeaturesSyncDescription
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color(designSystemColor: .container), lineWidth: 1)
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var ctaView: some View {
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
        static let contentSpacing: CGFloat = 24.0
        static let ios15scrollOffset: CGFloat = 80.0
        static let ctaVerticalSpacing: CGFloat = 8.0
        static let featureListItemIconGap: CGFloat = 8.0
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
