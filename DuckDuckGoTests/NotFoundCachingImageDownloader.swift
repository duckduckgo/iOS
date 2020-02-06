//
//  NotFoundCachingDownloader.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import Foundation
import Kingfisher

class NotFoundCachingDownloader: ImageDownloader {
    
    static let oneHour: TimeInterval = 60 * 60
    static var notFoundCache = [URL: TimeInterval]()
    
    convenience init() {
        self.init(name: "NotFoundCachingDownloader")
    }
    
    override func downloadImage(with url: URL,
                                retrieveImageTask: RetrieveImageTask?,
                                options: KingfisherOptionsInfo?,
                                progressBlock: ImageDownloaderProgressBlock?,
                                completionHandler: ImageDownloaderCompletionHandler?) -> RetrieveImageDownloadTask? {

        if let cacheAddTime = NotFoundCachingDownloader.notFoundCache[url],
            Date().timeIntervalSince1970 - cacheAddTime < NotFoundCachingDownloader.oneHour {
            completionHandler?(nil, nil, nil, nil)
            return nil
        }
        
        Self.notFoundCache[url] = nil
        
        return super.downloadImage(with: url,
                                   retrieveImageTask: retrieveImageTask,
                                   options: options,
                                   progressBlock: progressBlock,
                                   completionHandler: completionHandler)
    }
    
    static func cacheNotFound(_ url: URL) {
        notFoundCache[url] = Date().timeIntervalSince1970
    }
    
}
