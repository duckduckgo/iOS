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

public typealias ContentBlockerLoaderCompletion = (Bool) -> Void

public class ContentBlockerLoader {
    internal typealias DataStore = [ContentBlockerRequest.Configuration: Any]

    private var httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()

    private var newData = DataStore()

    public init() { }

    public func checkForUpdates(with currentCache: StorageCache) -> Bool {
        
        EasylistStore.removeLegacyLists()

        self.newData.removeAll()
        
        let semaphore = DispatchSemaphore(value: 0)
        let numberOfRequests = startRequests(with: semaphore, currentCache: currentCache)
        
        for _ in 0 ..< numberOfRequests {
            semaphore.wait()
        }
        
        Logger.log(items: "ContentBlockerLoader", "completed", self.newData.count)
        
        return !newData.isEmpty
    }
    
    public func applyUpdate(to cache: StorageCache) {
        cache.update(with: newData)
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
        contentBlockerRequest.request(configuration) { data, isCached in
            if let data = data {
                if isCached {
                    switch configuration {
                    case .disconnectMe:
                        if !currentCache.disconnectMeStore.hasData {
                            Pixel.fire(pixel: .etagStoreOOSWithDisconnectMe)
                        }
                    case .easylist:
                        if !currentCache.easylistStore.hasData {
                            Pixel.fire(pixel: .etagStoreOOSWithEasylist)
                        }
                    default:
                        break
                    }
                } else {
                    self.newData[configuration] = data
                }
            }
            semaphore.signal()
        }
    }
    
    fileprivate func requestHttpsUpgrade(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(.httpsBloomFilterSpec) { data, _ in
            guard let data = data, let specification = try? HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data) else {
                semaphore.signal()
                return
            }
            
            if let storedSpecification = self.httpsUpgradeStore.bloomFilterSpecification(), storedSpecification == specification {
                Logger.log(text: "Bloom filter already downloaded")
                semaphore.signal()
                return
            }
            
            contentBlockerRequest.request(.httpsBloomFilter) { data, _ in
                if let data = data {
                    self.newData[.httpsBloomFilter] = (specification, data)
                }
                semaphore.signal()
            }
        }
    }
    
    fileprivate func requestHttpsWhitelist(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(.httpsWhitelist) { data, isCached in
            if let data = data, !isCached, let whitelist = try? HTTPSUpgradeParser.convertWhitelist(fromJSONData: data) {
                self.newData[.httpsWhitelist] = whitelist
            }
            semaphore.signal()
        }
    }
    
}
