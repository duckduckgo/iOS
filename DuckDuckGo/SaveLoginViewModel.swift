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
    func saveLoginViewModelNeverPrompt(_ viewModel: SaveLoginViewModel)
    func saveLoginViewModelConfirmKeepUsing(_ viewModel: SaveLoginViewModel, isAlreadyDismissed: Bool)
    func saveLoginViewModelDidResizeContent(_ viewModel: SaveLoginViewModel, contentHeight: CGFloat)
}

final class SaveLoginViewModel: ObservableObject {

    /*
     - The url of the last site where autofill was declined is stored in app memory
     - The count of the number of times autofill has been declined is kept in user defaults
     - If the user has never saved a password and declines to save a password:
         - The count will increment unless the user is declining to fill on the same site as the one which is currently recorded in memory
         - The current site will replace the one stored in memory (if different)
     - If the count reaches 3, we show the prompt to explain that autofill can be disabled
     */
    private let domainLastShownOn: String?
    
    @UserDefaultsWrapper(key: .autofillSaveModalRejectionCount, defaultValue: 0)
    private var autofillSaveModalRejectionCount: Int
    
    @UserDefaultsWrapper(key: .autofillSaveModalDisablePromptShown, defaultValue: false)
    private var autofillSaveModalDisablePromptShown: Bool
    
    @UserDefaultsWrapper(key: .autofillFirstTimeUser, defaultValue: true)
    private var autofillFirstTimeUser: Bool

    private let numberOfRejectionsToTurnOffAutofill = 2
    private let maximumPasswordDisplayCount = 40
    private let credentialManager: SaveAutofillLoginManagerProtocol
    private let appSettings: AppSettings
    
    private var dismissButtonWasPressed = false
    var didSave = false
    
    weak var delegate: SaveLoginViewModelDelegate?

    var minHeight: CGFloat {
        switch layoutType {
        case .newUser, .saveLogin:
            return AutofillViews.saveLoginMinHeight
        case .savePassword, .updatePassword:
            return AutofillViews.savePasswordMinHeight
        case .updateUsername:
            return AutofillViews.updateUsernameMinHeight
        }
    }

    var contentHeight: CGFloat = AutofillViews.updateUsernameMinHeight {
        didSet {
            guard contentHeight != oldValue else { return }
            delegate?.saveLoginViewModelDidResizeContent(self, contentHeight: max(contentHeight, minHeight))
        }
    }

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
        credentialManager.username
    }

    var usernameTruncated: String {
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

        return .saveLogin
    }()
    
    private var attributedLayoutType: SaveLoginView.LayoutType?
    
    internal init(credentialManager: SaveAutofillLoginManagerProtocol, appSettings: AppSettings, layoutType: SaveLoginView.LayoutType? = nil, domainLastShownOn: String? = nil) {
        self.credentialManager = credentialManager
        self.appSettings = appSettings
        self.attributedLayoutType = layoutType
        self.domainLastShownOn = domainLastShownOn
    }
    
    private func updateRejectionCountIfNeeded() {
        // If the prompt has already been shown on this domain (that we know of), we don't want to increment the rejection count
        if let domainLastShownOn = domainLastShownOn, domainLastShownOn == accountDomain {
            return
        }
        autofillSaveModalRejectionCount += 1
    }

    private func shouldShowAutofillKeepUsingConfirmation() -> Bool {
        if autofillSaveModalDisablePromptShown || !autofillFirstTimeUser {
            return false
        }
        return autofillSaveModalRejectionCount >= numberOfRejectionsToTurnOffAutofill
    }
    
    private func cancel() {
        updateRejectionCountIfNeeded()
        if shouldShowAutofillKeepUsingConfirmation() {
            delegate?.saveLoginViewModelConfirmKeepUsing(self, isAlreadyDismissed: !dismissButtonWasPressed)
            autofillSaveModalDisablePromptShown = true
        } else {
            delegate?.saveLoginViewModelDidCancel(self)
        }
    }
    
    func cancelButtonPressed() {
        dismissButtonWasPressed = true
        cancel()
    }
    
    func viewControllerDidAppear() {
        appSettings.autofillCredentialsSavePromptShowAtLeastOnce = true
    }
    
    func viewControllerDidDisappear() {
        if dismissButtonWasPressed || didSave {
            return
        }
        cancel()
    }
    
    func save() {
        didSave = true
        autofillFirstTimeUser = false
        delegate?.saveLoginViewModelDidSave(self)
    }

    func neverPrompt() {
        didSave = true
        autofillFirstTimeUser = false
        delegate?.saveLoginViewModelNeverPrompt(self)
    }
}
