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

    func update() async -> Bool {
        async let didFetchAnyTrackerBlockingDependencies = fetchAndUpdateTrackerBlockingDependencies()
        async let didFetchExcludedDomains = fetchAndUpdateBloomFilterExcludedDomains()
        async let didFetchBloomFilter = fetchAndUpdateBloomFilter()

        let results = await (didFetchAnyTrackerBlockingDependencies, didFetchExcludedDomains, didFetchBloomFilter)
        return results.0 || results.1 || results.2
    }

    @discardableResult
    func fetchAndUpdateTrackerBlockingDependencies() async -> Bool {
        let didFetchAnyTrackerBlockingDependencies = await fetchTrackerBlockingDependencies()
        if didFetchAnyTrackerBlockingDependencies {
            updateTrackerBlockingDependencies()
        }
        return didFetchAnyTrackerBlockingDependencies
    }

    private func fetchTrackerBlockingDependencies() async -> Bool {
        var didFetchAnyTrackerBlockingDependencies = false
        let fetcher = ConfigurationFetcher(store: ConfigurationStore.shared, log: .configurationLog)

        var tasks = [Configuration: Task<(), Swift.Error>]()
        tasks[.trackerDataSet] = Task { try await fetcher.fetch(.trackerDataSet) }
        tasks[.surrogates] = Task { try await fetcher.fetch(.surrogates) }
        tasks[.privacyConfiguration] = Task { try await fetcher.fetch(.privacyConfiguration) }

        for (configuration, task) in tasks {
            do {
                try await task.value
                didFetchAnyTrackerBlockingDependencies = true
            } catch {
                os_log("Failed to apply update to %@: %@", log: .generalLog, type: .debug, configuration.rawValue, error.localizedDescription)
            }
        }

        return didFetchAnyTrackerBlockingDependencies
    }
    
    private func updateTrackerBlockingDependencies() {
        ContentBlocking.shared.privacyConfigurationManager.reload(etag: ConfigurationStore.shared.loadEtag(for: .privacyConfiguration),
                                                                  data: ConfigurationStore.shared.loadData(for: .privacyConfiguration))
        ContentBlocking.shared.trackerDataManager.reload(etag: ConfigurationStore.shared.loadEtag(for: .trackerDataSet),
                                                         data: ConfigurationStore.shared.loadData(for: .trackerDataSet))
        NotificationCenter.default.post(name: ConfigurationManager.didUpdateTrackerDependencies, object: self)
    }

    @discardableResult
    func fetchAndUpdateBloomFilterExcludedDomains() async -> Bool {
        do {
            try await ConfigurationFetcher(store: ConfigurationStore.shared, log: .configurationLog).fetch(.bloomFilterExcludedDomains)
            try updateBloomFilterExclusions()
            return true
        } catch {
            os_log("Failed to apply update to bloom filter exclusions: %@", log: .generalLog, type: .debug, error.localizedDescription)
            return false
        }
    }

    @discardableResult
    func fetchAndUpdateBloomFilter() async -> Bool {
        do {
            try await ConfigurationFetcher(store: ConfigurationStore.shared, log: .configurationLog).fetch(all: [.bloomFilterBinary,
                                                                                                                 .bloomFilterSpec])
            try updateBloomFilter()
            return true
        } catch {
            os_log("Failed to apply update to bloom filter: %@", log: .generalLog, type: .debug, error.localizedDescription)
            return false
        }
    }
    
    private func updateBloomFilter() throws {
        guard let specData = ConfigurationStore.shared.loadData(for: .bloomFilterSpec) else {
            throw Error.bloomFilterSpecNotFound
        }
        guard let bloomFilterData = ConfigurationStore.shared.loadData(for: .bloomFilterBinary) else {
            throw Error.bloomFilterBinaryNotFound
        }
        let specification = try JSONDecoder().decode(HTTPSBloomFilterSpecification.self, from: specData)
        try PrivacyFeatures.httpsUpgradeStore.persistBloomFilter(specification: specification, data: bloomFilterData)
        PrivacyFeatures.httpsUpgrade.loadData()
    }
    
    private func updateBloomFilterExclusions() throws {
        guard let excludedDomainsData = ConfigurationStore.shared.loadData(for: .bloomFilterExcludedDomains) else {
            throw Error.bloomFilterExcludedDomainsNotFound
        }
        let excludedDomains = try HTTPSUpgradeParser.convertExcludedDomainsData(excludedDomainsData)
        try PrivacyFeatures.httpsUpgradeStore.persistExcludedDomains(excludedDomains)
        PrivacyFeatures.httpsUpgrade.loadData()
    }
    
}
