//
//  AuthConfirmationPromptViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation

protocol AuthConfirmationPromptViewModelDelegate: AnyObject {
    func authConfirmationPromptViewModelDidBeginAuthenticating(_ viewModel: AuthConfirmationPromptViewModel)
    func authConfirmationPromptViewModelDidAuthenticate(_ viewModel: AuthConfirmationPromptViewModel, success: Bool)
    func authConfirmationPromptViewModelDidCancel(_ viewModel: AuthConfirmationPromptViewModel)
    func authConfirmationPromptViewModelDidResizeContent(_ viewModel: AuthConfirmationPromptViewModel, contentHeight: CGFloat)
}

final class AuthConfirmationPromptViewModel: ObservableObject {
    
    weak var delegate: AuthConfirmationPromptViewModelDelegate?
    private let authenticator = AutofillLoginListAuthenticator(reason: UserText.autofillDeleteAllPasswordsAuthenticationReason,
                                                               cancelTitle: UserText.autofillLoginListAuthenticationCancelButton)

    var contentHeight: CGFloat = AutofillViews.deleteAllPromptMinHeight {
        didSet {
            guard contentHeight != oldValue else {
                return
            }
            delegate?.authConfirmationPromptViewModelDidResizeContent(self,
                                                                      contentHeight: max(contentHeight, AutofillViews.deleteAllPromptMinHeight))
        }
    }

    func authenticatePressed() {
        delegate?.authConfirmationPromptViewModelDidBeginAuthenticating(self)

        authenticator.authenticate { [weak self] error in
            self?.authCompleted(with: error == nil)
        }
    }

    func cancelButtonPressed() {
        delegate?.authConfirmationPromptViewModelDidCancel(self)
    }

    private  func authCompleted(with success: Bool) {
        delegate?.authConfirmationPromptViewModelDidAuthenticate(self, success: success)
    }

}
