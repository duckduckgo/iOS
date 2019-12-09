//
//  NetworkLeaderboard.swift
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
import CoreData
import Core

class NetworkLeaderboard {

    public static let shared = NetworkLeaderboard()

    struct Constants {
        
        // Increment this to cause a reset on startup (e.g. if we know the TDS has changed significantly)
        static let dataVersion = 1
        static let dataVersionKey = "com.duckduckgo.mobile.ios.networkleaderboard.dataversion"
        
    }
    
    struct EntityNames {

        static let pageStats = "PPPageStats"
        static let trackerNetwork = "PPTrackerNetwork"

    }

    private lazy var context = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "NetworkLeaderboard")
    private var userDefaults: UserDefaults
    
    var startDate: Date? {
        return pageStats?.startDate
    }
    
    var needsDataReset: Bool {
        return userDefaults.integer(forKey: Constants.dataVersionKey) < Constants.dataVersion
    }
    
    private var pageStats: PPPageStats? {
        let request: NSFetchRequest<PPPageStats> = PPPageStats.fetchRequest()
        return try? context.fetch(request).first
    }
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        if pageStats == nil || needsDataReset {
            reset()
        }
    }
    
    func reset() {
        context.deleteAll(matching: PPTrackerNetwork.fetchRequest())
        context.deleteAll(matching: PPPageStats.fetchRequest())
        createNewPageStatsEntity()
        try? context.save()
        userDefaults.set(Constants.dataVersion, forKey: Constants.dataVersionKey)
    }

    func incrementPagesLoaded() {
        if let pageStats = pageStats {
            pageStats.pagesLoaded += 1
            try? context.save()
        }
    }
    
    func incrementPagesWithTrackers() {
        if let pageStats = pageStats {
            pageStats.pagesWithTrackers += 1
            try? context.save()
        }
    }
    
    func incrementHttpsUpgrades() {
        if let pageStats = pageStats {
            pageStats.httpsUpgrades += 1
            try? context.save()
        }
    }
    
    private func createNewPageStatsEntity() {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.pageStats, into: context)
        guard let stats = managedObject as? PPPageStats else { return }
        stats.startDate = Date()
        stats.pagesLoaded = 0
        try? context.save()
    }
    
    func pagesVisited() -> Int {
        return Int(pageStats?.pagesLoaded ?? 0)
    }
    
    func pagesWithTrackers() -> Int {
        return Int(pageStats?.pagesWithTrackers ?? 0)
    }
    
    func httpsUpgrades() -> Int {
        return Int(pageStats?.httpsUpgrades ?? 0)
    }

    func networksDetected() -> [PPTrackerNetwork] {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(key: "detectedOnCount", ascending: false) ]
        guard let results = try? context.fetch(request) else { return [] }
        let pagesVisitedCount = Float(pagesVisited())
        return results.filter { Float($0.detectedOnCount) / pagesVisitedCount >= 0.01 }
    }

    func shouldShow() -> Bool {
        let pagesVisitedThreshold = isDebugBuild ? 3 : 30
        return pagesVisited() > pagesVisitedThreshold && networksDetected().count >= 3
    }
    
    func incrementDetectionCount(forNetworkNamed networkName: String) {
        guard let network = findNetwork(byName: networkName) else {
            createNewNetworkEntity(named: networkName)
            return
        }
        network.detectedOnCount += 1
        try? context.save()
    }
    
    func incrementTrackersCount(forNetworkNamed networkName: String) {
        guard let network = findNetwork(byName: networkName) else {
            createNewNetworkEntity(named: networkName)
            return
        }
        network.trackersCount += 1
        try? context.save()
    }
    
    private func createNewNetworkEntity(named networkName: String) {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.trackerNetwork, into: context)
        guard let trackerNetwork = managedObject as? PPTrackerNetwork else { return }
        trackerNetwork.name = networkName
        trackerNetwork.detectedOnCount = 1
        try? context.save()
    }

    private func findNetwork(byName network: String) -> PPTrackerNetwork? {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.predicate = NSPredicate(format: "name LIKE %@", network)
        guard let results = try? context.fetch(request) else { return nil }
        return results.first
    }

}
