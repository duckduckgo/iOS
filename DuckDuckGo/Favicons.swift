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

import Bookmarks
import Common
import Kingfisher
import UIKit
import LinkPresentation
import WidgetKit

// swiftlint:disable type_body_length file_length
public class Favicons {

    public struct Constants {

        static let salt = "DDGSalt:"
        static let faviconsFolderName = "Favicons"
        static let requestModifier = FaviconRequestModifier()
        static let fireproofCache = CacheType.fireproof.create()
        static let tabsCache = CacheType.tabs.create()
        static let targetImageSizePoints: CGFloat = 64
        public static let tabsCachePath = "com.onevcat.Kingfisher.ImageCache.tabs"
        public static let maxFaviconSize: CGSize = CGSize(width: 192, height: 192)
        
        public static let caches = [
            CacheType.fireproof: fireproofCache,
            CacheType.tabs: tabsCache
        ]

    }

    public enum CacheType: String {

        case tabs
        case fireproof

        func create() -> ImageCache {
            
            // If unable to create cache in desired location default to Kingfisher's default location which is Library/Cache.  Images may disappear
            //  but at least the app won't crash.  This should not happen.
            let cache = createCacheInDesiredLocation() ?? ImageCache(name: rawValue)
            
            // We hash the resource key when loading the resource so don't use Kingfisher's hashing which is md5 based
            cache.diskStorage.config.usesHashedFileName = false

            if self == .fireproof {
                migrateBookmarksCacheContents(to: cache.diskStorage.directoryURL)
            }

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
            case .fireproof:
                let groupName = BookmarksDatabase.Constants.bookmarksGroupID
                return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
                       
            case .tabs:
                return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            }
        }

        private func migrateBookmarksCacheContents(to url: URL) {
            guard let cacheUrl = CacheType.fireproof.cacheLocation() else { return }

            // Using hardcoded path as this is a one time migration
            let bookmarksCache = cacheUrl.appendingPathComponent("com.onevcat.Kingfisher.ImageCache.bookmarks")
            guard FileManager.default.fileExists(atPath: bookmarksCache.path) else { return }

            if let contents = try? FileManager.default.contentsOfDirectory(at: bookmarksCache, includingPropertiesForKeys: nil, options: []) {
                contents.forEach {
                    let destination = url.appendingPathComponent($0.lastPathComponent)
                    try? FileManager.default.moveItem(at: $0, to: destination)
                }
            }

            do {
                try FileManager.default.removeItem(at: bookmarksCache)
            } catch {
                os_log("Failed to remove favicon bookmarks cache: %s", type: .error, error.localizedDescription)
            }
        }
    }

    public static let shared = Favicons()

    @UserDefaultsWrapper(key: .faviconSizeNeedsMigration, defaultValue: true)
    var sizeNeedsMigration: Bool

    let sourcesProvider: FaviconSourcesProvider
    let downloader: NotFoundCachingDownloader

    let userAgentManager: UserAgentManager = DefaultUserAgentManager.shared

    init(sourcesProvider: FaviconSourcesProvider = DefaultFaviconSourcesProvider(),
         downloader: NotFoundCachingDownloader = NotFoundCachingDownloader()) {
        self.sourcesProvider = sourcesProvider
        self.downloader = downloader

        // Prevents the caches being cleaned up
        NotificationCenter.default.removeObserver(Constants.fireproofCache)
        NotificationCenter.default.removeObserver(Constants.tabsCache)
    }

    public func migrateFavicons(to size: CGSize, afterMigrationHandler: @escaping () -> Void) {
        guard sizeNeedsMigration else { return }

        DispatchQueue.global(qos: .utility).async {
            guard let files = try? FileManager.default.contentsOfDirectory(at: Constants.fireproofCache.diskStorage.directoryURL,
                    includingPropertiesForKeys: nil) else {
                return
            }

            files.forEach { file in
                guard let data = (try? Data(contentsOf: file)),
                      let image = UIImage(data: data),
                      !self.isValidImage(image, forMaxSize: size) else {
                    return
                }

                let resizedImage = self.resizedImage(image, toSize: size)
                if let data = resizedImage.pngData() {
                    try? data.write(to: file)
                }
            }

            Constants.fireproofCache.clearMemoryCache()
            self.sizeNeedsMigration = false
            afterMigrationHandler()
        }
    }

    internal func isValidImage(_ image: UIImage, forMaxSize size: CGSize) -> Bool {
        if image.size.width > size.width || image.size.height > size.height {
            return false
        }
        return true
    }

    internal func resizedImage(_ image: UIImage, toSize size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    public func replaceFireproofFavicon(forDomain domain: String?, withImage image: UIImage) {
        
        guard let domain = domain,
              let resource = defaultResource(forDomain: domain),
              let options = kfOptions(forDomain: domain, usingCache: .fireproof) else { return }

        let faviconImage = scaleDownIfNeeded(image: image, toFit: Constants.maxFaviconSize)

        let replace = {
            Constants.fireproofCache.removeImage(forKey: resource.cacheKey)
            Constants.fireproofCache.store(faviconImage, forKey: resource.cacheKey, options: .init(options))
        }
        
        Constants.fireproofCache.retrieveImageInDiskCache(forKey: resource.cacheKey, options: [.onlyFromCache ]) { result in
            switch result {
                
            case .success(let cachedImage):
                if let cachedImage = cachedImage {
                    // it's in the cache so only replace if the new one is bigger
                    if cachedImage.size.width < faviconImage.size.width {
                        replace()
                    }
                } else { // Nothing in the cache so 'add' it
                    replace()
                }
                
            default:
                break
            }
        }
    }

    public func clearCache(_ cacheType: CacheType, clearMemoryCache: Bool = false) {
        Constants.caches[cacheType]?.clearDiskCache()
        
        if clearMemoryCache {
            Constants.caches[cacheType]?.clearMemoryCache()
        }
    }

    private func removeFavicon(forDomain domain: String, fromCache cacheType: CacheType) {
        let key = defaultResource(forDomain: domain)?.cacheKey ?? domain
        Constants.caches[cacheType]?.removeImage(forKey: key, fromDisk: true)
    }

    private func removeFavicon(forCacheKey key: String, fromCache cacheType: CacheType) {
        Constants.caches[cacheType]?.removeImage(forKey: key, fromDisk: true)
    }

    public func removeBookmarkFavicon(forDomain domain: String) {
        guard !PreserveLogins.shared.isAllowed(fireproofDomain: domain) else { return }
        removeFavicon(forDomain: domain, fromCache: .fireproof)
    }

    public func removeFireproofFavicon(forDomain domain: String) {
       removeFavicon(forDomain: domain, fromCache: .fireproof)
    }

    public func removeTabFavicon(forDomain domain: String) {
       removeFavicon(forDomain: domain, fromCache: .tabs)
    }

    public func removeTabFavicon(forCacheKey key: String) {
       removeFavicon(forCacheKey: key, fromCache: .tabs)
    }

    private func copyFavicon(forDomain domain: String, fromCache: CacheType, toCache: CacheType, completion: ((UIImage?) -> Void)? = nil) {
        guard let resource = defaultResource(forDomain: domain),
             let options = kfOptions(forDomain: domain, usingCache: toCache) else { return }
        
        Constants.caches[fromCache]?.retrieveImage(forKey: resource.cacheKey, options: [.onlyFromCache]) { result in
            switch result {
            case .success(let image):
                if let image = image.image {
                    Constants.caches[toCache]?.store(image, forKey: resource.cacheKey, options: .init(options))
                    WidgetCenter.shared.reloadAllTimelines()
                }
                completion?(image.image)

            default:
                completion?(nil)
            }
        }
        return
    }

    // Call this when the user interacts with an entity of the specific type with a given URL,
    //  e.g. if launching a bookmark, or clicking on a tab.
    public func loadFavicon(forDomain domain: String?,
                            fromURL url: URL? = nil,
                            intoCache targetCacheType: CacheType,
                            fromCache: CacheType? = nil,
                            queue: DispatchQueue? = OperationQueue.current?.underlyingQueue,
                            completion: ((UIImage?) -> Void)? = nil) {

        guard let domain = domain,
            let options = kfOptions(forDomain: domain, withURL: url, usingCache: targetCacheType),
            let resource = defaultResource(forDomain: domain),
            let targetCache = Favicons.Constants.caches[targetCacheType] else {
                completion?(nil)
                return
            }
        
        if let fromCache = fromCache, Constants.caches[fromCache]?.isCached(forKey: resource.cacheKey) ?? false {
            copyFavicon(forDomain: domain, fromCache: fromCache, toCache: targetCacheType, completion: completion)
            return
        }

        guard let queue = queue else { return }

        func complete(withImage image: UIImage?) {
            queue.async {
                if let image = image {
                    let image = self.scaleDownIfNeeded(image: image, toFit: Constants.maxFaviconSize)
                    targetCache.store(image, forKey: resource.cacheKey, options: .init(options))
                    WidgetCenter.shared.reloadAllTimelines()
                }
                completion?(image)
            }
        }

        targetCache.retrieveImage(forKey: resource.cacheKey, options: options) { result in

            var image: UIImage?

            switch result {

            case .success(let result):
                image = result.image

            default: break
            }

            if let image = image {
                complete(withImage: image)
            } else {
                self.loadImageFromNetwork(url, domain, complete)
            }

        }

    }

    private func scaleDownIfNeeded(image: UIImage, toFit size: CGSize) -> UIImage {
        isValidImage(image, forMaxSize: size) ? image : resizedImage(image, toSize: size)
    }

    private func loadImageFromNetwork(_ imageUrl: URL?,
                                      _ domain: String,
                                      _ completion: @escaping (UIImage?) -> Void) {

      guard downloader.shouldDownload(forDomain: domain) else {
            completion(nil)
            return
        }

        let bestSources = [
            imageUrl,
            sourcesProvider.mainSource(forDomain: domain)
        ].compactMap { $0 }

        let additionalSources = sourcesProvider.additionalSources(forDomain: domain)

        // Try LinkPresentation first, before falling back to standard favicon fetching logic.
        retrieveLinkPresentationImage(from: domain) {
            guard let image = $0, image.size.width >= Constants.targetImageSizePoints else {
                self.retrieveBestImage(bestSources: bestSources, additionalSources: additionalSources, completion: completion)
                return
            }

            completion(image)
        }
    }

    private func retrieveBestImage(bestSources: [URL], additionalSources: [URL], completion: @escaping (UIImage?) -> Void) {
        retrieveBestImage(from: bestSources) {

            // Fallback to favicons
            guard let image = $0 else {
                self.retrieveBestImage(from: additionalSources) {
                    completion($0)
                }
                return
            }

            completion(image)
        }
    }

    private func retrieveLinkPresentationImage(from domain: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "https://\(domain)") else {
            completion(nil)
            return
        }

        /// DuckDuckGo Privacy Browser uses built-in functionality from iOS to fetch the highest quality favicons for your bookmarks and favorites.
        /// This functionality uses a user agent that is different from other network requests made by the app in order to find the best favicon available.
        let metadataFetcher = LPMetadataProvider()
        let completion: (LPLinkMetadata?, Error?) -> Void = { metadata, metadataError in
            guard let iconProvider = metadata?.iconProvider, metadataError == nil else {
                completion(nil)
                return
            }

            iconProvider.loadObject(ofClass: UIImage.self) { potentialImage, _ in
                completion(potentialImage as? UIImage)
            }
        }

        if #available(iOS 15.0, *) {
            let request = URLRequest.userInitiated(url)
            metadataFetcher.startFetchingMetadata(for: request, completionHandler: completion)
        } else {
            metadataFetcher.startFetchingMetadata(for: url, completionHandler: completion)
        }
    }

    private func retrieveBestImage(from urls: [URL], completion: @escaping (UIImage?) -> Void) {
        let targetSize = Constants.targetImageSizePoints * UIScreen.main.scale
        DispatchQueue.global(qos: .background).async {
            var bestImage: UIImage?
            for url in urls {
                guard let image = self.loadImage(url: url) else { continue }
                if (bestImage?.size.width ?? 0) < image.size.width {
                    bestImage = image
                    if image.size.width >= targetSize {
                        break
                    }
                }
            }
            completion(bestImage)
        }
    }
    
    private lazy var session = URLSession(configuration: .ephemeral)

    private func loadImage(url: URL) -> UIImage? {
        var image: UIImage?
        var request = URLRequest.userInitiated(url)
        userAgentManager.update(request: &request, isDesktop: false)

        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request) { data, _, _ in
            if let data = data {
                image = UIImage(data: data)
            }
            group.leave()
        }
        task.resume()
        _ = group.wait(timeout: .now() + 60.0)
        return image
    }

    public func defaultResource(forDomain domain: String?) -> Kingfisher.ImageResource? {
        return FaviconsHelper.defaultResource(forDomain: domain, sourcesProvider: sourcesProvider)
    }

    public func kfOptions(forDomain domain: String?, withURL url: URL? = nil, usingCache cacheType: CacheType) -> KingfisherOptionsInfo? {
        guard let domain = domain else {
            return nil
        }

        if URL.isDuckDuckGo(domain: domain) {
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
        let expiry = KingfisherOptionsInfoItem.diskCacheExpiration(isDebugBuild ? .seconds(60) : .days(7))

        return [
            .downloader(downloader),
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

extension Favicons: Bookmarks.FaviconStoring {

    public func hasFavicon(for domain: String) -> Bool {
        guard let targetCache = Favicons.Constants.caches[.fireproof],
              let resource = defaultResource(forDomain: domain)
        else {
            return false
        }

        return targetCache.isCached(forKey: resource.cacheKey)
    }

    public func storeFavicon(_ imageData: Data, with url: URL?, for documentURL: URL) async throws {

        guard let domain = documentURL.host,
              let options = kfOptions(forDomain: domain, withURL: documentURL, usingCache: .fireproof),
              let resource = defaultResource(forDomain: domain),
              let targetCache = Favicons.Constants.caches[.fireproof],
              let image = UIImage(data: imageData)
        else {
            return
        }

        Task {
            let image = self.scaleDownIfNeeded(image: image, toFit: Constants.maxFaviconSize)
            targetCache.store(image, forKey: resource.cacheKey, options: .init(options))
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
// swiftlint:enable type_body_length file_length
