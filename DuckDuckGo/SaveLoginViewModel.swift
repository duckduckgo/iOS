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
}

final class SaveLoginViewModel: ObservableObject {
    @Published var faviconImage = UIImage(systemName: "globe")!

    @UserDefaultsWrapper(key: .autofillSaveModalRejectionCount, defaultValue: 0)
    private var autofillSaveModalRejectionCount: Int
    
    @UserDefaultsWrapper(key: .autofillFirstTimeUser, defaultValue: true)
    private var autofillFirstTimeUser: Bool

    private let numberOfRejectionsToTurnOffAutofill = 3
    private let maximumPasswordDisplayCount = 40
    private let credentialManager: AutofillCredentialManagerProtocol
    weak var delegate: SaveLoginViewModelDelegate?

    var accountDomain: String {
        credentialManager.accountDomain
    }
    
    var isUpdatingPassword: Bool {
        credentialManager.isUsernameOnlyAccount
    }
    
    var isUpdatingUsername: Bool {
        credentialManager.isPasswordOnlyAccount
    }

    var hiddenPassword: String {
        // swiftlint:disable:next line_length
        let passwordCount = credentialManager.visiblePassword.count > maximumPasswordDisplayCount ? maximumPasswordDisplayCount : credentialManager.visiblePassword.count
        return String(repeating: "•", count: passwordCount)
    }
    
    var username: String {
        truncatedEmail(credentialManager.username)
    }
    
    lazy var layoutType: SaveLoginView.LayoutType = {
        if autofillFirstTimeUser {
            return .newUser
        }
        
        if credentialManager.hasOtherCredentialsOnSameDomain {
            return .saveAdditionalLogin
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
    
    internal init(credentialManager: AutofillCredentialManagerProtocol) {
        self.credentialManager = credentialManager
        loadFavicon()
    }
    
    private func truncatedEmail(_ login: String) -> String {
        let maximumLoginDisplayCount = 36
        
        let emailComponents = login.components(separatedBy: "@")
        if emailComponents.count > 1 && login.count > maximumLoginDisplayCount {
            let ellipsis = "..."
            let minimumPrefixSize = 3
            
            let difference = login.count - maximumLoginDisplayCount + ellipsis.count
            if let username = emailComponents.first,
               let domain = emailComponents.last {
                
                var prefixCount = username.count - difference
                prefixCount = prefixCount < 0 ? minimumPrefixSize : prefixCount
                let prefix = username.prefix(prefixCount)
                
                return "\(prefix)\(ellipsis)@\(domain)"
            }
        }
        
        return login
    }
    
    private func loadFavicon() {
        FaviconsHelper.loadFaviconSync(forDomain: credentialManager.accountDomain,
                                       usingCache: .tabs,
                                       useFakeFavicon: true) { image, _ in
            if let image = image {
                self.faviconImage = image
            }
        }
    }
    
    private func updateRejectionCount() {
        autofillSaveModalRejectionCount += 1
        if autofillSaveModalRejectionCount >= numberOfRejectionsToTurnOffAutofill {
            AppDependencyProvider.shared.appSettings.autofill = false
        }
    }
    
    func cancel() {
        updateRejectionCount()
        delegate?.saveLoginViewModelDidCancel(self)
    }
    
    func save() {
        autofillFirstTimeUser = false
        delegate?.saveLoginViewModelDidSave(self)
    }
}
