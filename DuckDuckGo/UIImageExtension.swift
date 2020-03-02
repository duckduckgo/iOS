//
//  UIImageExtension.swift
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

    struct FaviconConstants {

        static let appUrls = AppUrls()
        static let downloader = NotFoundCachingDownloader()
        static let imageCache = ImageCache(name: BookmarksManager.imageCacheName)

    }

    func loadFavicon(forDomain domain: String?, completion: ((UIImage?) -> Void)? = nil) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        image = placeholder

        if let domain = domain, let faviconUrl = FaviconConstants.appUrls.faviconUrl(forDomain: domain) {

            kf.setImage(with: faviconUrl,
                        placeholder: placeholder,
                        options: [
                            .downloader(FaviconConstants.downloader),
                            .targetCache(FaviconConstants.imageCache)
                        ],
                        progressBlock: nil) { image, error, _, _ in

                if image == nil || error != nil {
                    NotFoundCachingDownloader.cacheNotFound(faviconUrl)
                }

                completion?(image)
            }
        }
    }

}
