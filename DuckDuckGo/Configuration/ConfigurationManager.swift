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
    
    enum Error: Swift.Error, LocalizedError {
        
        case bloomFilterSpecNotFound
        case bloomFilterBinaryNotFound
        case bloomFilterExcludedDomainsNotFound
        
        var errorDescription: String? {
            switch self {
            case .bloomFilterSpecNotFound:
                return "Bloom filter spec not found."
            case .bloomFilterBinaryNotFound:
                return "Bloom filter binary not found."
            case .bloomFilterExcludedDomainsNotFound:
                return "Bloom filter excluded domains not found."
            }
        }
        
    }
    
    public static let didUpdateTrackerDependencies = NSNotification.Name(rawValue: "com.duckduckgo.configurationManager.didUpdateTrackerDependencies")
    private static let updateQueue = DispatchQueue(label: "StorageCache update queue", qos: .utility)
    
    private let store = ConfigurationStore()
    private let httpsUpgradeStore: AppHTTPSUpgradeStore = PrivacyFeatures.httpsUpgradeStore

    func update(onDidUpdate: @escaping (Configuration) -> Void) async -> Bool {
        var didUpdateAnyData = false
        let fetcher = ConfigurationFetcher(store: ConfigurationStore())
        do {
            try await fetcher.fetch([.trackerDataSet, .surrogates, .privacyConfiguration]) {
                updateTrackerBlockingDependencies(onDidUpdate: onDidUpdate)
                didUpdateAnyData = true
            }
        } catch {
            os_log("Failed to apply update to tracker blocking dependencies: %@", log: .generalLog, type: .debug, error.localizedDescription)
        }
        
        do {
            try await fetcher.fetch([.bloomFilterBinary, .bloomFilterSpec]) {
                try updateBloomFilter(onDidUpdate: onDidUpdate)
                didUpdateAnyData = true
            }
        } catch {
            os_log("Failed to apply update to bloom filter: %@", log: .generalLog, type: .debug, error.localizedDescription)
        }
        
        do {
            try await fetcher.fetch([.bloomFilterExcludedDomains]) {
                try updateBloomFilterExclusions(onDidUpdate: onDidUpdate)
                didUpdateAnyData = true
            }
        } catch {
            os_log("Failed to apply update to bloom filter exclusions: %@", log: .generalLog, type: .debug, error.localizedDescription)
        }

        return didUpdateAnyData
    }
    
    private func updateTrackerBlockingDependencies(onDidUpdate: (Configuration) -> Void) {
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
        
        onDidUpdate(.privacyConfiguration)
        onDidUpdate(.trackerDataSet)
        
        NotificationCenter.default.post(name: ConfigurationManager.didUpdateTrackerDependencies, object: self)
    }
    
    private func updateBloomFilter(onDidUpdate: (Configuration) -> Void) throws {
        guard let specData = store.loadData(for: .bloomFilterSpec) else {
            throw Error.bloomFilterSpecNotFound
        }

        guard let bloomFilterData = store.loadData(for: .bloomFilterBinary) else {
            throw Error.bloomFilterBinaryNotFound
        }

        let spec = try JSONDecoder().decode(HTTPSBloomFilterSpecification.self, from: specData)
        try httpsUpgradeStore.persistBloomFilter(specification: spec, data: bloomFilterData)
        
        onDidUpdate(.bloomFilterSpec)
        onDidUpdate(.bloomFilterBinary)

        PrivacyFeatures.httpsUpgrade.loadData()
    }
    
    private func updateBloomFilterExclusions(onDidUpdate: (Configuration) -> Void) throws {
        guard let excludedDomainsData = store.loadData(for: .bloomFilterExcludedDomains) else {
            throw Error.bloomFilterExcludedDomainsNotFound
        }
        
        let excludedDomains = try HTTPSUpgradeParser.convertExcludedDomainsData(excludedDomainsData)
        try httpsUpgradeStore.persistExcludedDomains(excludedDomains)
        
        onDidUpdate(.bloomFilterExcludedDomains)
        
        PrivacyFeatures.httpsUpgrade.loadData()
    }
    
}
