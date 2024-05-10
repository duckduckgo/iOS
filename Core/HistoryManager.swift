//
//  HistoryManager.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import CoreData
import Foundation
import BrowserServicesKit
import History
import Common
import Persistence

public protocol HistoryManaging {

    var historyCoordinator: HistoryCoordinating { get }
    func loadStore()

}

// Used for controlling incremental rollout
public enum HistorySubFeature: String, PrivacySubfeature {
    public var parent: PrivacyFeature {
        .history
    }

    case onByDefault
}

public class HistoryManager: HistoryManaging {

    let privacyConfigManager: PrivacyConfigurationManaging
    let variantManager: VariantManager
    let database: CoreDataDatabase
    let internalUserDecider: InternalUserDecider
    let isEnabledByUser: () -> Bool
    let onStoreLoadFailed: (Error) -> Void

    private var currentHistoryCoordinator: HistoryCoordinating?

    public var historyCoordinator: HistoryCoordinating {
        guard isHistoryFeatureEnabled(),
                isEnabledByUser() else {
            currentHistoryCoordinator = nil
            return NullHistoryCoordinator()
        }

        if let currentHistoryCoordinator {
            return currentHistoryCoordinator
        }

        var loadError: Error?
        database.loadStore { _, error in
            loadError = error
        }
        
        if let loadError {
            onStoreLoadFailed(loadError)
            return NullHistoryCoordinator()
        }

        let context = database.makeContext(concurrencyType: .privateQueueConcurrencyType)
        let historyCoordinator = HistoryCoordinator(historyStoring: HistoryStore(context: context, eventMapper: HistoryStoreEventMapper()))
        currentHistoryCoordinator = historyCoordinator
        return historyCoordinator
    }

    public init(privacyConfigManager: PrivacyConfigurationManaging,
                variantManager: VariantManager,
                database: CoreDataDatabase,
                internalUserDecider: InternalUserDecider,
                isEnabledByUser: @autoclosure @escaping () -> Bool,
                onStoreLoadFailed: @escaping (Error) -> Void) {

        self.privacyConfigManager = privacyConfigManager
        self.variantManager = variantManager
        self.database = database
        self.internalUserDecider = internalUserDecider
        self.isEnabledByUser = isEnabledByUser
        self.onStoreLoadFailed = onStoreLoadFailed
    }

    /// Determines if the history feature is enabled.  This code will need to be cleaned up once the roll out is at 100%
    public func isHistoryFeatureEnabled() -> Bool {
        guard privacyConfigManager.privacyConfig.isEnabled(featureKey: .history) else {
            // Whatever happens if this is disabled then disable the feature
            return false
        }

        if internalUserDecider.isInternalUser {
            // Internal users get the feature
            return true
        }

        if variantManager.isSupported(feature: .history) {
            // Users in the experiment get the fature
            return true
        }

        // Handles incremental roll out to everyone else
        return privacyConfigManager.privacyConfig.isSubfeatureEnabled(HistorySubFeature.onByDefault)
    }

    public func removeAllHistory() async {
        await withCheckedContinuation { continuation in
            historyCoordinator.burnAll {
                continuation.resume()
            }
        }
    }

    public func loadStore() {
        historyCoordinator.loadHistory {
            // Do migrations here if needed in the future
        }
    }

}

class NullHistoryCoordinator: HistoryCoordinating {

    func loadHistory(onCleanFinished: @escaping () -> Void) {
    }

    var history: History.BrowsingHistory?

    var allHistoryVisits: [History.Visit]?

    @Published private(set) public var historyDictionary: [URL: HistoryEntry]?
    var historyDictionaryPublisher: Published<[URL: History.HistoryEntry]?>.Publisher {
        $historyDictionary
    }

    func addVisit(of url: URL) -> History.Visit? {
        return nil
    }

    func addBlockedTracker(entityName: String, on url: URL) {
    }

    func trackerFound(on: URL) {
    }

    func updateTitleIfNeeded(title: String, url: URL) {
    }

    func markFailedToLoadUrl(_ url: URL) {
    }

    func commitChanges(url: URL) {
    }

    func title(for url: URL) -> String? {
        return nil
    }

    func burnAll(completion: @escaping () -> Void) {
        completion()
    }

    func burnDomains(_ baseDomains: Set<String>, tld: Common.TLD, completion: @escaping () -> Void) {
        completion()
    }

    func burnVisits(_ visits: [History.Visit], completion: @escaping () -> Void) {
        completion()
    }

}

public class HistoryDatabase {

    private init() { }

    public static var defaultDBLocation: URL = {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            os_log("HistoryDatabase.make - OUT, failed to get application support directory")
            fatalError("Failed to get location")
        }
        return url
    }()

    public static var defaultDBFileURL: URL = {
        return defaultDBLocation.appendingPathComponent("History.sqlite", conformingTo: .database)
    }()

    public static func make(location: URL = defaultDBLocation, readOnly: Bool = false) -> CoreDataDatabase {
        os_log("HistoryDatabase.make - IN - %s", location.absoluteString)
        let bundle = History.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "BrowsingHistory") else {
            os_log("HistoryDatabase.make - OUT, failed to loadModel")
            fatalError("Failed to load model")
        }

        let db = CoreDataDatabase(name: "History",
                                  containerLocation: location,
                                  model: model,
                                  readOnly: readOnly)
        os_log("HistoryDatabase.make - OUT")
        return db
    }
}

class HistoryStoreEventMapper: EventMapping<HistoryStore.HistoryStoreEvents> {
    public init() {
        super.init { event, error, _, _ in
            switch event {
            case .removeFailed:
                Pixel.fire(pixel: .historyRemoveFailed, error: error)

            case .reloadFailed:
                Pixel.fire(pixel: .historyReloadFailed, error: error)

            case .cleanEntriesFailed:
                Pixel.fire(pixel: .historyCleanEntriesFailed, error: error)

            case .cleanVisitsFailed:
                Pixel.fire(pixel: .historyCleanVisitsFailed, error: error)

            case .saveFailed:
                Pixel.fire(pixel: .historySaveFailed, error: error)

            case .insertVisitFailed:
                Pixel.fire(pixel: .historyInsertVisitFailed, error: error)

            case .removeVisitsFailed:
                Pixel.fire(pixel: .historyRemoveVisitsFailed, error: error)
            }

        }
    }

    override init(mapping: @escaping EventMapping<HistoryStore.HistoryStoreEvents>.Mapping) {
        fatalError("Use init()")
    }
}
