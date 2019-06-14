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
    private let userDefaults: UserDefaults

    var startDate: Date? {
        let timeIntervalSince1970 = userDefaults.double(forKey: Constants.startDateKey)
        guard timeIntervalSince1970 > 0.0 else { return nil }
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }

    init(userDefaults: UserDefaults = UserDefaults()) {
        self.userDefaults = userDefaults
    }

    func reset() {
        container.deleteAll(entities: try? container.managedObjectContext.fetch(PPTrackerNetwork.fetchRequest()))
        _ = container.save()
        userDefaults.removeObject(forKey: Constants.startDateKey)
    }

    func pageVisited() {
        guard startDate == nil else { return }
        userDefaults.set(Date().timeIntervalSince1970, forKey: Constants.startDateKey)
    }
    
    func pagesVisited() -> Int {
        return networksDetected().reduce(0, { $0 + ($1.detectedOnCount ?? 0).intValue })
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
    
    func incrementCount(forNetworkNamed networkName: String) {
        guard let network = findNetwork(byName: networkName) else {
            createNewNetworkEntity(named: networkName)
            return
        }
        let count = (network.detectedOnCount ?? 0).intValue
        network.detectedOnCount = NSNumber(value: count + 1)
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

    private func setStartDate() {
        userDefaults.set(Date().timeIntervalSince1970, forKey: Constants.startDateKey)
    }

}
