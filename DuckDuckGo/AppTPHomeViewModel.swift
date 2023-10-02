//
//  AppTPHomeViewModel.swift
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

#if APP_TRACKING_PROTECTION

import Foundation
import CoreData
import Persistence
import Core
import NetworkExtension

class AppTPHomeViewModel: ObservableObject {
    @Published public var blockCount: Int32 = 0
    @Published public var appTPEnabled: Bool = false
    
    private let appTPDatabase: CoreDataDatabase
    private let context: NSManagedObjectContext
    private var firewallManager: FirewallManaging
    
    public init(appTrackingProtectionDatabase: CoreDataDatabase,
                firewallManager: FirewallManaging = FirewallManager()) {
        self.appTPDatabase = appTrackingProtectionDatabase
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        self.firewallManager = firewallManager
        self.firewallManager.delegate = self
        registerForRemoteChangeNotifications()
        
        fetchTrackerCount()
        Task {
            await self.firewallManager.refreshManager()
        }
    }
    
    private func registerForRemoteChangeNotifications() {
        guard let coordinator = context.persistentStoreCoordinator else {
            Pixel.fire(pixel: .appTPDBPersistentStoreLoadFailure)
            assertionFailure("Failed to get AppTP persistent store coordinator")
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchTrackerCount),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: coordinator)
    }
    
    /// Use Core Data aggregation to fetch the sum of trackers from the last 24 hours
    @objc public func fetchTrackerCount() {
        let keyPathExpr = NSExpression(forKeyPath: "count")
        let expr = NSExpression(forFunction: "sum:", arguments: [keyPathExpr])
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expr
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer32AttributeType
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AppTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K > %@", #keyPath(AppTrackerEntity.timestamp),
                                             Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as NSDate)
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        
        Task { @MainActor in
            if let result = try? context.fetch(fetchRequest) as? [[String: Any]],
               let sum = result.first?[sumDesc.name] as? Int32 {
                blockCount = sum
            }
        }
    }
    
    public func showAppTPInSettings() {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
                let rootViewController = window.rootViewController as? MainViewController else { return }

        rootViewController.segueToSettings()
        let navigationController = rootViewController.presentedViewController as? UINavigationController
        navigationController?.popToRootViewController(animated: false)
        navigationController?.pushViewController(AppTPActivityHostingViewController(appTrackingProtectionDatabase: self.appTPDatabase),
                                                 animated: true)
    }
}

extension AppTPHomeViewModel: FirewallDelegate {
    func statusDidChange(newStatus: NEVPNStatus) {
        Task { @MainActor in
            self.appTPEnabled = newStatus == .connected
        }
    }
}

#endif
