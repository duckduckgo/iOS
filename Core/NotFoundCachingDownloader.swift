//
//  NotFoundCachingDownloader.swift
//  Core
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

class NotFoundCachingDownloader: ImageDownloader {

    static let expiry: TimeInterval = 60 * 60 * 24 * 7 // 1 week

    @UserDefaultsWrapper(key: .notFoundCache, defaultValue: [:])
    var notFoundCache: [String: TimeInterval]

    init() {
        super.init(name: String(describing: Self.Type.self))
    }

    override func downloadImage(with url: URL,
                                options: KingfisherParsedOptionsInfo,
                                completionHandler: ((Result<ImageLoadingResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {

        if shouldDownload(url) {
            return super.downloadImage(with: url, options: options, completionHandler: completionHandler)
        }
        
        completionHandler?(.failure(.requestError(reason: .emptyRequest)))
        return nil
    }

    func noFaviconsFound(forDomain domain: String) {
        guard let hashedKey = Favicons.shared.defaultResource(forDomain: domain)?.cacheKey else { return }
        notFoundCache[hashedKey] = Date().timeIntervalSince1970
    }
    
    func shouldDownload(_ url: URL, referenceDate: Date = Date()) -> Bool {
        guard let domain = url.host else { return false }
        return shouldDownload(forDomain: domain, referenceDate: referenceDate)
    }

    func shouldDownload(forDomain domain: String, referenceDate: Date = Date()) -> Bool {
        guard let hashedKey = Favicons.shared.defaultResource(forDomain: domain)?.cacheKey else { return false }
        if let cacheAddTime = notFoundCache[hashedKey],
            referenceDate.timeIntervalSince1970 - cacheAddTime < Self.expiry {
            return false
        }
        notFoundCache[hashedKey] = nil
        return true
    }

}
