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
    
    enum FaviconType {
        
        case favicon
        case appleTouch
        
    }
    
    struct FaviconConstants {

        static let standardPlaceHolder = UIImage(named: "GlobeSmall")
        static let appUrls = AppUrls()
        static let options: KingfisherOptionsInfo = [
            .downloader(NotFoundCachingDownloader())
        ]

    }
    
    /// Loads a favicon for a given domain.
    /// `fallback` only called if no icon could be found
    /// `completion` only called when at least one image is found after all
    func loadFavicon(forDomain domain: String?, fallbackImage: UIImage? = FaviconConstants.standardPlaceHolder,
                     completion: ((UIImageView.FaviconType) -> Void)? = nil) {
        
        guard let domain = domain else {
            self.image = fallbackImage
            return
        }
    
        let secureFaviconUrl = Self.FaviconConstants.appUrls.faviconUrl(forDomain: domain, secure: true)
        let secureAppleTouchUrl = Self.FaviconConstants.appUrls.appleTouchIcon(forDomain: domain)
        let insecureFaviconUrl = Self.FaviconConstants.appUrls.faviconUrl(forDomain: domain, secure: false)
        let options = Self.FaviconConstants.options

        kf.setImage(with: secureFaviconUrl, options: options) { secureFaviconImage, _, _, _ in
            
            if let url = secureFaviconUrl, secureFaviconImage == nil {
                NotFoundCachingDownloader.cacheNotFound(url)
            }
            
            self.kf.setImage(with: secureAppleTouchUrl, placeholder: secureFaviconImage, options: options) { secureAppleTouchImage, _, _, _ in

                if let url = secureAppleTouchUrl, secureAppleTouchImage == nil {
                    NotFoundCachingDownloader.cacheNotFound(url)
                }

                if secureFaviconImage == nil && secureAppleTouchImage == nil {
                
                    self.kf.setImage(with: insecureFaviconUrl, options: options) { insecureFaviconImage, _, _, _ in
                    
                        if let url = insecureFaviconUrl, insecureFaviconImage == nil {
                            NotFoundCachingDownloader.cacheNotFound(url)
                        }

                        if insecureFaviconImage == nil {
                            self.image = fallbackImage
                        } else {
                            completion?(.favicon)
                        }
                    
                    }
                    
                } else {
                    
                    completion?(secureAppleTouchImage != nil ? .appleTouch : .favicon)
                    
                }
            }
        }
        
    }
    
}
