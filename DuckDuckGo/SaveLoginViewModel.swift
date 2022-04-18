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
    @UserDefaultsWrapper(key: .autofillSaveModalRejectionCount, defaultValue: 0)
    private var autofillSaveModalRejectionCount: Int
    
    private let numberOfRejectionsToTurnOffAutofill = 3
    
    @Published var faviconImage = UIImage(systemName: "globe")!
    weak var delegate: SaveLoginViewModelDelegate?
    private let credentialManager: AutofillCredentialManager
    var accountDomain: String {
        credentialManager.accountDomain
    }
    
    var isUpdatingPassword: Bool {
        false
    }
    
    var isUpdatingLogin: Bool {
        false
    }

    var isFirstTimeUser: Bool {
        false
    }
    
    lazy var layoutType: SaveLoginView.LayoutType = {
        if isFirstTimeUser {
            return .newUser
        }
        
        if credentialManager.hasMoreCredentialsOnSameDomain {
            return .saveAdditionalLogin
        }
        
        if credentialManager.isPasswordOnlyAccount {
            return .savePassword
        }
        
        if isUpdatingLogin {
            return .updateUsername
        }
        
        if isUpdatingPassword {
            return .updatePassword
        }

        return .saveLogin
    }()

    internal init(credentialManager: AutofillCredentialManager) {
    self.credentialManager = credentialManager
        loadFavicon()
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
        delegate?.saveLoginViewModelDidSave(self)
    }
}
