//
//  ContentBlockerLoader.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class ContentBlockerLoader {
    
    internal typealias DataDict = [ContentBlockerRequest.Configuration: Any]
    internal typealias EtagDict = [ContentBlockerRequest.Configuration: String]

    private let httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()
    private let etagStorage: BlockerListETagStorage

    private var newData = DataDict()
    private var etags = EtagDict()

    internal init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage()) {
        self.etagStorage = etagStorage
    }

    internal func checkForUpdates(with currentCache: StorageCache) -> Bool {
        
        EasylistStore.removeLegacyLists()

        self.newData.removeAll()
        self.etags.removeAll()
        
        let semaphore = DispatchSemaphore(value: 0)
        let numberOfRequests = startRequests(with: semaphore, currentCache: currentCache)
        
        for _ in 0 ..< numberOfRequests {
            semaphore.wait()
        }
        
        Logger.log(items: "ContentBlockerLoader", "completed", self.newData.count)
        
        return !newData.isEmpty
    }
    
    internal func applyUpdate(to cache: StorageCache) {
        
        for (config, info) in newData {
            if (cache.update(config, with: info)),
                let etag = etags[config] {
                etagStorage.set(etag: etag, for: config)
            } else {
                Logger.log(text: "Failed to apply update to \(config.rawValue)")
            }
        }
    }
    
    private func startRequests(with semaphore: DispatchSemaphore,
                               currentCache: StorageCache) -> Int {
        let contentBlockerRequest = ContentBlockerRequest()
        request(.entitylist, with: contentBlockerRequest, currentCache: currentCache, semaphore)
        request(.disconnectMe, with: contentBlockerRequest, currentCache: currentCache, semaphore)
        request(.trackersWhitelist, with: contentBlockerRequest, currentCache: currentCache, semaphore)
        request(.surrogates, with: contentBlockerRequest, currentCache: currentCache, semaphore)
        
        requestHttpsUpgrade(contentBlockerRequest, semaphore)
        requestHttpsWhitelist(contentBlockerRequest, semaphore)
        
        return contentBlockerRequest.requestCount
    }
    
    fileprivate func request(_ configuration: ContentBlockerRequest.Configuration,
                             with contentBlockerRequest: ContentBlockerRequest,
                             currentCache: StorageCache,
                             _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(configuration) { response in
            
            guard case ContentBlockerRequest.Response.success(let etag, let data) = response else {
                semaphore.signal()
                return
            }
            
            let isCached = etag != nil && self.etagStorage.etag(for: configuration) == etag
            self.etags[configuration] = etag
            
            if isCached {
                switch configuration {
                case .disconnectMe:
                    if !currentCache.disconnectMeStore.hasData {
                        self.newData[configuration] = data
                        Pixel.fire(pixel: .etagStoreOOSWithDisconnectMeFix)
                    }
                case .easylist:
                    if !currentCache.easylistStore.hasData {
                        self.newData[configuration] = data
                        Pixel.fire(pixel: .etagStoreOOSWithEasylistFix)
                    }
                default:
                    break
                }
            } else {
                self.newData[configuration] = data
            }

            semaphore.signal()
        }
    }
    
    private func requestHttpsUpgrade(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(.httpsBloomFilterSpec) { response in
            guard case ContentBlockerRequest.Response.success(_, let data) = response,
                let specification = try? HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data)
                else {
                    semaphore.signal()
                    return
            }
            
            if let storedSpecification = self.httpsUpgradeStore.bloomFilterSpecification(), storedSpecification == specification {
                Logger.log(text: "Bloom filter already downloaded")
                semaphore.signal()
                return
            }
            
            contentBlockerRequest.request(.httpsBloomFilter) { response in
                guard case ContentBlockerRequest.Response.success(_, let data) = response else {
                    semaphore.signal()
                    return
                }
                
                self.newData[.httpsBloomFilter] = (specification, data)
                semaphore.signal()
            }
        }
    }
    
    private func requestHttpsWhitelist(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(.httpsWhitelist) { response in
            guard case ContentBlockerRequest.Response.success(let etag, let data) = response else {
                semaphore.signal()
                return
            }
            
            let isCached = etag != nil && self.etagStorage.etag(for: .httpsWhitelist) == etag
            
            if !isCached, let whitelist = try? HTTPSUpgradeParser.convertWhitelist(fromJSONData: data) {
                self.newData[.httpsWhitelist] = whitelist
                self.etags[.httpsWhitelist] = etag
            }
            semaphore.signal()
        }
    }
    
}
