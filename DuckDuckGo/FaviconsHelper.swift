//
//  FaviconsHelper.swift
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
import Core
import Kingfisher
import Common

struct FaviconsHelper {
    
    private static let tld: TLD = AppDependencyProvider.shared.storageCache.tld
    
    static func loadFaviconSync(forDomain domain: String?,
                                usingCache cacheType: FaviconsCacheType,
                                useFakeFavicon: Bool,
                                preferredFakeFaviconLetters: String? = nil) -> (image: UIImage?, isFake: Bool) {

        func complete(_ image: UIImage?) -> (UIImage?, Bool) {
            var fake = false
            var resultImage: UIImage?
            
            if image != nil {
                resultImage = image
            } else if useFakeFavicon, let domain = domain {
                fake = true
                resultImage = Self.createFakeFavicon(forDomain: domain,
                                                     backgroundColor: UIColor.forDomain(domain),
                                                     preferredFakeFaviconLetters: preferredFakeFaviconLetters)
            }
            return (resultImage, fake)
        }
        
        if domain == "player" {
            return complete(UIImage(named: "DuckPlayer"))
        }
        
        if URL.isDuckDuckGo(domain: domain) {
            return complete(UIImage(named: "Logo"))
        }
        
        guard let cache = Favicons.Constants.caches[cacheType] else {
            return complete(nil)
        }
        
        guard let resource = Favicons.shared.defaultResource(forDomain: domain) else {
            return complete(nil)
        }
        
        if let image = cache.retrieveImageInMemoryCache(forKey: resource.cacheKey) {
            return complete(image)
        } else {
                        
            // Load manually otherwise Kingfisher won't load it if the file's modification date > current date
            let url = cache.diskStorage.cacheFileURL(forKey: resource.cacheKey)
            guard let data = (try? Data(contentsOf: url)), let image = UIImage(data: data) else {
                return complete(nil)
            }

            // Cache in memory with the original expiry date so that the image will be refreshed on user interaction.
            
            if let attributes = (try? FileManager.default.attributesOfItem(atPath: url.path)),
                let fileModificationDate = attributes[.modificationDate] as? Date {
                
                cache.store(image, forKey: resource.cacheKey, options: KingfisherParsedOptionsInfo([
                    .cacheMemoryOnly,
                    .diskCacheAccessExtendingExpiration(.none),
                    .memoryCacheExpiration(.date(fileModificationDate))
                ]), toDisk: false)
            }

            return complete(image)
        }

    }

    static func loadFaviconSync(forDomain domain: String?,
                                usingCache cacheType: FaviconsCacheType,
                                useFakeFavicon: Bool,
                                preferredFakeFaviconLetters: String? = nil,
                                completion: ((UIImage?, Bool) -> Void)? = nil) {
        let result = loadFaviconSync(forDomain: domain, usingCache: cacheType, useFakeFavicon: useFakeFavicon, preferredFakeFaviconLetters: preferredFakeFaviconLetters)

        completion?(result.image, result.isFake)
    }

    static func createFakeFavicon(forDomain domain: String,
                                  size: CGFloat = 192,
                                  backgroundColor: UIColor = UIColor.greyishBrown2,
                                  bold: Bool = true,
                                  preferredFakeFaviconLetters: String? = nil,
                                  letterCount: Int = 2) -> UIImage? {

        let cornerRadius = size * 0.125
        let imageRect = CGRect(x: 0, y: 0, width: size, height: size)
        let padding = size * 0.16
        let labelFrame = CGRect(x: padding, y: padding, width: imageRect.width - (2 * padding), height: imageRect.height - (2 * padding))

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
                            
            context.setFillColor(backgroundColor.cgColor)
            context.addPath(CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
            context.fillPath()
           
            let label = UILabel(frame: labelFrame)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            label.baselineAdjustment = .alignCenters
            label.font = bold ? UIFont.boldAppFont(ofSize: size) : UIFont.appFont(ofSize: size)
            label.textColor = UIColor.white
            label.textAlignment = .center

            if let prefferedPrefix = preferredFakeFaviconLetters?.droppingWwwPrefix().prefix(letterCount).capitalized {
                label.text = prefferedPrefix
            } else {
                label.text = String(tld.eTLDplus1(domain)?.prefix(letterCount) ?? "#").capitalized
            }
           
            context.translateBy(x: padding, y: padding)

            label.layer.draw(in: context)
        }
         
        return icon.withRenderingMode(.alwaysOriginal)
    }

    // this function is now static and outside of Favicons, otherwise there is a circular dependency between
    // Favicons and NotFoundCachingDownloader
    public static func defaultResource(forDomain domain: String?, sourcesProvider: FaviconSourcesProvider) -> KF.ImageResource? {
        guard let domain = domain,
              let source = sourcesProvider.mainSource(forDomain: domain) else { return nil }

        let key = FaviconHasher.createHash(ofDomain: domain)
        return KF.ImageResource(downloadURL: source, cacheKey: key)
    }

}
