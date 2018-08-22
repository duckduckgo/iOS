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

    private var easylistStore = EasylistStore()
    private var disconnectStore = DisconnectMeStore()
    private var httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()
    private var surrogateStore = SurrogateStore()

    public var hasData: Bool {
        return disconnectStore.hasData && easylistStore.hasData
    }

    private var newDataItems = 0

    public init() { }

    public func start(completion: ContentBlockerLoaderCompletion?) {

        DispatchQueue.global(qos: .background).async {

            let semaphore = DispatchSemaphore(value: 0)
            let numberOfRequests = self.startRequests(with: semaphore)

            for _ in 0 ..< numberOfRequests {
                semaphore.wait()
            }

            Logger.log(items: "ContentBlockerLoader", "completed", self.newDataItems)
            completion?(self.newDataItems > 0)
        }
        easylistStore.removeLegacyLists()
    }

    private func startRequests(with semaphore: DispatchSemaphore) -> Int {

        let contentBlockerRequest = ContentBlockerRequest()

        contentBlockerRequest.request(.disconnectMe) { (data) in
            if let data = data {
                self.newDataItems += 1
                try? self.disconnectStore.persist(data: data)
            }
            semaphore.signal()
        }

        contentBlockerRequest.request(.trackersWhitelist) { (data) in
            if let data = data {
                self.newDataItems += 1
                self.easylistStore.persistEasylistWhitelist(data: data)
            }
            semaphore.signal()
        }
        
        contentBlockerRequest.request(.httpsBloomFilterSpec) { data in
            guard let data = data, let specification = HTTPSUpgradeParser.bloomFilterSpecification(fromJSONData: data) else {
                semaphore.signal()
                return
            }
                
            if specification.matches(storedSpecification: self.httpsUpgradeStore.bloomFilterSpecification()) {
                Logger.log(text: "Bloom filter already downloaded")
                semaphore.signal()
                return
            }
                
            contentBlockerRequest.request(.httpsBloomFilter) { data in
                guard let data = data else {
                    semaphore.signal()
                    return
                }
                self.httpsUpgradeStore.persistBloomFilter(specification: specification, data: data)
                HTTPSUpgrade.shared.reloadData()
                self.newDataItems += 1
                semaphore.signal()
            }
        }
        
        contentBlockerRequest.request(.httpsWhitelist) { data in
            if let data = data, let whitelist = HTTPSUpgradeParser.whitelist(fromJSONData: data) {
                self.newDataItems += 1
                self.httpsUpgradeStore.persistWhitelist(domains: whitelist)
            }
            semaphore.signal()
        }

        contentBlockerRequest.request(.surrogates) { (data) in
            if let data = data {
                self.newDataItems += 1
                self.surrogateStore.parseAndPersist(data: data)
            }
            semaphore.signal()
        }

        return contentBlockerRequest.requestCount
    }

}
