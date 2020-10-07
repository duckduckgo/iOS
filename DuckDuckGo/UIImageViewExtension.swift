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
    
    struct UIImageViewConstants {
        
        static let appUrls = AppUrls()
        
    }

    /// Load a favicon from the cache in to this uiview.  This will not load the favicon from the network.
    func loadFavicon(forDomain domain: String?,
                     usingCache cacheType: Favicons.CacheType,
                     useFakeFavicon: Bool = true,
                     completion: ((UIImage?, Bool) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .utility).async {
            self.loadFaviconSync(forDomain: domain, usingCache: cacheType, useFakeFavicon: useFakeFavicon, completion: completion)
        }
        
    }

    private func loadFaviconSync(forDomain domain: String?,
                                 usingCache cacheType: Favicons.CacheType,
                                 useFakeFavicon: Bool,
                                 completion: ((UIImage?, Bool) -> Void)? = nil) {
   
        func complete(_ image: UIImage?) {
            DispatchQueue.main.async {
                var fake = false
                if image != nil {
                    self.image = image
                } else if useFakeFavicon, let domain = domain {
                    fake = true
                    self.image = Self.createFakeFavicon(forDomain: domain)
                }
                completion?(self.image, fake)
            }
        }
        
        if UIImageViewConstants.appUrls.isDuckDuckGo(domain: domain) {
            complete(UIImage(named: "Logo"))
            return
        }
        
        guard let cache = Favicons.Constants.caches[cacheType] else {
            complete(nil)
            return
        }
        
        guard let resource = Favicons.shared.defaultResource(forDomain: domain) else {
            complete(nil)
            return
        }
        
        if let image = cache.retrieveImageInMemoryCache(forKey: resource.cacheKey) {
            complete(image)
        } else {
                        
            // Load manually otherwise Kingfisher won't load it if the file's modification date > current date
            let url = cache.diskStorage.cacheFileURL(forKey: resource.cacheKey)
            guard let data = (try? Data(contentsOf: url)), let image = UIImage(data: data) else {
                complete(nil)
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
    
    static func createFakeFavicon(forDomain domain: String,
                                  size: CGFloat = 192,
                                  backgroundColor: UIColor = UIColor.greyishBrown2,
                                  bold: Bool = true) -> UIImage? {
        
        let cornerRadius = size * 0.125
        let fontSize = size * 0.76
        
        let imageRect = CGRect(x: 0, y: 0, width: size, height: size)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
                            
            context.setFillColor(backgroundColor.cgColor)
            context.addPath(CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil))
            context.fillPath()
             
            let label = UILabel(frame: imageRect)
            label.font = bold ? UIFont.boldAppFont(ofSize: fontSize) : UIFont.appFont(ofSize: fontSize)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = String(domain.dropPrefix(prefix: "www.").prefix(1).uppercased())
            label.sizeToFit()
             
            context.translateBy(x: (imageRect.width - label.bounds.width) / 2,
                                y: (imageRect.height - label.font.ascender) / 2 - (label.font.ascender - label.font.capHeight) / 2)
             
            label.layer.draw(in: context)
        }
         
        return icon.withRenderingMode(.alwaysOriginal)
    }
    
}
