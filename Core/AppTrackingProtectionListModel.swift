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
import os.log

public class AppTrackingProtectionListModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    @Published var sections: [NSFetchedResultsSectionInfo] = []

    private let context: NSManagedObjectContext

    private lazy var trackerProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<AppTrackerEntity> = {
        let fetchRequest: NSFetchRequest<AppTrackerEntity> = AppTrackerEntity.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "count", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: "bucket",
                                                                  cacheName: nil)

        return fetchedResultsController
    }()

    @UserDefaultsWrapper(key: .lastAppTrackingProtectionHistoryFetchTimestamp, defaultValue: Date.distantPast)
    private var lastTrackerHistoryFetchTimestamp: Date

    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)

        super.init()

        setupFetchedResultsController()
        registerForRemoteChangeNotifications()
    }

    private func setupFetchedResultsController() {
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        self.sections = fetchedResultsController.sections ?? []
    }

    private func registerForRemoteChangeNotifications() {
        guard let coordinator = context.persistentStoreCoordinator else {
            assertionFailure("Failed to get AppTP persistent store coordinator")
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
                try merge()
                try removeTransactions(before: lastTrackerHistoryFetchTimestamp)
            } catch {
                print("Persistent History Tracking failed with error \(error)")
            }
        }
    }

    func merge() throws {
        let fetcher = PersistentHistoryFetcher(context: context, fromDate: lastTrackerHistoryFetchTimestamp)
        let newTransactions = try fetcher.fetch()

        guard !newTransactions.isEmpty else {
            return
        }

        newTransactions.merge(into: context)

        guard let lastTimestamp = newTransactions.last?.timestamp else { return }
        lastTrackerHistoryFetchTimestamp = lastTimestamp
    }

    func removeTransactions(before date: Date) throws {
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: lastTrackerHistoryFetchTimestamp)
        try context.execute(deleteHistoryRequest)
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.sections = controller.sections ?? []
    }
}

extension Collection where Element == NSPersistentHistoryTransaction {

    func merge(into context: NSManagedObjectContext) {
        forEach { transaction in
            guard let userInfo = transaction.objectIDNotification().userInfo else { return }
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [context])
        }
    }

}

struct PersistentHistoryFetcher {

    enum Error: Swift.Error {
        case historyTransactionConversionFailed
    }

    let context: NSManagedObjectContext
    let fromDate: Date

    func fetch() throws -> [NSPersistentHistoryTransaction] {
        let fetchRequest = createFetchRequest()

        guard let historyResult = try context.execute(fetchRequest) as? NSPersistentHistoryResult,
              let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            throw Error.historyTransactionConversionFailed
        }

        return history
    }

    func createFetchRequest() -> NSPersistentHistoryChangeRequest {
        let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: fromDate)

        if let fetchRequest = NSPersistentHistoryTransaction.fetchRequest {
            historyFetchRequest.fetchRequest = fetchRequest
        } else {
            assertionFailure("Failed to create AppTP persistent history fetch request")
        }

        return historyFetchRequest
    }

}
