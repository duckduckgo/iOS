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

    }

    enum CacheType: String {

        case tabs
        case bookmarks

    }

    class NotFoundCachingDownloader: ImageDownloader {

        static let expiry: TimeInterval = 60 * 60 // 1 hour

        static let shared = NotFoundCachingDownloader()

        var notFoundCache = [String: TimeInterval]()

        private init() {
            super.init(name: String(describing: Self.Type.self))
        }

        override func downloadImage(with url: URL,
                                    options: KingfisherParsedOptionsInfo,
                                    completionHandler: ((Result<ImageLoadingResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {

            print("***", #function, url)

            if wasNotFound(url) {
                completionHandler?(.failure(.requestError(reason: .emptyRequest)))
                return nil
            }

            // Default to normal download behaviour because even though we try several URLs it'll still
            //  take the image from the cache thanks to the alternative sources option.
            return super.downloadImage(with: url, options: options, completionHandler: completionHandler)
        }

        func cacheNotFound(_ domain: String) {
            // TODO use hash of the domain and persist
            notFoundCache[domain] = Date().timeIntervalSince1970
        }

        func wasNotFound(_ url: URL) -> Bool {
            // TODO use hash of the domain
            if let domain = url.host,
                let cacheAddTime = notFoundCache[domain],
                Date().timeIntervalSince1970 - cacheAddTime < Self.expiry {
                return true
            }
            return false
        }

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

        let cache = ImageCache.create(cacheType)

        let options: KingfisherOptionsInfo = [
            .downloader(Favicons.NotFoundCachingDownloader.shared),
            .targetCache(cache),
            .alternativeSources([
                Source.network(secureFaviconUrl),
                Source.network(insecureFaviconUrl)
            ])
        ]

        KingfisherManager.shared.retrieveImage(with: secureAppleTouchUrl, options: options) { result in

            switch result {
            case .failure(let error):
                if error.isInvalidResponseStatusCode {
                    Favicons.NotFoundCachingDownloader.shared.cacheNotFound(domain)
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

        let cache = ImageCache.create(cacheType)

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
        imageCache.diskStorage.config.fileNameHashProvider = {
            let hashed = "DDGSalt:\($0)".sha256()
            print("***", $0, hashed)
            return hashed
        }
        return imageCache
    }

}
