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

    private let trackerDataManager: TrackerDataManager
    private let privacyConfigurationManager: PrivacyConfigurationManaging

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

    init(fetcher: ConfigurationFetching = ConfigurationFetcher(store: ConfigurationStore(), eventMapping: configurationDebugEvents),
         store: ConfigurationStoring = AppDependencyProvider.shared.configurationStore,
         defaults: KeyValueStoring = UserDefaults(suiteName: "\(Global.groupIdPrefix).app-configuration") ?? UserDefaults(),
         trackerDataManager: TrackerDataManager = ContentBlocking.shared.trackerDataManager,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.trackerDataManager = trackerDataManager
        self.privacyConfigurationManager = privacyConfigurationManager
        super.init(fetcher: fetcher, store: store, defaults: defaults)
        subscribeToLifecycleNotifications()
    }

    deinit {
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
        let storedEtag = store.loadEtag(for: .privacyConfiguration)
        let privacyManagerEtag = (ContentBlocking.shared.privacyConfigurationManager as? PrivacyConfigurationManager)?.fetchedConfigData?.etag
        if let privacyManagerEtag, privacyManagerEtag != storedEtag {
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

        // Start surrogates fetch task
        let surrogatesTask = Task { try await fetcher.fetch(.surrogates, isDebug: isDebug) }

        // Perform privacyConfiguration fetch and update
        do {
            try await fetcher.fetch(.privacyConfiguration, isDebug: isDebug)
            didFetchAnyTrackerBlockingDependencies = true
            privacyConfigurationManager.reload(etag: store.loadEtag(for: .privacyConfiguration),
                                               data: store.loadData(for: .privacyConfiguration))
        } catch {
            Logger.general.error("Did not apply update to \(Configuration.privacyConfiguration.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }

        // Start trackerDataSet fetch task after privacyConfiguration completes
        let trackerDataSetTask = Task { try await fetcher.fetch(.trackerDataSet, isDebug: isDebug) }

        // Wait for surrogates and trackerDataSet tasks
        let tasks: [(Configuration, Task<(), Swift.Error>)] = [
            (.surrogates, surrogatesTask),
            (.trackerDataSet, trackerDataSetTask)
        ]

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
        privacyConfigurationManager.reload(etag: store.loadEtag(for: .privacyConfiguration),
                                           data: store.loadData(for: .privacyConfiguration))
        trackerDataManager.reload(etag: store.loadEtag(for: .trackerDataSet),
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
        return store.fileUrl(for: .privacyConfiguration).deletingLastPathComponent()
    }

    override func presentedSubitemDidAppear(at url: URL) {
        guard url == store.fileUrl(for: .privacyConfiguration) else { return }
        updateTrackerBlockingDependencies()
    }

    override func presentedSubitemDidChange(at url: URL) {
        guard url == store.fileUrl(for: .privacyConfiguration) else { return }
        updateTrackerBlockingDependencies()
    }

    func subscribeToLifecycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addPresenter), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePresenter), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func removeLifecycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
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
