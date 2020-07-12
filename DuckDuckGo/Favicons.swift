//
//  Favicons.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 11/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Kingfisher
import UIKit
import Core

class Favicons {

    struct Constants {

        static let standardPlaceHolder = UIImage(named: "GlobeSmall")
        static let appUrls = AppUrls()
        static let bookmarksCache = ImageCache.create(.bookmarks)
        static let tabsCache = ImageCache.create(.tabs)
        static let caches: [CacheType: ImageCache] = [
            .bookmarks: bookmarksCache,
            .tabs: tabsCache
        ]
    }

    enum CacheType: String {

        case tabs
        case bookmarks

    }

    class NotFoundCachingDownloader: ImageDownloader {

        static let expiry: TimeInterval = 60 * 60 * 24 * 7 // 1 week

        static let shared = NotFoundCachingDownloader()

        @UserDefaultsWrapper(key: .notFoundCache, defaultValue: [:])
        var notFoundCache: [String: TimeInterval]

        private init() {
            super.init(name: String(describing: Self.Type.self))
        }

        override func downloadImage(with url: URL,
                                    options: KingfisherParsedOptionsInfo,
                                    completionHandler: ((Result<ImageLoadingResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {

            print("***", #function, url)

            if wasNotFound(url) {
                print("***", #function, url, "was not found")
                completionHandler?(.failure(.requestError(reason: .emptyRequest)))
                return nil
            }

            // Default to normal download behaviour because even though we try several URLs it'll still
            //  take the image from the cache thanks to the alternative sources option.
            return super.downloadImage(with: url, options: options, completionHandler: completionHandler)
        }

        func removeExpired() {
            let cache = notFoundCache
            cache.forEach { key, time in
                if Date().timeIntervalSince1970 - time > Self.expiry {
                    print("***", #function, "removing", key)
                    notFoundCache.removeValue(forKey: key)
                }
            }
        }

        func cacheNotFound(_ domain: String) {
            let hashedKey = Favicons.hasher(string: domain)
            notFoundCache[hashedKey] = Date().timeIntervalSince1970
        }

        func wasNotFound(_ url: URL) -> Bool {
            guard let domain = url.host else { return false }
            let hashedKey = Favicons.hasher(string: domain)
            if let cacheAddTime = notFoundCache[hashedKey],
                Date().timeIntervalSince1970 - cacheAddTime < Self.expiry {
                return true
            }
            return false
        }

    }

    static func hasher(string: String) -> String {
        print("***", #function, string)
        let domain = URL(string: string)?.host ?? string
        let hashed = "DDGSalt:\(domain)".sha256()
        print("***", #function, string, domain, hashed)
        return hashed
    }

    static func clearCache(_ cacheType: CacheType) {
        Constants.caches[cacheType]?.clearDiskCache()
    }

    static func removeFavicon(forDomain domain: String, fromCache cacheType: CacheType) {
        Constants.caches[cacheType]?.removeImage(forKey: "https://\(domain)", fromDisk: true)
    }

    // Call this when the user interacts with an entity of the specific type with a given URL,
    //  e.g. if launching a bookmark, or clicking on a tab.
    static func loadFavicon(forDomain domain: String?, intoCache cacheType: CacheType) {
        guard let domain = domain else {
            print("***", #function, "domain is nil")
            return
        }

        if let url = URL(string: "https://\(domain)"), Constants.appUrls.isDuckDuckGo(url: url) {
            print("***", #function, "DDG logo")
            return
        }

        guard let secureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: true),
            let secureAppleTouchUrl = Constants.appUrls.appleTouchIcon(forDomain: domain),
            let insecureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: false) else {

            print("***", #function, "failed to generate a favicon link for \(domain)")
            return
        }

        guard let cache = Constants.caches[cacheType] else {
            print("***", #function, "no cache for", cacheType)
            return
        }

        let options: KingfisherOptionsInfo = [
            .downloader(Favicons.NotFoundCachingDownloader.shared),
            .targetCache(cache),
            .alternativeSources([
                Source.network(secureFaviconUrl),
                Source.network(insecureFaviconUrl)
            ])
        ]

        KingfisherManager.shared.retrieveImage(with: secureAppleTouchUrl, options: options) { result in
            guard let host = secureAppleTouchUrl.host else { return }

            switch result {
            case .failure(let error):
                switch error {
                case .imageSettingError(let settingError):
                    switch settingError {
                    case .alternativeSourcesExhausted:
                        Favicons.NotFoundCachingDownloader.shared.cacheNotFound(host)

                    default: break
                    }

                default: break
                }

            default: break
            }
        }
    }

    static func path(url: URL, path: String) -> URL {
        print("***", #function, url, path)
        return url.appendingPathComponent("test").appendingPathComponent(path)
    }

    static func loadFavicon(forDomain domain: String?,
                            intoImageView imageView: UIImageView,
                            usingCache cacheType: CacheType,
                            fallbackImage: UIImage? = Constants.standardPlaceHolder,
                            completion: ((UIImage?) -> Void)? = nil) {

        print("***", #function, "domain is \(domain as Any)")

        guard let domain = domain else {
            print("***", #function, "domain is nil")
            imageView.image = fallbackImage
            completion?(imageView.image)
            return
        }

        if let url = URL(string: "https://\(domain)"), Constants.appUrls.isDuckDuckGo(url: url) {
            print("***", #function, "DDG logo")
            imageView.image = UIImage(named: "Logo")
            completion?(imageView.image)
            return
        }

        guard let secureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: true),
            let secureAppleTouchUrl = Constants.appUrls.appleTouchIcon(forDomain: domain),
            let insecureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: false) else {

            print("***", #function, "failed to generate a favicon link for \(domain)")
            return
        }

        guard let cache = Constants.caches[cacheType] else {
            print("***", #function, "no cache for", cacheType)
            return
        }

        let options: KingfisherOptionsInfo = [
            .onlyFromCache,
            .targetCache(cache),
            .alternativeSources([
                Source.network(secureFaviconUrl),
                Source.network(insecureFaviconUrl)
            ])
        ]

        imageView.kf.setImage(with: secureAppleTouchUrl, placeholder: fallbackImage, options: options) { _ in
            completion?(imageView.image)
        }
    }

}

extension ImageCache {

    static func create(_ type: Favicons.CacheType) -> ImageCache {
        let imageCache = ImageCache(name: type.rawValue)
        print("***", #function, imageCache.diskStorage.cacheFileURL(forKey: "test"))
        imageCache.diskStorage.config.fileNameHashProvider = Favicons.hasher
        return imageCache
    }

}
