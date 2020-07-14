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
                     fallbackImage: UIImage? = Favicons.Constants.standardPlaceHolder,
                     completion: ((UIImage?) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .utility).async {
            self.loadFaviconSync(forDomain: domain, usingCache: cacheType, fallbackImage: fallbackImage, completion: completion)
        }
        
    }

    private func loadFaviconSync(forDomain domain: String?,
                                 usingCache cacheType: Favicons.CacheType,
                                 fallbackImage: UIImage? = Favicons.Constants.standardPlaceHolder,
                                 completion: ((UIImage?) -> Void)? = nil) {
        
        func complete(_ image: UIImage?) {
            DispatchQueue.main.async {
                self.image = image
                completion?(self.image)
            }
        }
                
        if domain == AppUrls.ddgDomain {
            complete(UIImage(named: "Logo"))
            return
        }
        
        guard let cache = Favicons.Constants.caches[cacheType] else {
            complete(fallbackImage)
            return
        }
        
        guard let resource = Favicons.defaultResource(forDomain: domain) else {
            complete(fallbackImage)
            return
        }
        
        if let image = cache.retrieveImageInMemoryCache(forKey: resource.cacheKey) {
            complete(image)
        } else {
            
            // Not in memory, could because it's expired or we have cold started.
            
            // Load manually otherwise Kingfisher won't load it if the file's modification date > current date
            let url = cache.diskStorage.cacheFileURL(forKey: resource.cacheKey)
            guard let data = (try? Data(contentsOf: url)), let image = UIImage(data: data) else {
                complete(fallbackImage)
                return
            }
            
            complete(image)

            // Cache in memory with the original expiry date so that the image will be refreshed on user interaction.
            
            guard let attributes = (try? FileManager.default.attributesOfItem(atPath: url.path)),
                let fileModificationDate = attributes[.modificationDate] as? Date else {
                return
            }
            
            cache.store(image, forKey: resource.cacheKey, options: KingfisherParsedOptionsInfo([
                .cacheMemoryOnly,
                .diskCacheAccessExtendingExpiration(.none),
                .memoryCacheExpiration(.date(fileModificationDate))
            ]), toDisk: false)
            
        }

    }
    
}
