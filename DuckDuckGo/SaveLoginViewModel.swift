//
//  SaveLoginViewModel.swift
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

import UIKit
import BrowserServicesKit
import Core

protocol SaveLoginViewModelDelegate: AnyObject {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel)
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel)
    func saveLoginViewModelConfirmKeepUsing(_ viewModel: SaveLoginViewModel)
}

final class SaveLoginViewModel: ObservableObject {
    @UserDefaultsWrapper(key: .autofillSaveModalRejectionCount, defaultValue: 0)
    private var autofillSaveModalRejectionCount: Int
    
    @UserDefaultsWrapper(key: .autofillFirstTimeUser, defaultValue: true)
    private var autofillFirstTimeUser: Bool

    private let numberOfRejectionsToTurnOffAutofill = 3
    private let maximumPasswordDisplayCount = 40
    private let credentialManager: SaveAutofillLoginManagerProtocol
    weak var delegate: SaveLoginViewModelDelegate?

    var accountDomain: String {
        credentialManager.accountDomain
    }
    
    var isUpdatingPassword: Bool {
        credentialManager.hasSavedMatchingUsername
    }
    
    var isUpdatingUsername: Bool {
        credentialManager.hasSavedMatchingPasswordWithoutUsername
    }

    var hiddenPassword: String {
        PasswordHider(password: credentialManager.visiblePassword).hiddenPassword
    }
    
    var username: String {
        AutofillInterfaceEmailTruncator.truncateEmail(credentialManager.username, maxLength: 36)
    }
    
    lazy var layoutType: SaveLoginView.LayoutType = {
        if let attributedLayoutType = attributedLayoutType {
            return attributedLayoutType
        }
        
        if autofillFirstTimeUser {
            return .newUser
        }
        
        if credentialManager.isPasswordOnlyAccount {
            return .savePassword
        }
        
        if isUpdatingUsername {
            return .updateUsername
        }
        
        if isUpdatingPassword {
            return .updatePassword
        }

        if credentialManager.hasOtherCredentialsOnSameDomain {
            return .saveAdditionalLogin
        }

        return .saveLogin
    }()
    
    private var attributedLayoutType: SaveLoginView.LayoutType?
    
    internal init(credentialManager: SaveAutofillLoginManagerProtocol, layoutType: SaveLoginView.LayoutType? = nil) {
        self.credentialManager = credentialManager
        self.attributedLayoutType = layoutType
    }
    
    private func updateRejectionCount() {
        autofillSaveModalRejectionCount += 1
    }

    private func shouldShowAutofillKeepUsingConfirmation() -> Bool {
        return autofillSaveModalRejectionCount >= numberOfRejectionsToTurnOffAutofill
    }
    
    func cancel() {
        updateRejectionCount()
        if shouldShowAutofillKeepUsingConfirmation() {
            delegate?.saveLoginViewModelConfirmKeepUsing(self)
        } else {
            delegate?.saveLoginViewModelDidCancel(self)
        }
    }
    
    func save() {
        autofillFirstTimeUser = false
        delegate?.saveLoginViewModelDidSave(self)
    }
}
