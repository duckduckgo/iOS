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
import os.log

public class ContentBlockerLoader {
    typealias ContentBlockerLoaderProgress = (ContentBlockerRequest.Configuration) -> Void

    private typealias DataDict = [ContentBlockerRequest.Configuration: Any]
    private typealias EtagDict = [ContentBlockerRequest.Configuration: String]

    private let httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()
    private let etagStorage: BlockerListETagStorage
    private let fileStore: FileStore

    private var newData = DataDict()
    private var etags = EtagDict()

    init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage(), fileStore: FileStore = FileStore()) {
        self.etagStorage = etagStorage
        self.fileStore = fileStore
    }

    func checkForUpdates(progress: ContentBlockerLoaderProgress? = nil, dataSource: ContentBlockerRemoteDataSource? = nil) -> Bool {
        let dataSource = dataSource ?? ContentBlockerRequest(etagStorage: etagStorage)

        self.newData.removeAll()
        self.etags.removeAll()
        
        let semaphore = DispatchSemaphore(value: 0)
        let numberOfRequests = startRequests(with: semaphore, dataSource: dataSource, progress: progress)
        
        for _ in 0 ..< numberOfRequests {
            semaphore.wait()
        }
        os_log("ContentBlockerLoader completed %d", log: generalLog, type: .debug, self.newData.count)
        
        return !newData.isEmpty
    }
    
    func applyUpdate(to cache: StorageCacheUpdating) {
        
        for (config, info) in newData {
            if cache.update(config, with: info, etag: etags[config]), let etag = etags[config] {
                etagStorage.set(etag: etag, for: config)
            } else {
                os_log("Failed to apply update to %d", log: generalLog, type: .debug, self.newData.count)
            }
        }
    }
    
    private func startRequests(with semaphore: DispatchSemaphore,
                               dataSource: ContentBlockerRemoteDataSource,
                               progress: ContentBlockerLoaderProgress? = nil) -> Int {
        
        request(.surrogates, with: dataSource, semaphore, progress)
        request(.trackerDataSet, with: dataSource, semaphore, progress)
        request(.temporaryUnprotectedSites, with: dataSource, semaphore, progress)
        requestHttpsUpgrade(dataSource, semaphore, progress)
        requestHttpsExcludedDomains(dataSource, semaphore, progress)
        
        return dataSource.requestCount
    }
    
    fileprivate func request(_ configuration: ContentBlockerRequest.Configuration,
                             with contentBlockerRequest: ContentBlockerRemoteDataSource,
                             _ semaphore: DispatchSemaphore,
                             _ progress: ContentBlockerLoaderProgress? = nil) {
        contentBlockerRequest.request(configuration) { response in
            defer {
                progress?(configuration)
            }

            guard case ContentBlockerRequest.Response.success(let etag, let data) = response else {
                semaphore.signal()
                return
            }
            
            let isCached = etag != nil && self.etagStorage.etag(for: configuration) == etag
            self.etags[configuration] = etag
            
            if !isCached || !self.fileStore.hasData(forConfiguration: configuration) {
                self.newData[configuration] = data
            }

            semaphore.signal()
        }
    }
    
    private func requestHttpsUpgrade(_ contentBlockerRequest: ContentBlockerRemoteDataSource,
                                     _ semaphore: DispatchSemaphore,
                                     _ progress: ContentBlockerLoaderProgress? = nil) {
        contentBlockerRequest.request(.httpsBloomFilterSpec) { response in
            defer {
                progress?(.httpsBloomFilterSpec)
            }

            guard case ContentBlockerRequest.Response.success(_, let data) = response,
                let specification = try? HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data)
                else {
                    progress?(.httpsBloomFilter)
                    semaphore.signal()
                    return
            }
            
            if let storedSpecification = self.httpsUpgradeStore.bloomFilterSpecification(), storedSpecification == specification {
                os_log("Bloom filter already downloaded", log: generalLog, type: .debug)
                progress?(.httpsBloomFilter)
                semaphore.signal()
                return
            }
            
            contentBlockerRequest.request(.httpsBloomFilter) { response in
                defer {
                    progress?(.httpsBloomFilter)
                }

                guard case ContentBlockerRequest.Response.success(_, let data) = response else {
                    semaphore.signal()
                    return
                }
                
                self.newData[.httpsBloomFilter] = (specification, data)
                semaphore.signal()
            }
        }
    }
    
    private func requestHttpsExcludedDomains(_ contentBlockerRequest: ContentBlockerRemoteDataSource,
                                             _ semaphore: DispatchSemaphore,
                                             _ progress: ContentBlockerLoaderProgress? = nil) {
        contentBlockerRequest.request(.httpsExcludedDomains) { response in
            defer {
                progress?(.httpsExcludedDomains)
            }

            guard case ContentBlockerRequest.Response.success(let etag, let data) = response else {
                semaphore.signal()
                return
            }
            
            let isCached = etag != nil && self.etagStorage.etag(for: .httpsExcludedDomains) == etag
            
            if !isCached, let excludedDomains = try? HTTPSUpgradeParser.convertExcludedDomainsData(data) {
                self.newData[.httpsExcludedDomains] = excludedDomains
                self.etags[.httpsExcludedDomains] = etag
            }
            semaphore.signal()
        }
    }
    
}
