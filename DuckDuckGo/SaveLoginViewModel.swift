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

import Foundation
import UIKit

protocol SaveLoginViewModelDelegate: AnyObject {
    func saveLoginModelDidSave(_ model: SaveLoginViewModel)
    func saveLoginModelDidCancel(_ model: SaveLoginViewModel)
}

class SaveLoginViewModel: ObservableObject {
    weak var delegate: SaveLoginViewModelDelegate?
    
    @Published var password: String
    @Published var username: String
    @Published var faviconImage = UIImage(named: "Logo")!
    
    private(set) var website: String
    static var preview = SaveLoginViewModel(website: "www.duck.com",
                                            password: "LV-426",
                                            username: "Dax")

    internal init(website: String, password: String, username: String) {
        self.website = website
        self.password = password
        self.username = username
        loadFavicon()
    }
    
    private func loadFavicon() {
        FaviconsHelper.loadFaviconSync(forDomain: website,
                                       usingCache: .tabs,
                                       useFakeFavicon: true) { image, _ in
            if let image = image {
                self.faviconImage = image
            }
        }
    }
    
    func dismissLoginView() {
        delegate?.saveLoginModelDidCancel(self)
    }
    
    func saveLogin() {
        delegate?.saveLoginModelDidSave(self)
    }
}
