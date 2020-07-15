//
//  Favicons.swift
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

import Kingfisher
import UIKit
import os

public class Favicons {

    public struct Constants {

        public static let standardPlaceHolder = UIImage(named: "GlobeSmall")
        
        static let salt = "DDGSalt:"
        static let downloader = NotFoundCachingDownloader()
        static let requestModifier = FaviconRequestModifier()
        static let bookmarksCache = CacheType.bookmarks.create()
        static let tabsCache = CacheType.tabs.create()
        
        public static let caches = [
            CacheType.bookmarks: bookmarksCache,
            CacheType.tabs: tabsCache
        ]

    }

    public enum CacheType: String {

        case tabs
        case bookmarks

        func create() -> ImageCache {

            let imageCache: ImageCache

            switch self {
            case .bookmarks:
                let groupName = BookmarkUserDefaults.Constants.groupName
                let sharedLocation = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
                os_log("favicons bookmarks location %s", log: generalLog, type: .debug, sharedLocation?.absoluteString ?? "<none>")
                imageCache = (try? ImageCache(name: self.rawValue, cacheDirectoryURL: sharedLocation))
                                ?? ImageCache(name: self.rawValue)
                            
            case .tabs:
                let location = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                os_log("favicons tabs location %s", log: generalLog, type: .debug, location[0].absoluteString)
                imageCache = ImageCache(name: self.rawValue)
            }

            // We hash the resource key when loading the resource
            imageCache.diskStorage.config.usesHashedFileName = false

            return imageCache
        }
        
    }

    public static let shared = Favicons()

    @UserDefaultsWrapper(key: .faviconsNeedMigration, defaultValue: true)
    var needsMigration: Bool
    
    let sourcesProvider: FaviconSourcesProvider
    let bookmarksStore: BookmarkStore
    
    init(sourcesProvider: FaviconSourcesProvider = DefaultFaviconSourcesProvider(), bookmarksStore: BookmarkStore = BookmarkUserDefaults()) {
        self.sourcesProvider = sourcesProvider
        self.bookmarksStore = bookmarksStore
    }
    
    public func migrateIfNeeded(completion: @escaping () -> Void) {
         guard needsMigration else { return }
        
        DispatchQueue.global(qos: .utility).async {
            ImageCache.default.clearDiskCache()
            
            let links = ((self.bookmarksStore.bookmarks + self.bookmarksStore.favorites).compactMap { $0.url.host })
                + PreserveLogins.shared.allowedDomains
            
            let group = DispatchGroup()
            Set(links).forEach { domain in
                group.enter()
                self.loadFavicon(forDomain: domain, intoCache: .bookmarks) {
                    group.leave()
                }
            }
            group.wait()

            self.needsMigration = false
            completion()
        }
        
    }
    
    private func replaceBookmarksFavicon(forDomain domain: String, withImage image: UIImage) {
        
        guard let resource = defaultResource(forDomain: domain),
            (Constants.bookmarksCache.isCached(forKey: resource.cacheKey) || bookmarksStore.contains(domain: domain)),
            let options = kfOptions(forDomain: domain, usingCache: .bookmarks) else { return }

        let replace = {
            Constants.bookmarksCache.removeImage(forKey: resource.cacheKey)
            Constants.bookmarksCache.store(image, forKey: resource.cacheKey, options: .init(options))
        }
        
        // only replace if it exists and new one is bigger
        Constants.bookmarksCache.retrieveImageInDiskCache(forKey: resource.cacheKey, options: [.onlyFromCache ]) { result in
            switch result {
                
            case .success(let cachedImage):
                if let cachedImage = cachedImage, cachedImage.size.width < image.size.width {
                    replace()
                } else if self.bookmarksStore.contains(domain: domain) {
                    replace()
                }
                
            default:
                break
            }
        }
    }
    
    private func replaceTabsFavicon(forDomain domain: String, withImage image: UIImage) {
        guard let resource = defaultResource(forDomain: domain),
            let options = kfOptions(forDomain: domain, usingCache: .tabs) else { return }

        let replace = {
            Constants.tabsCache.removeImage(forKey: resource.cacheKey)
            Constants.tabsCache.store(image, forKey: resource.cacheKey, options: .init(options))
        }
        
        // replace if bigger or if it doesn't exist
        Constants.tabsCache.retrieveImageInDiskCache(forKey: resource.cacheKey, options: [.onlyFromCache ]) { result in
            switch result {
                
            case .success(let cachedImage):
                if cachedImage == nil || cachedImage!.size.width < image.size.width {
                    replace()
                }
                
            default:
                replace()
            }
        }
    }

    public func replaceFaviconInCaches(using url: URL, forDomain domain: String?) {
        
        guard let domain = domain else { return }
        
        var request = URLRequest(url: url)
        UserAgentManager.shared.update(request: &request, isDesktop: false)
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            
            guard let data = data,
                let image = UIImage(data: data) else { return }
            
            self.replaceBookmarksFavicon(forDomain: domain, withImage: image)
            self.replaceTabsFavicon(forDomain: domain, withImage: image)

        }
        task.resume()
    }
    
    // "not found" entries that have expired should be removed from the user settings occasionally
    public func removeExpiredNotFoundEntries() {
        Constants.downloader.removeExpired()
    }

    public func clearCache(_ cacheType: CacheType) {
        Constants.caches[cacheType]?.clearDiskCache()
    }

    public func removeFavicon(forDomain domain: String, fromCache cacheType: CacheType) {
        let key = defaultResource(forDomain: domain)?.cacheKey ?? domain
        Constants.caches[cacheType]?.removeImage(forKey: key, fromDisk: true)
    }

    public func removeBookmarkFavicon(forDomain domain: String) {

        guard !PreserveLogins.shared.isAllowed(fireproofDomain: domain) else { return }
        removeFavicon(forDomain: domain, fromCache: .bookmarks)

    }

    public func removeFireproofFavicon(forDomain domain: String) {

        guard !bookmarksStore.contains(domain: domain) else { return }
        removeFavicon(forDomain: domain, fromCache: .bookmarks)

    }
    
    private func copyFavicon(forDomain domain: String, fromCache: CacheType, toCache: CacheType, completion: (() -> Void)? = nil) {
        guard let resource = defaultResource(forDomain: domain),
             let options = kfOptions(forDomain: domain, usingCache: toCache) else { return }
        
        Constants.caches[fromCache]?.retrieveImage(forKey: resource.cacheKey, options: [.onlyFromCache]) { result in
            switch result {
            case .success(let image):
                if let image = image.image {
                    Constants.caches[toCache]?.store(image, forKey: resource.cacheKey, options: .init(options))
                    completion?()
                } else {
                    self.loadFavicon(forDomain: domain, intoCache: toCache, completion: completion)
                }
            default:
                self.loadFavicon(forDomain: domain, intoCache: toCache, completion: completion)
            }
        }
        return
    }

    // Call this when the user interacts with an entity of the specific type with a given URL,
    //  e.g. if launching a bookmark, or clicking on a tab.
    public func loadFavicon(forDomain domain: String?,
                            intoCache targetCache: CacheType,
                            fromCache: CacheType? = nil,
                            completion: (() -> Void)? = nil) {

        guard let domain = domain,
            let options = kfOptions(forDomain: domain, usingCache: targetCache),
            let resource = defaultResource(forDomain: domain) else {
                completion?()
                return
            }
        
        if let fromCache = fromCache, Constants.caches[fromCache]?.isCached(forKey: resource.cacheKey) ?? false {
            copyFavicon(forDomain: domain, fromCache: fromCache, toCache: targetCache, completion: completion)
            return
        }

        KingfisherManager.shared.retrieveImage(with: resource, options: options) { result in
            guard let domain = resource.downloadURL.host else {
                completion?()
                return
            }

            switch result {
            case .success(let imageResult):
                // Store it anyway - Kingfisher doesn't appear to store the image if it came from an alternative source
                Favicons.Constants.caches[targetCache]?.store(imageResult.image, forKey: resource.cacheKey, options: .init(options))
                
            case .failure(let error):
                
                switch error {
                case .imageSettingError(let settingError):
                    switch settingError {
                    case .alternativeSourcesExhausted:
                        Constants.downloader.noFaviconsFound(forDomain: domain)

                    default: break
                    }

                default: break
                }
            }
            
            completion?()
        }
    }

    public func defaultResource(forDomain domain: String?) -> ImageResource? {
        guard let domain = domain,
            let source = sourcesProvider.mainSource(forDomain: domain),
            let faviconUrl = URL(string: source) else { return nil }
        
        let key = "\(Constants.salt)\(domain)".sha256()
        return ImageResource(downloadURL: faviconUrl, cacheKey: key)
    }

    public func kfOptions(forDomain domain: String?, usingCache cacheType: CacheType) -> KingfisherOptionsInfo? {
        guard let domain = domain else {
            return nil
        }

        if AppUrls.isDuckDuckGo(domain: domain) {
            return nil
        }

        guard let cache = Constants.caches[cacheType] else {
            return nil
        }

        let sources = sourcesProvider.additionalSources(forDomain: domain).compactMap { URL(string: $0) }.map { Source.network($0) }

        return [
            .downloader(Constants.downloader),
            .requestModifier(Constants.requestModifier),
            .targetCache(cache),
            .alternativeSources(sources)
        ]
    }

}
