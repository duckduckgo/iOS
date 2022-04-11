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

class SaveLoginViewModel: ObservableObject {
    weak var delegate: SaveLoginViewModelDelegate?
    private let layoutType: SaveLoginView.LayoutType
    private let credentials: SecureVaultModels.WebsiteCredentials
    @Published var faviconImage = UIImage(systemName: "globe")!
    var accountDomain: String {
        credentials.account.domain
    }

    internal init(credentials: SecureVaultModels.WebsiteCredentials) {
        self.credentials = credentials
        layoutType = .newUser
        loadFavicon()
    }
    
    private func loadFavicon() {
        FaviconsHelper.loadFaviconSync(forDomain: credentials.account.domain,
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
