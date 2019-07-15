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

    struct EntityNames {

        static let pageStats = "PPPageStats"
        static let trackerNetwork = "PPTrackerNetwork"

    }

    private lazy var container = DDGPersistenceContainer(name: "NetworkLeaderboard", concurrencyType: .mainQueueConcurrencyType)!

    var startDate: Date? {
        return pageStats?.startDate
    }
    
    private var pageStats: PPPageStats? {
        let request: NSFetchRequest<PPPageStats> = PPPageStats.fetchRequest()
        return try? container.managedObjectContext.fetch(request).first
    }
    
    init() {
        if pageStats == nil {
            reset()
        }
    }
    
    func reset() {
        container.deleteAll(entities: try? container.managedObjectContext.fetch(PPTrackerNetwork.fetchRequest()))
        container.deleteAll(entities: try? container.managedObjectContext.fetch(PPPageStats.fetchRequest()))
        createNewPageStatsEntity()
        _ = container.save()
    }

    func incrementPagesLoaded() {
        if let pageStats = pageStats {
            let count = (pageStats.pagesLoaded ?? 0).intValue
            pageStats.pagesLoaded = NSNumber(value: count + 1)
            _ = container.save()
        }
    }
    
    func incrementPagesWithTrackers() {
        if let pageStats = pageStats {
            let count = (pageStats.pagesWithTrackers ?? 0).intValue
            pageStats.pagesWithTrackers = NSNumber(value: count + 1)
            _ = container.save()
        }
    }
    
    func incrementHttpsUpgrades() {
        if let pageStats = pageStats {
            let count = pageStats.httpsUpgrades + 1
            pageStats.httpsUpgrades = count
            _ = container.save()
        }
    }
    
    private func createNewPageStatsEntity() {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.pageStats, into: container.managedObjectContext)
        guard let stats = managedObject as? PPPageStats else { return }
        stats.startDate = Date()
        stats.pagesLoaded = NSNumber(value: 0)
        _ = container.save()
    }
    
    func pagesVisited() -> Int {
        return pageStats?.pagesLoaded?.intValue ?? 0
    }
    
    func pagesWithTrackers() -> Int {
        return pageStats?.pagesWithTrackers?.intValue ?? 0
    }
    
    func httpsUpgrades() -> Int {
        return Int(pageStats?.httpsUpgrades ?? 0)
    }

    func networksDetected() -> [PPTrackerNetwork] {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(key: "detectedOnCount", ascending: false) ]
        guard let results = try? container.managedObjectContext.fetch(request) else { return [] }
        return results
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
        let count = (network.detectedOnCount ?? 0).intValue
        network.detectedOnCount = NSNumber(value: count + 1)
        _ = container.save()
    }
    
    func incrementTrackersCount(forNetworkNamed networkName: String) {
        guard let network = findNetwork(byName: networkName) else {
            createNewNetworkEntity(named: networkName)
            return
        }
        let count = network.trackersCount + 1
        network.trackersCount = count
        _ = container.save()
    }
    
    private func createNewNetworkEntity(named networkName: String) {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.trackerNetwork, into: container.managedObjectContext)
        guard let trackerNetwork = managedObject as? PPTrackerNetwork else { return }
        trackerNetwork.name = networkName
        trackerNetwork.detectedOnCount = 1
        _ = container.save()
    }

    private func findNetwork(byName network: String) -> PPTrackerNetwork? {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.predicate = NSPredicate(format: "name LIKE %@", network)
        guard let results = try? container.managedObjectContext.fetch(request) else { return nil }
        return results.first
    }

}
