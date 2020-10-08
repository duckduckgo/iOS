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

        static let salt = "DDGSalt:"
        static let faviconsFolderName = "Favicons"
        static let downloader = NotFoundCachingDownloader()
        static let requestModifier = FaviconRequestModifier()
        static let bookmarksCache = CacheType.bookmarks.create()
        static let tabsCache = CacheType.tabs.create()
        static let appUrls = AppUrls()
        
        public static let caches = [
            CacheType.bookmarks: bookmarksCache,
            CacheType.tabs: tabsCache
        ]

    }

    public enum CacheType: String {

        case tabs
        case bookmarks

        func create() -> ImageCache {
            
            // If unable to create cache in desired location default to Kinfisher's default location which is Library/Cache.  Images may disappear
            //  but at least the app won't crash.  This should not happen.
            let cache = createCacheInDesiredLocation() ?? ImageCache(name: rawValue)
            
            // We hash the resource key when loading the resource so don't use Kingfisher's hashing which is md5 based
            cache.diskStorage.config.usesHashedFileName = false
            
            return cache
        }

        public func cacheLocation() -> URL? {
            return baseCacheURL()?.appendingPathComponent(Constants.faviconsFolderName)
        }

        private func createCacheInDesiredLocation() -> ImageCache? {
            
            guard var url = cacheLocation() else { return nil }
            
            if !FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.createDirectory(at: url,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
                
                // Exclude from backup
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try? url.setResourceValues(resourceValues)
            }
            
            os_log("favicons %s location %s", type: .debug, rawValue, url.absoluteString)
            return try? ImageCache(name: self.rawValue, cacheDirectoryURL: url)
        }

        private func baseCacheURL() -> URL? {
            switch self {
            case .bookmarks:
                let groupName = BookmarkUserDefaults.Constants.groupName
                return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
                       
            case .tabs:
                return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            }
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

        // Prevents the caches being cleaned up
        NotificationCenter.default.removeObserver(Constants.bookmarksCache)
        NotificationCenter.default.removeObserver(Constants.tabsCache)
    }
    
    public func migrateIfNeeded(afterMigrationHandler: @escaping () -> Void) {
        guard needsMigration else { return }

        DispatchQueue.global(qos: .utility).async {
            ImageCache.default.clearDiskCache()
            
            let links = ((self.bookmarksStore.bookmarks + self.bookmarksStore.favorites).compactMap { $0.url.host })
                + PreserveLogins.shared.allowedDomains
            
            let group = DispatchGroup()
            Set(links).forEach { domain in
                group.enter()
                self.loadFavicon(forDomain: domain, intoCache: .bookmarks) { _ in
                    group.leave()
                }
            }
            group.wait()

            self.needsMigration = false
            afterMigrationHandler()
        }
        
    }
    
    func replaceBookmarksFavicon(forDomain domain: String?, withImage image: UIImage) {
        
        guard let domain = domain,
            let resource = defaultResource(forDomain: domain),
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
 
    public func clearCache(_ cacheType: CacheType) {
        Constants.caches[cacheType]?.clearDiskCache()
    }

    private func removeFavicon(forDomain domain: String, fromCache cacheType: CacheType) {
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
    
    private func copyFavicon(forDomain domain: String, fromCache: CacheType, toCache: CacheType, completion: ((UIImage?) -> Void)? = nil) {
        guard let resource = defaultResource(forDomain: domain),
             let options = kfOptions(forDomain: domain, usingCache: toCache) else { return }
        
        Constants.caches[fromCache]?.retrieveImage(forKey: resource.cacheKey, options: [.onlyFromCache]) { result in
            switch result {
            case .success(let image):
                if let image = image.image {
                    Constants.caches[toCache]?.store(image, forKey: resource.cacheKey, options: .init(options))
                    completion?(image)
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
                            fromURL url: URL? = nil,
                            intoCache targetCache: CacheType,
                            fromCache: CacheType? = nil,
                            completion: ((UIImage?) -> Void)? = nil) {

        guard let domain = domain,
            let options = kfOptions(forDomain: domain, withURL: url, usingCache: targetCache),
            let resource = defaultResource(forDomain: domain) else {
                completion?(nil)
                return
            }
        
        if let fromCache = fromCache, Constants.caches[fromCache]?.isCached(forKey: resource.cacheKey) ?? false {
            copyFavicon(forDomain: domain, fromCache: fromCache, toCache: targetCache, completion: completion)
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: resource, options: options) { result in
            guard let domain = resource.downloadURL.host else {
                completion?(nil)
                return
            }

            switch result {
            case .success(let imageResult):
                // Store it anyway - Kingfisher doesn't appear to store the image if it came from an alternative source
                Favicons.Constants.caches[targetCache]?.store(imageResult.image, forKey: resource.cacheKey, options: .init(options))
                completion?(imageResult.image)
                
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

                completion?(nil)
            }
            
        }
    }

    public func defaultResource(forDomain domain: String?) -> ImageResource? {
        guard let domain = domain,
            let source = sourcesProvider.mainSource(forDomain: domain) else { return nil }
        
        let key = Self.createHash(ofDomain: domain)
        return ImageResource(downloadURL: source, cacheKey: key)
    }

    public func kfOptions(forDomain domain: String?, withURL url: URL? = nil, usingCache cacheType: CacheType) -> KingfisherOptionsInfo? {
        guard let domain = domain else {
            return nil
        }

        if Constants.appUrls.isDuckDuckGo(domain: domain) {
            return nil
        }

        guard let cache = Constants.caches[cacheType] else {
            return nil
        }

        var sources = sourcesProvider.additionalSources(forDomain: domain).map { Source.network($0) }
        
        // a provided URL was given so add our usual main source to the list of alteratives
        if let url = url {
            sources.insert(Source.network(url), at: 0)
        }

        // Explicity set the expiry
        #if DEBUG
        let expiry = KingfisherOptionsInfoItem.diskCacheExpiration(.seconds(60))
        #else
        let expiry = KingfisherOptionsInfoItem.diskCacheExpiration(.days(7))
        #endif

        return [
            .downloader(Constants.downloader),
            .requestModifier(Constants.requestModifier),
            .targetCache(cache),
            expiry,
            .alternativeSources(sources)
        ]
    }

    public static func createHash(ofDomain domain: String) -> String {
        return "\(Constants.salt)\(domain)".sha256()
    }

}
