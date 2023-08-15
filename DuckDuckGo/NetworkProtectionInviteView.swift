//
//  NetworkProtectionInviteView.swift
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

#if NETWORK_PROTECTION

import SwiftUI
import DesignResourcesKit
import DuckUI

struct NetworkProtectionInviteView: View {
    @ObservedObject var model: NetworkProtectionInviteViewModel

    var body: some View {
        Group {
            switch model.currentStep {
            case .codeEntry:
                codeEntryView
            case .success:
                successView
            }
        }
        .transition(.slideFromRight)
        .animation(.default, value: model.currentStep.isSuccess)
    }

    @ViewBuilder
    private var codeEntryView: some View {
        let messageData = NetworkProtectionInviteMessageData(
            imageIdentifier: "InviteLock",
            title: UserText.netPInviteTitle,
            message: UserText.netPInviteMessage
        )

        NetworkProtectionInviteMessageView(messageData: messageData) {
            ClearTextField(
                placeholderText: UserText.netPInviteFieldPrompt,
                text: $model.text,
                keyboardType: .asciiCapable
            )
            .frame(height: 44)
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .background(Color.textFieldBackground)
            .cornerRadius(10)
            .disabled(model.shouldDisableTextField)
            Button(UserText.inviteDialogSubmitButton) {
                Task {
                    await model.submit()
                }
            }
            .buttonStyle(PrimaryButtonStyle(disabled: model.shouldDisableSubmit))
        }
        .alert(isPresented: $model.shouldShowAlert) {
            Alert(
                title: Text(model.errorText),
                dismissButton: .default(Text(UserText.inviteDialogErrorAlertOKButton))
            )
        }
    }

    @ViewBuilder
    private var successView: some View {
        let messageData = NetworkProtectionInviteMessageData(
            imageIdentifier: "InviteLockSuccess",
            title: UserText.netPInviteSuccessTitle,
            message: UserText.netPInviteSuccessMessage
        )

        NetworkProtectionInviteMessageView(messageData: messageData) {
            Button(UserText.inviteDialogGetStartedButton, action: model.getStarted)
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

private struct NetworkProtectionInviteMessageView<Content>: View where Content: View {
    let messageData: NetworkProtectionInviteMessageData
    @ViewBuilder let interactiveContent: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Image(messageData.imageIdentifier)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 102.5)
                    Text(messageData.title)
                        .font(.system(size: 22, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.textPrimary)
                    Text(messageData.message)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.textSecondary)
                        .padding(.bottom, 16)
                    interactiveContent()
                    Spacer()
                    Text(UserText.netPInviteOnlyMessage)
                        .foregroundColor(.textSecondary)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(minHeight: proxy.size.height)
                .background(Color.viewBackground)
            }
        }
        .background(Color.viewBackground)
    }
}

private struct NetworkProtectionInviteMessageData {
    let imageIdentifier: String
    let title: String
    let message: String
    let footer = UserText.netPInviteOnlyMessage
}

extension AnyTransition {
    static var slideFromRight: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
}

private extension Color {
    static let textPrimary = Color(designSystemColor: .textPrimary)
    static let textSecondary = Color(designSystemColor: .textSecondary)
    static let textFieldBackground = Color(designSystemColor: .surface)
    static let viewBackground = Color(designSystemColor: .background)
}

import NetworkProtection

struct NetworkProtectionInviteView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkProtectionInviteView(
            model: NetworkProtectionInviteViewModel(
                redemptionCoordinator: NetworkProtectionCodeRedemptionCoordinator()
            ) { }
        )
    }
}

#endif
