//
//  AppTrackingProtectionListModel.swift
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
import Combine
import CoreData
import Persistence

public class AppTrackingProtectionListModel: ObservableObject {

    private let context: NSManagedObjectContext

    private lazy var trackerProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    public init(appTrackingProtectionDatabase: TemporaryAppTrackingProtectionDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)

        registerForRemoteChangeNotifications()
    }

    private func registerForRemoteChangeNotifications() {
        guard let coordinator = context.persistentStoreCoordinator else {
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(processStoreRemoteChanges),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: coordinator)
    }

    @objc private func processStoreRemoteChanges(_ notification: Notification) {
        trackerProcessingQueue.addOperation { [weak self] in
            self?.processPersistentHistory()
        }
    }

    @objc private func processPersistentHistory() {
        context.performAndWait {
            do {
                print("DEBUG: Processing history")
            } catch {
                print("Persistent History Tracking failed with error \(error)")
            }
        }
    }
}
