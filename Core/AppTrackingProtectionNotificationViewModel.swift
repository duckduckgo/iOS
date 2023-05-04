//
//  AppTrackingProtectionNotificationViewModel.swift
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
import CoreData
import BrowserServicesKit
import Persistence

public struct AppTrackerNetworkStat: Equatable, Hashable {
    public let trackerOwner: String
    public let blockedPrevalence: Double
    public let count: Int32
}

public class AppTrackingProtectionNotificationViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    fileprivate var fetchedResultsController: NSFetchedResultsController<AppTrackerEntity>!
    
    @Published public var trackers: [AppTrackerEntity] = []
    
    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        self.context.stalenessInterval = 0
        
        super.init()
        
        setupFetchedResultsController()
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<AppTrackerEntity> {
        let date = Date(timeIntervalSinceNow: -24 * 60 * 60) // 24 hours ago
        let fetchRequest: NSFetchRequest<AppTrackerEntity> = AppTrackerEntity.fetchRequest(trackersMoreRecentThan: date,
                                                                                           blockedOnly: true)
        let countSort = NSSortDescriptor(key: #keyPath(AppTrackerEntity.count), ascending: false)
        fetchRequest.sortDescriptors = [countSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }
    
    private func setupFetchedResultsController() {
        self.fetchedResultsController = createFetchedResultsController()
        
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
        self.trackers = self.fetchedResultsController.fetchedObjects ?? []
    }
    
    public func totalTrackerCount() -> Int32 {
        let total = trackers.reduce(0) { res, tracker in
            return res + tracker.count
        }
        return total
    }
    
    public func aggregatedResults() -> [AppTrackerNetworkStat] {
        var owners = [String: Int32]()
        for tracker in trackers {
            if let currentCount = owners[tracker.trackerOwner] {
                owners[tracker.trackerOwner] = currentCount + tracker.count
            } else {
                owners[tracker.trackerOwner] = tracker.count
            }
        }
        
        let totalCount = totalTrackerCount()
        let ownersArr = Array(owners.keys
                        .sorted(by: { owners[$0]! > owners[$1]! }))
                        .prefix(10)
                        .map {
                            return AppTrackerNetworkStat(
                                trackerOwner: $0,
                                blockedPrevalence: Double(owners[$0] ?? 0) / Double(totalCount),
                                count: owners[$0] ?? 0
                            )
                        }
        return ownersArr
    }
    
    /// Return the top tracker owners' names
    /// `topCount` defines how many to return (defaults to `3`)
    public func topTrackerOwners(topCount: Int = 3) -> [AppTrackerNetworkStat] {
        var owners = [String: Int32]()
        for tracker in trackers {
            if let currentCount = owners[tracker.trackerOwner] {
                owners[tracker.trackerOwner] = currentCount + tracker.count
            } else {
                owners[tracker.trackerOwner] = tracker.count
            }
        }
        
        let totalCount = totalTrackerCount()
        var topOwners = Array(owners.keys
                        .sorted(by: { owners[$0]! > owners[$1]! })
                        .prefix(topCount)).map {
                            return AppTrackerNetworkStat(
                                trackerOwner: $0,
                                blockedPrevalence: Double(owners[$0] ?? 0) / Double(totalCount),
                                count: owners[$0] ?? 0
                            )
                        }
        topOwners.swapAt(0, 1)
        return topOwners
    }
    
}
