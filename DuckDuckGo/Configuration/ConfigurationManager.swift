//
//  ConfigurationManager.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Core
import Configuration
import os.log
import BrowserServicesKit

struct ConfigurationManager {
    
    public static let didUpdateStorageCacheNotification = NSNotification.Name(rawValue: "com.duckduckgo.storageCacheProvider.notifications.didUpdate")
    private static let updateQueue = DispatchQueue(label: "StorageCache update queue", qos: .utility)
    
    private let lock = NSLock()
    private let store = ConfigurationStore()
    private let httpsUpgradeStore: AppHTTPSUpgradeStore = PrivacyFeatures.httpsUpgradeStore

    func update() async {
        
        let fetcher = ConfigurationFetcher(store: ConfigurationStore())
        do {
            try await fetcher.fetch([.trackerDataSet, .surrogates, .privacyConfiguration]) {
                updateTrackerBlockingDependencies()
            }
        } catch {
//            os_log("Failed to apply update to %d", log: .generalLog, type: .debug, self.newData.count)
        }
        
        do {
            try await fetcher.fetch([.bloomFilterBinary, .bloomFilterSpec]) {
                try updateBloomFilter()
            }
        } catch {
//            os_log("Failed to apply update to %d", log: .generalLog, type: .debug, self.newData.count)
        }
        
        do {
            try await fetcher.fetch([.bloomFilterExcludedDomains]) {
                try updateBloomFilterExclusions()
            }
        } catch {
//            os_log("Failed to apply update to %d", log: .generalLog, type: .debug, self.newData.count)
        }
        
//        Self.updateQueue.async {
//            let currentCache = self.current
//            let newCache = StorageCache(tld: currentCache.tld)
//            loader.applyUpdate(to: newCache)
//
//            self.current = newCache
//
//            NotificationCenter.default.post(name: StorageCacheProvider.didUpdateStorageCacheNotification,
//                                            object: self)
//
//            completion(newCache)
//        }
    }
    
    private func updateTrackerBlockingDependencies() {
        let configEtag = store.loadEtag(for: .privacyConfiguration)
        let configData = store.loadData(for: .privacyConfiguration)
        if ContentBlocking.shared.privacyConfigurationManager.reload(etag: configEtag, data: configData) != .downloaded {
            Pixel.fire(pixel: .privacyConfigurationReloadFailed)
        }
        
        let tdsEtag = store.loadEtag(for: .trackerDataSet)
        let tdsData = store.loadData(for: .trackerDataSet)
        if ContentBlocking.shared.trackerDataManager.reload(etag: tdsEtag, data: tdsData) != .downloaded {
            Pixel.fire(pixel: .trackerDataReloadFailed)
        }
        ContentBlocking.shared.contentBlockingManager.scheduleCompilation() // to do was it from mac on from ios?
    }
    
    private func updateBloomFilter() throws {
        
        guard let specData = store.loadData(for: .bloomFilterSpec) else {
//            throw Error.bloomFilterSpecNotFound
            return
        }

        guard let bloomFilterData = store.loadData(for: .bloomFilterBinary) else {
//            throw Error.bloomFilterBinaryNotFound
            return
        }

        let spec = try JSONDecoder().decode(HTTPSBloomFilterSpecification.self, from: specData)
        try httpsUpgradeStore.persistBloomFilter(specification: spec, data: bloomFilterData)
//            throw Error.bloomFilterPersistenceFailed

        PrivacyFeatures.httpsUpgrade.loadData()
    }
    
    private func updateBloomFilterExclusions() throws {
        guard let excludedDomainsData = store.loadData(for: .bloomFilterExcludedDomains) else {
            return // todo: throw
        }
        
        let excludedDomains = try HTTPSUpgradeParser.convertExcludedDomainsData(excludedDomainsData)
        try httpsUpgradeStore.persistExcludedDomains(excludedDomains)
    }
    
}
