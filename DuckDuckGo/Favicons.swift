//
//  Favicons.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 11/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Kingfisher
import UIKit

public class Favicons {

    public struct Constants {

        public static let standardPlaceHolder = UIImage(named: "GlobeSmall")
        public static let appUrls = AppUrls()
        
        static let downloader = NotFoundCachingDownloader()
        static let bookmarksCache = ImageCache.create(.bookmarks)
        static let tabsCache = ImageCache.create(.tabs)
        static let caches = [
            CacheType.bookmarks: bookmarksCache,
            CacheType.tabs: tabsCache
        ]

    }

    public enum CacheType: String {

        case tabs
        case bookmarks

    }

    public static func removeExpiredNotFoundEntries() {
        Constants.downloader.removeExpired()
    }

    public static func clearCache(_ cacheType: CacheType) {
        Constants.caches[cacheType]?.clearDiskCache()
    }

    public static func removeFavicon(forDomain domain: String, fromCache cacheType: CacheType) {
        Constants.caches[cacheType]?.removeImage(forKey: "https://\(domain)", fromDisk: true)
    }

    public static func removeBookmarkFavicon(forDomain domain: String) {

        guard !PreserveLogins.shared.isAllowed(fireproofDomain: domain) else { return }
        removeFavicon(forDomain: domain, fromCache: .bookmarks)

    }

    public static func removeFireproofFavicon(forDomain domain: String) {

        guard !BookmarkUserDefaults().contains(domain: domain) else { return }
        removeFavicon(forDomain: domain, fromCache: .bookmarks)

    }

    // Call this when the user interacts with an entity of the specific type with a given URL,
    //  e.g. if launching a bookmark, or clicking on a tab.
    public static func loadFavicon(forDomain domain: String?, intoCache cacheType: CacheType) {

        guard let domain = domain,
            let options = Self.kfOptions(forDomain: domain, usingCache: cacheType),
            let resource = Self.defaultResource(forDomain: domain) else { return }

        KingfisherManager.shared.retrieveImage(with: resource, options: options) { result in
            guard let domain = resource.downloadURL.host else { return }

            switch result {
            case .failure(let error):
                switch error {
                case .imageSettingError(let settingError):
                    switch settingError {
                    case .alternativeSourcesExhausted:
                        Constants.downloader.cacheNotFound(domain)

                    default: break
                    }

                default: break
                }

            default: break
            }
        }
    }

    public static func defaultResource(forDomain domain: String?) -> ImageResource? {
        guard let domain = domain else { return nil }
        guard let faviconUrl = Constants.appUrls.appleTouchIcon(forDomain: domain) else { return nil }
        let key = "DDGSalt:\(domain)".sha256()
        return ImageResource(downloadURL: faviconUrl, cacheKey: key)
    }

    public static func kfOptions(forDomain domain: String?, usingCache cacheType: CacheType) -> KingfisherOptionsInfo? {
        guard let domain = domain else {
            return nil
        }

        if let url = URL(string: "https://\(domain)"), Constants.appUrls.isDuckDuckGo(url: url) {
            return nil
        }

        guard let secureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: true),
            let insecureFaviconUrl = Constants.appUrls.faviconUrl(forDomain: domain, secure: false) else {
            return nil
        }

        guard let cache = Constants.caches[cacheType] else {
            return nil
        }

        return [
            .downloader(Constants.downloader),
            .targetCache(cache),
            .alternativeSources([
                Source.network(secureFaviconUrl),
                Source.network(insecureFaviconUrl)
            ])
        ]
    }

}

extension ImageCache {

    static func create(_ type: Favicons.CacheType) -> ImageCache {

        let imageCache: ImageCache

        switch type {
        case .bookmarks:
            let groupName = BookmarkUserDefaults.Constants.groupName
            let sharedLocation = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
            print("***", #function, sharedLocation as Any)
            imageCache = (try? ImageCache(name: type.rawValue, cacheDirectoryURL: sharedLocation))
                            ?? ImageCache(name: type.rawValue)
        case .tabs:
            imageCache = ImageCache(name: type.rawValue)
        }

        // We hash the key when loading the resource
        imageCache.diskStorage.config.usesHashedFileName = false
        return imageCache
    }

}
