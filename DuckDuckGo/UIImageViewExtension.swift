//
//  UIImageViewExtension.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Core
import Kingfisher

extension UIImageView {
    
    /// Load a favicon from the cache in to this uiview.  This will not load the favicon from the network.
    func loadFavicon(forDomain domain: String?,
                     usingCache cacheType: Favicons.CacheType,
                     useFakeFavicon: Bool = true,
                     preferredFakeFaviconLetters: String? = nil,
                     completion: ((UIImage?, Bool) -> Void)? = nil) {

        func load() {
            FaviconsHelper.loadFaviconSync(forDomain: domain,
                                           usingCache: cacheType,
                                           useFakeFavicon: useFakeFavicon,
                                           preferredFakeFaviconLetters: preferredFakeFaviconLetters) { image, fake in
                self.image = image
                completion?(image, fake)
            }
        }

        if Thread.isMainThread {
            load()
        } else {
            DispatchQueue.main.async(execute: load)
        }
    }

}
