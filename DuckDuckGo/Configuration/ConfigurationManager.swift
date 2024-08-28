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
import BrowserServicesKit
import Persistence
import Common
import os.log

final class ConfigurationManager: DefaultConfigurationManager {

    private enum Constants {
        static let lastConfigurationInstallDateKey = "config.last.installed"
    }

    enum UpdateResult {
        case noData
        case assetsUpdated(includesPrivacyProtectionChanges: Bool)
    }
    
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

    private let defaults: KeyValueStoring
    public var lastConfigInstallDate: Date? {
        get {
            defaults.object(forKey: Constants.lastConfigurationInstallDateKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: Constants.lastConfigurationInstallDateKey)
        }
    }

    private static let configurationDebugEvents = EventMapping<ConfigurationDebugEvents> { event, error, _, _ in
        let domainEvent: Pixel.Event
        switch event {
        case .invalidPayload(let configuration):
            domainEvent = .invalidPayload(configuration)
        }

        if let error = error {
            Pixel.fire(pixel: domainEvent, error: error)
        } else {
            Pixel.fire(pixel: domainEvent)
        }
    }

    // TODO: Use app config group
    override init(fetcher: ConfigurationFetching = ConfigurationFetcher(store: ConfigurationStore(), eventMapping: configurationDebugEvents),
                  store: ConfigurationStoring = ConfigurationStore(),
                  defaults: any KeyValueStoring = UserDefaults()) {
        self.defaults = defaults
        super.init(fetcher: fetcher, store: store, defaults: defaults)
        addPresenter()
        subscribeToLifecycleNotifications()
    }

    deinit {
        removePresenter()
        removeLifecycleNotifications()
    }

    @discardableResult
    func update(isDebug: Bool = false) async -> UpdateResult {
        lastUpdateTime = Date()
        async let didFetchAnyTrackerBlockingDependencies = fetchAndUpdateTrackerBlockingDependencies(isDebug: isDebug)
        async let didFetchExcludedDomains = fetchAndUpdateBloomFilterExcludedDomains()
        async let didFetchBloomFilter = fetchAndUpdateBloomFilter()

        let results = await (didFetchAnyTrackerBlockingDependencies, didFetchExcludedDomains, didFetchBloomFilter)

        if results.0 || results.1 || results.2 {
            return .assetsUpdated(includesPrivacyProtectionChanges: results.0)
        }
        return .noData
    }

    func loadPrivacyConfigFromDiskIfNeeded() {
        guard let lastConfigInstallDate else { updateTrackerBlockingDependencies(); return }
        if lastUpdateTime.timeIntervalSince(lastConfigInstallDate) > 1 {
            updateTrackerBlockingDependencies()
        }
    }

    @discardableResult
    func fetchAndUpdateTrackerBlockingDependencies(isDebug: Bool = false) async -> Bool {
        let didFetchAnyTrackerBlockingDependencies = await fetchTrackerBlockingDependencies(isDebug: isDebug)
        if didFetchAnyTrackerBlockingDependencies {
            updateTrackerBlockingDependencies()
        }
        return didFetchAnyTrackerBlockingDependencies
    }

    private func fetchTrackerBlockingDependencies(isDebug: Bool = false) async -> Bool {
        var didFetchAnyTrackerBlockingDependencies = false

        var tasks = [Configuration: Task<(), Swift.Error>]()
        tasks[.trackerDataSet] = Task { try await fetcher.fetch(.trackerDataSet, isDebug: isDebug) }
        tasks[.surrogates] = Task { try await fetcher.fetch(.surrogates, isDebug: isDebug) }
        tasks[.privacyConfiguration] = Task { try await fetcher.fetch(.privacyConfiguration, isDebug: isDebug) }

        for (configuration, task) in tasks {
            do {
                try await task.value
                didFetchAnyTrackerBlockingDependencies = true
            } catch {
                Logger.general.error("Did not apply update to \(configuration.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }

        return didFetchAnyTrackerBlockingDependencies
    }
    
    private func updateTrackerBlockingDependencies() {
        lastConfigInstallDate = Date()
        ContentBlocking.shared.privacyConfigurationManager.reload(etag: store.loadEtag(for: .privacyConfiguration),
                                                                  data: store.loadData(for: .privacyConfiguration))
        ContentBlocking.shared.trackerDataManager.reload(etag: store.loadEtag(for: .trackerDataSet),
                                                         data: store.loadData(for: .trackerDataSet))
        NotificationCenter.default.post(name: ConfigurationManager.didUpdateTrackerDependencies, object: self)
    }

    @discardableResult
    func fetchAndUpdateBloomFilterExcludedDomains() async -> Bool {
        do {
            try await fetcher.fetch(.bloomFilterExcludedDomains, isDebug: false)
            try await updateBloomFilterExclusions()
            return true
        } catch {
            Logger.general.error("Failed to apply update to bloom filter exclusions: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    @discardableResult
    func fetchAndUpdateBloomFilter() async -> Bool {
        do {
            try await fetcher.fetch(all: [.bloomFilterBinary, .bloomFilterSpec])
            try await updateBloomFilter()
            return true
        } catch {
            Logger.general.error("Failed to apply update to bloom filter: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
    
    private func updateBloomFilter() async throws {
        guard let specData = store.loadData(for: .bloomFilterSpec) else {
            throw Error.bloomFilterSpecNotFound
        }
        guard let bloomFilterData = store.loadData(for: .bloomFilterBinary) else {
            throw Error.bloomFilterBinaryNotFound
        }
        let specification = try JSONDecoder().decode(HTTPSBloomFilterSpecification.self, from: specData)
        try await PrivacyFeatures.httpsUpgrade.persistBloomFilter(specification: specification, data: bloomFilterData)
        await PrivacyFeatures.httpsUpgrade.loadData()
    }
    
    private func updateBloomFilterExclusions() async throws {
        guard let excludedDomainsData = store.loadData(for: .bloomFilterExcludedDomains) else {
            throw Error.bloomFilterExcludedDomainsNotFound
        }
        let excludedDomains = try HTTPSUpgradeParser.convertExcludedDomainsData(excludedDomainsData)
        try await PrivacyFeatures.httpsUpgrade.persistExcludedDomains(excludedDomains)
        await PrivacyFeatures.httpsUpgrade.loadData()
    }
    
}

extension ConfigurationManager {
    override var presentedItemURL: URL? {
        return store.fileUrl(for: .privacyConfiguration)
    }

    override func presentedItemDidChange() {
        updateTrackerBlockingDependencies()
    }

    func subscribeToLifecycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addPresenter), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePresenter), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func removeLifecycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc
    func addPresenter() {
        NSFileCoordinator.addFilePresenter(self)
    }

    @objc
    func removePresenter() {
        NSFileCoordinator.removeFilePresenter(self)
    }
}
