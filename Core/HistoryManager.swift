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
import os.log

public protocol HistoryManaging {
    
    var historyCoordinator: HistoryCoordinating { get }
    func isHistoryFeatureEnabled() -> Bool
    var isEnabledByUser: Bool { get }
    func removeAllHistory() async
    func deleteHistoryForURL(_ url: URL) async

}

public class HistoryManager: HistoryManaging {

    let privacyConfigManager: PrivacyConfigurationManaging
    let dbCoordinator: HistoryCoordinator
    let tld: TLD

    public var historyCoordinator: HistoryCoordinating {
        guard isHistoryFeatureEnabled(),
                isEnabledByUser else {
            return NullHistoryCoordinator()
        }
        return dbCoordinator
    }

    public let isAutocompleteEnabledByUser: () -> Bool
    public let isRecentlyVisitedSitesEnabledByUser: () -> Bool

    public var isEnabledByUser: Bool {
        return isAutocompleteEnabledByUser() && isRecentlyVisitedSitesEnabledByUser()
    }

    /// Use `make()`
    init(privacyConfigManager: PrivacyConfigurationManaging,
         dbCoordinator: HistoryCoordinator,
         tld: TLD,
         isAutocompleteEnabledByUser: @autoclosure @escaping () -> Bool,
         isRecentlyVisitedSitesEnabledByUser: @autoclosure @escaping () -> Bool) {

        self.privacyConfigManager = privacyConfigManager
        self.dbCoordinator = dbCoordinator
        self.tld = tld
        self.isAutocompleteEnabledByUser = isAutocompleteEnabledByUser
        self.isRecentlyVisitedSitesEnabledByUser = isRecentlyVisitedSitesEnabledByUser
    }

    /// Determines if the history feature is enabled.  This code will need to be cleaned up once the roll out is at 100%
    public func isHistoryFeatureEnabled() -> Bool {
        return privacyConfigManager.privacyConfig.isEnabled(featureKey: .history)
    }

    public func removeAllHistory() async {
        await withCheckedContinuation { continuation in
            dbCoordinator.burnAll {
                continuation.resume()
            }
        }
    }

    public func deleteHistoryForURL(_ url: URL) async {
        guard let domain = url.host,
            let baseDomain = tld.eTLDplus1(domain) else { return }

        await withCheckedContinuation { continuation in
            historyCoordinator.burnDomains([baseDomain], tld: tld) { _ in
                continuation.resume()
            }
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

    func addVisit(of url: URL, at date: Date) -> History.Visit? {
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

    func burnDomains(_ baseDomains: Set<String>, tld: Common.TLD, completion: @escaping (Set<URL>) -> Void) {
        completion([])
    }

    func burnVisits(_ visits: [History.Visit], completion: @escaping () -> Void) {
        completion()
    }

    func removeUrlEntry(_ url: URL, completion: (((any Error)?) -> Void)?) {
        completion?(nil)
    }

}

public class HistoryDatabase {

    private init() { }

    public static var defaultDBLocation: URL = {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            Logger.general.fault("HistoryDatabase.make - OUT, failed to get application support directory")
            fatalError("Failed to get location")
        }
        return url
    }()

    public static var defaultDBFileURL: URL = {
        return defaultDBLocation.appendingPathComponent("History.sqlite", conformingTo: .database)
    }()

    public static func make(location: URL = defaultDBLocation, readOnly: Bool = false) -> CoreDataDatabase {
        Logger.general.debug("HistoryDatabase.make - IN - \(location.absoluteString)")
        let bundle = History.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "BrowsingHistory") else {
            Logger.general.debug("HistoryDatabase.make - OUT, failed to loadModel")
            fatalError("Failed to load model")
        }

        let db = CoreDataDatabase(name: "History",
                                  containerLocation: location,
                                  model: model,
                                  readOnly: readOnly)
        Logger.general.debug("HistoryDatabase.make - OUT")
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

extension HistoryManager {

    /// Should only be called once in the app
    public static func make(isAutocompleteEnabledByUser: @autoclosure @escaping () -> Bool,
                            isRecentlyVisitedSitesEnabledByUser: @autoclosure @escaping () -> Bool,
                            privacyConfigManager: PrivacyConfigurationManaging,
                            tld: TLD) -> Result<HistoryManager, Error> {

        let database = HistoryDatabase.make()
        var loadError: Error?
        database.loadStore { _, error in
            loadError = error
        }

        if let loadError {
            return .failure(loadError)
        }

        let context = database.makeContext(concurrencyType: .privateQueueConcurrencyType)
        let dbCoordinator = HistoryCoordinator(historyStoring: HistoryStore(context: context, eventMapper: HistoryStoreEventMapper()))

        let historyManager = HistoryManager(privacyConfigManager: privacyConfigManager,
                                            dbCoordinator: dbCoordinator,
                                            tld: tld,
                                            isAutocompleteEnabledByUser: isAutocompleteEnabledByUser(),
                                            isRecentlyVisitedSitesEnabledByUser: isRecentlyVisitedSitesEnabledByUser())

        dbCoordinator.loadHistory(onCleanFinished: {
            // Do future migrations after clean has finished.  See macOS for an example.
        })

        return .success(historyManager)
    }

}

// Available in case `make` fails so that we don't have to pass optional around.
public struct NullHistoryManager: HistoryManaging {

    public var isEnabledByUser = false

    public let historyCoordinator: HistoryCoordinating = NullHistoryCoordinator()
    
    public func removeAllHistory() async {
        // No-op
    }

    public func isHistoryFeatureEnabled() -> Bool {
        return false
    }

    public init() { }
    
    public func deleteHistoryForURL(_ url: URL) async { }
}
