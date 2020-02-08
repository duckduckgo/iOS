//
//  UIImageExtension.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 26/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
