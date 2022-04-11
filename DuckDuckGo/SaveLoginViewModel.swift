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

protocol SaveLoginViewModelDelegate: AnyObject {
    func saveLoginViewModelDidSave(_ viewModel: SaveLoginViewModel)
    func saveLoginViewModelDidCancel(_ viewModel: SaveLoginViewModel)
}

final class SaveLoginViewModel: ObservableObject {
    @Published var faviconImage = UIImage(systemName: "globe")!
    weak var delegate: SaveLoginViewModelDelegate?
    private let credentialManager: LoginPlusCredentialManager
    var accountDomain: String {
        credentialManager.accountDomain
    }
    
    var isUpdatingPassword: Bool {
        false
    }
    
    var isUpdatingLogin: Bool {
        false
    }
    
    var isSavingAdditionalLogin: Bool {
        false
    }
    
    var isFirstTimeUser: Bool {
        false
    }
    
    var layoutType: SaveLoginView.LayoutType {
        if isFirstTimeUser {
            return .newUser
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
        
        if isSavingAdditionalLogin {
            return .saveAdditionalLogin
        }

        return .saveLogin
    }

    internal init(credentialManager: LoginPlusCredentialManager) {
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
    
    func cancel() {
        delegate?.saveLoginViewModelDidCancel(self)
    }
    
    func save() {
        delegate?.saveLoginViewModelDidSave(self)
    }
    
}
