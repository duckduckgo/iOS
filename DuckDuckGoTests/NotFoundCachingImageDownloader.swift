//
//  NotFoundCachingImageDownloader.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 18/03/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
            return nil
        }
        
        NotFoundCachingDownloader.notFoundCache[url] = nil
        
        return super.downloadImage(with: url,
                                   retrieveImageTask: retrieveImageTask,
                                   options: options,
                                   progressBlock: progressBlock,
                                   completionHandler: completionHandler)
    }
    
    static func cacheNotFound(_ url: URL) {
        NotFoundCachingDownloader.notFoundCache[url] = Date().timeIntervalSince1970
    }
    
}
