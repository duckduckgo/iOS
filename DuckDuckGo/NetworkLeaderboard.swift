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

    struct entityNames {

        static let visitedSite = "PPVisitedSite"
        static let trackerNetwork = "PPTrackerNetwork"

    }

    lazy var container = DDGPersistenceContainer(name: "NetworkLeaderboard")!

    func reset() {
        deleteAll(entities: try? container.managedObjectContext.fetch(PPVisitedSite.fetchRequest()))
        deleteAll(entities: try? container.managedObjectContext.fetch(PPTrackerNetwork.fetchRequest()))
        _ = container.save()
    }

    func percentOfSitesWithNetwork(named: String? = nil) -> Int {
        let allSitesRequest:NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        guard let totalSites = try? container.managedObjectContext.count(for: allSitesRequest), totalSites > 0 else { return 0 }

        let byNetworkRequest:NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        if let named = named {
            byNetworkRequest.predicate = NSPredicate(format: "ANY networksDetected.name contains %@", named)
        } else {
            byNetworkRequest.predicate = NSPredicate(format: "networksDetected.@count > 0")
        }
        guard let sitesWithNetworks = try? container.managedObjectContext.count(for: byNetworkRequest) else { return 0 }
        
        let rawPercent = Float(sitesWithNetworks) / Float(totalSites)
        return Int(rawPercent * 100)
    }

    func networksDetected() -> [String] {
        guard let results:[PPTrackerNetwork] = try? container.managedObjectContext.fetch(PPTrackerNetwork.fetchRequest()) else { return [] }
        return results.map( { $0.name ?? "" } )
    }

    func visited(domain: String) {
        guard nil == findSite(byDomain: domain) else { return }
        let visitedSite = NSEntityDescription.insertNewObject(forEntityName: entityNames.visitedSite, into: container.managedObjectContext) as! PPVisitedSite
        visitedSite.domain = domain
        _ = container.save()
    }

    func network(named network: String, detectedWhileVisitingDomain domain: String) {
        let byDomainAndNetworkRequest:NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        byDomainAndNetworkRequest.predicate = NSPredicate(format: "domain LIKE %@ AND ANY networksDetected.name LIKE %@", domain, network)

        guard let results = try? container.managedObjectContext.fetch(byDomainAndNetworkRequest), results.isEmpty else { return }

        var visitedSite = findSite(byDomain: domain)
        if visitedSite == nil {
            visited(domain: domain)
            guard let newSite = findSite(byDomain: domain) else { return }
            visitedSite = newSite
        }

        var trackerNetwork = findNetwork(byName: network)
        if trackerNetwork == nil {
            trackerNetwork = NSEntityDescription.insertNewObject(forEntityName: entityNames.trackerNetwork, into: container.managedObjectContext) as? PPTrackerNetwork
            trackerNetwork?.name = network
            guard trackerNetwork != nil else { return }
        }
        trackerNetwork?.addToDetectedOn(visitedSite!)
        visitedSite?.addToNetworksDetected(trackerNetwork!)
        _ = container.save()
    }

    private func findSite(byDomain domain: String) -> PPVisitedSite? {
        let request:NSFetchRequest<PPVisitedSite> = PPVisitedSite.fetchRequest()
        request.predicate = NSPredicate(format: "domain LIKE %@", domain)
        guard let results = try? container.managedObjectContext.fetch(request) else { return nil }
        return results.first
    }

    private func findNetwork(byName network: String) -> PPTrackerNetwork? {
        let request:NSFetchRequest<PPTrackerNetwork> = PPTrackerNetwork.fetchRequest()
        request.predicate = NSPredicate(format: "name LIKE %@", network)
        guard let results = try? container.managedObjectContext.fetch(request) else { return nil }
        return results.first
    }

    private func deleteAll(entities: [NSManagedObject]?) {
        guard let entities = entities else { return }
        for entity in entities {
            container.managedObjectContext.delete(entity)
        }
    }

}
