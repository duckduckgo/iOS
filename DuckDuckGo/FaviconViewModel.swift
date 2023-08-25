//
//  FaviconViewModel.swift
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
import Core

final class FaviconViewModel {
    @Published var image = UIImage(named: "Logo")!

    private let domain: String
    private let useFakeFavicon: Bool
    private let cacheType: Favicons.CacheType
    private let preferredFaviconLetters: String?
    
    internal init(domain: String,
                  useFakeFavicon: Bool = true,
                  cacheType: Favicons.CacheType = .tabs,
                  preferredFakeFaviconLetters: String? = nil) {
        
        self.domain = domain
        self.useFakeFavicon = useFakeFavicon
        self.cacheType = cacheType
        self.preferredFaviconLetters = preferredFakeFaviconLetters
        loadFavicon()
    }
    
    private func loadFavicon() {
        FaviconsHelper.loadFaviconSync(forDomain: domain,
                                       usingCache: cacheType,
                                       useFakeFavicon: useFakeFavicon,
                                       preferredFakeFaviconLetters: preferredFaviconLetters) { image, _ in
            if let image = image {
                self.image = image
            }
        }
    }
}
