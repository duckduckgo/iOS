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

struct SaveLoginView: View {
    enum LayoutType {
        case newUser
        case saveLogin
        case savePassword
        case saveAdditionalLogin
        case updateUsername
        case updatePassword
    }
    
    let viewModel: SaveLoginViewModel
    let layoutType: LayoutType
    
    private var title: String {
        switch layoutType {
        case .newUser:
            return UserText.loginPlusSaveLoginTitleNewUser
        case .saveLogin, .saveAdditionalLogin:
            return UserText.loginPlusSaveLoginTitle
        case .savePassword:
            return "Save Password?"
        case .updateUsername:
            return "Update Username?"
        case .updatePassword:
            return "Update Password?"
        }
    }
    
    private var confirmButton: String {
        switch layoutType {
        case .newUser, .saveLogin, .saveAdditionalLogin:
            return UserText.loginPlusSaveLoginSaveCTA
        case .savePassword:
            return "Save Password"
        case .updateUsername:
            return "Update Login"
        case .updatePassword:
            return "Update Password"
        }
    }
    
    private var buttonsStackTopPadding: CGFloat {
        if viewModel.password != nil || viewModel.username != nil  || viewModel.subtitle == nil {
            return 53
        } else {
            return 0
        }
    }
    private var userInfo: String? {
        if let username = viewModel.username {
            return username
        }
        if let password = viewModel.password {
            return password
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                closeButton
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "globe")
                    Text("blablala.com")
                        .font(Const.Fonts.titleCaption)
                }
                .padding(.top, 5)
                
                VStack {
                    Text(title)
                        .font(Const.Fonts.title)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }.padding(.top, 25)
                
                contentView
                
                SaveLoginCTAStackView(confirmLabel: confirmButton,
                                      cancelLabel: viewModel.cancelButtonLabel,
                                      confirmAction: {
                    print("Save")
                }, cancelAction: {
                    print("Not now")
                })
                
                Spacer()
            }.frame(width: Const.Size.contentWidth)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch layoutType {
        case .newUser:
            newUserContentView
        case .saveLogin, .savePassword:
            saveContentView
        case .saveAdditionalLogin:
            aditionalLoginContentView
        case .updateUsername, .updatePassword:
            updateContentView
        }
    }
    
    private var newUserContentView: some View {
        Text(UserText.loginPlusSaveLoginMessageNewUser)
            .font(Const.Fonts.subtitle)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, 24)
            .padding(.bottom, 40)
    }
    
    private var saveContentView: some View {
        Spacer(minLength: 60)
    }
    
    private var updateContentView: some View {
        Text(verbatim: "me@email.com")
            .font(Const.Fonts.userInfo)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    private var aditionalLoginContentView: some View {
        Text(verbatim: "This will save an additional Login for this site.")
            .font(Const.Fonts.subtitle)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 56)
            .padding(.bottom, 56)
    }
    
    private var closeButton: some View {
        Button {
        } label: {
            Image(systemName: "xmark")
                .frame(width: 13, height: 13)
                .foregroundColor(.primary)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

struct SaveLoginView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SaveLoginViewModel(title: UserText.loginPlusSaveLoginTitleNewUser,
                                           subtitle: UserText.loginPlusSaveLoginMessageNewUser,
                                           confirmButtonLabel: UserText.loginPlusSaveLoginSaveCTA,
                                           cancelButtonLabel: UserText.loginPlusSaveLoginNotNowCTA)
        SaveLoginView(viewModel: viewModel, layoutType: .saveAdditionalLogin)
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
        
    }
    
    enum Size {
        static let CTAButtonCornerRadius: CGFloat = 12
        static let CTAButtonMaxHeight: CGFloat = 50
        static let contentWidth: CGFloat = 286
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
