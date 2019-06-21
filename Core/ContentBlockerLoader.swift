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
    typealias DataStore = [ContentBlockerRequest.Configuration: Any]
    
    private static let updateQueue = DispatchQueue(label: "ContentBlocking update queue", qos: .utility)

    private var httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()

    public var hasData: Bool {
        return true//disconnectStore.hasData && easylistStore.hasData
    }

    private var newData = DataStore()

    public init() { }

    public func start(completion: ContentBlockerLoaderCompletion?) {

        type(of: self).updateQueue.async {
            self.newData.removeAll()

            let semaphore = DispatchSemaphore(value: 0)
            let numberOfRequests = self.startRequests(with: semaphore)

            for _ in 0 ..< numberOfRequests {
                semaphore.wait()
            }

            Logger.log(items: "ContentBlockerLoader", "completed", self.newData.count)
            
            // apply
            completion?(!self.newData.isEmpty)
        }
        EasylistStore.removeLegacyLists()
    }
    
    private func startRequests(with semaphore: DispatchSemaphore) -> Int {
        let contentBlockerRequest = ContentBlockerRequest()
        request(.entitylist, with: contentBlockerRequest, semaphore)
        request(.disconnectMe, with: contentBlockerRequest, semaphore)
        request(.trackersWhitelist, with: contentBlockerRequest, semaphore)
        request(.surrogates, with: contentBlockerRequest, semaphore)
        
        requestHttpsUpgrade(contentBlockerRequest, semaphore)
        requestHttpsWhitelist(contentBlockerRequest, semaphore)
        
        return contentBlockerRequest.requestCount
    }
    
    fileprivate func request(_ configuration: ContentBlockerRequest.Configuration,
                             with contentBlockerRequest: ContentBlockerRequest,
                             _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(configuration) { data, isCached in
            if let data = data, !isCached {
                self.newData[configuration] = data
            }
            semaphore.signal()
        }
    }
    
    //////
//
//    fileprivate func requestEntityList(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
//        contentBlockerRequest.request(.entitylist) { data, isCached in
//            if let data = data, !isCached {
////                self.newDataItems += 1
//                self.entityMappingStore.persist(data: data)
//            }
//            semaphore.signal()
//        }
//    }
//
//    fileprivate func requestDisconnectMe(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
//        contentBlockerRequest.request(.disconnectMe) { data, isCached in
//            if let data = data, !isCached {
////                self.newDataItems += 1
//                try? self.disconnectStore.persist(data: data)
//            }
//            semaphore.signal()
//        }
//    }
//
//    fileprivate func requestTrackerWhitelist(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
//        contentBlockerRequest.request(.trackersWhitelist) { data, isCached in
//            if let data = data, !isCached {
////                self.newDataItems += 1
//                self.easylistStore.persistEasylistWhitelist(data: data)
//            }
//            semaphore.signal()
//        }
//    }
//
//    fileprivate func requestSurrogates(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
//        contentBlockerRequest.request(.surrogates) { data, isCached in
//            if let data = data, !isCached {
////                self.newDataItems += 1
//                self.surrogateStore.parseAndPersist(data: data)
//            }
//            semaphore.signal()
//        }
//    }
    
    //////
    
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
                
//                let persisted = self.httpsUpgradeStore.persistBloomFilter(specification: specification, data: data)
//                HTTPSUpgrade.shared.loadData()
//                self.newDataItems += persisted ? 1 : 0
//                semaphore.signal()
            }
        }
    }
    
    fileprivate func requestHttpsWhitelist(_ contentBlockerRequest: ContentBlockerRequest, _ semaphore: DispatchSemaphore) {
        contentBlockerRequest.request(.httpsWhitelist) { data, isCached in
            if let data = data, !isCached, let whitelist = try? HTTPSUpgradeParser.convertWhitelist(fromJSONData: data) {
                self.newData[.httpsWhitelist] = whitelist
//                self.httpsUpgradeStore.persistWhitelist(domains: whitelist)
            }
            semaphore.signal()
        }
    }
    
}
