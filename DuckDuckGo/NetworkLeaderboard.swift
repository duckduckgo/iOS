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

        static let visitedSite = "PPVisitedSite"
        static let trackerNetwork = "PPTrackerNetwork"

    }

    struct Constants {

        static let startDateKey = "com.duckduckgo.network.leaderboard.start.date"

    }

    private lazy var container = DDGPersistenceContainer(name: "NetworkLeaderboard", concurrencyType: .mainQueueConcurrencyType)!
    private var userDefaults: UserDefaults!

    var startDate: Date? {
        let timeIntervalSince1970 = userDefaults.double(forKey: Constants.startDateKey)
        guard timeIntervalSince1970 > 0.0 else { return nil }
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }

    init(userDefaults: UserDefaults = UserDefaults()) {
        self.userDefaults = userDefaults
    }

    func reset() {
        container.deleteAll(entities: try? container.managedObjectContext.fetch(PPVisitedSite.fetchRequest()))
        container.deleteAll(entities: try? container.managedObjectContext.fetch(PPTrackerNetwork.fetchRequest()))
        _ = container.save()
        userDefaults.removeObject(forKey: Constants.startDateKey)
    }

    func sitesVisited() -> Int {
        let request: NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        return (try? container.managedObjectContext.count(for: request)) ?? 0
    }

    func networksDetected() -> [PPTrackerNetwork] {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(key: "detectedOnCount", ascending: false) ]
        guard let results = try? container.managedObjectContext.fetch(request) else { return [] }
        return results
    }

    func shouldShow() -> Bool {
        let visitedSitesThreshold = isDebugBuild ? 3 : 30
        return sitesVisited() > visitedSitesThreshold && networksDetected().count >= 3
    }

    func visited(domain: String) {
        guard nil == findSite(byDomain: domain) else { return }

        if nil == startDate {
            setStartDate()
        }

        let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.visitedSite, into: container.managedObjectContext)
        if let visitedSite = managedObject as? PPVisitedSite {
            visitedSite.domain = domain
        }
        _ = container.save()
    }

    func network(named network: String, detectedWhileVisitingDomain domain: String) {
        let byDomainAndNetworkRequest: NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        byDomainAndNetworkRequest.predicate = NSPredicate(format: "domain LIKE %@ AND ANY networksDetected.name LIKE %@", domain, network)

        guard let results = try? container.managedObjectContext.fetch(byDomainAndNetworkRequest), results.isEmpty else { return }

        var visitedSite = findSite(byDomain: domain)
        if visitedSite == nil {
            visited(domain: domain)
            guard let newSite = findSite(byDomain: domain) else { return }
            visitedSite = newSite
        }

        var trackerNetwork: PPTrackerNetwork? = findNetwork(byName: network)
        if trackerNetwork == nil {
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: EntityNames.trackerNetwork, into: container.managedObjectContext)
            trackerNetwork = managedObject as? PPTrackerNetwork
            trackerNetwork?.name = network
            guard trackerNetwork != nil else { return }
        }

        trackerNetwork?.addToDetectedOn(visitedSite!)
        trackerNetwork?.detectedOnCount = (trackerNetwork?.detectedOn?.count ?? 0) as NSNumber

        visitedSite?.addToNetworksDetected(trackerNetwork!)
        _ = container.save()
    }

    private func findSite(byDomain domain: String) -> PPVisitedSite? {
        let request: NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        request.predicate = NSPredicate(format: "domain LIKE %@", domain)
        guard let results = try? container.managedObjectContext.fetch(request) else { return nil }
        return results.first
    }

    private func findNetwork(byName network: String) -> PPTrackerNetwork? {
        let request: NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.predicate = NSPredicate(format: "name LIKE %@", network)
        guard let results = try? container.managedObjectContext.fetch(request) else { return nil }
        return results.first
    }

    private func setStartDate() {
        userDefaults.set(Date().timeIntervalSince1970, forKey: Constants.startDateKey)
    }

}
