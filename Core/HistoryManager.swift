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

public class HistoryManager {

    let privacyConfigManager: PrivacyConfigurationManaging
    let variantManager: VariantManager
    let database: CoreDataDatabase

    private var currentHistoryCoordinator: HistoryCoordinating?

    var historyCoordinator: HistoryCoordinating {
        if !isHistoryFeatureEnabled() {
            currentHistoryCoordinator = nil
            return NullHistoryCoordinator()
        }

        if let currentHistoryCoordinator {
            return currentHistoryCoordinator
        }

        let context = database.makeContext(concurrencyType: .privateQueueConcurrencyType)
        let historyCoordinator = HistoryCoordinator(historyStoring: HistoryStore(context: context))
        currentHistoryCoordinator = historyCoordinator
        historyCoordinator.loadHistory {
            // no-op
        }
        return historyCoordinator
    }

    public init(privacyConfigManager: PrivacyConfigurationManaging, variantManager: VariantManager, database: CoreDataDatabase) {
        self.privacyConfigManager = privacyConfigManager
        self.variantManager = variantManager
        self.database = database
    }

    func isHistoryFeatureEnabled() -> Bool {
        return privacyConfigManager.privacyConfig.isEnabled(featureKey: .history) && variantManager.isSupported(feature: .history)
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
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "HistoryModel") else {
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
