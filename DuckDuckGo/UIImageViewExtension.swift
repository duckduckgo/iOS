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

        defer {
            completion?(self.image)
        }
                
        if domain == AppUrls.ddgDomain {
            self.image = UIImage(named: "Logo")
            return
        }
        
        guard let cache = Favicons.Constants.caches[cacheType] else {
            return
        }
        
        guard let resources = Favicons.defaultResource(forDomain: domain) else {
            return
        }
        
        if let image = cache.retrieveImageInMemoryCache(forKey: resources.cacheKey) {
            print("***", resources.cacheKey, "loaded from memory")
            self.image = image
        } else {
            let url = cache.diskStorage.cacheFileURL(forKey: resources.cacheKey)
            guard let data = (try? Data(contentsOf: url)), let image = UIImage(data: data) else {
                self.image = fallbackImage
                return
            }

            print("***", resources.cacheKey, "loaded from disk")
            self.image = image

            // If we loaded from disk it could be because we cold started.  Cache in memory with the original expiry date so that the
            //  image will be refreshed on user interaction.
            
            guard let attributes = (try? FileManager.default.attributesOfItem(atPath: url.path)),
                let fileModificationDate = attributes[.modificationDate] as? Date else {
                return
            }
            
            cache.store(image, forKey: resources.cacheKey, options: KingfisherParsedOptionsInfo([
                .cacheMemoryOnly,
                .diskCacheAccessExtendingExpiration(.none),
                .memoryCacheExpiration(.date(fileModificationDate))
            ]), toDisk: false)
            
        }
   }

}
