//
//  AppTrackingProtectionListViewModel.swift
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
import Common
import CoreData
import Persistence

public class AppTrackingProtectionListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    enum Error: Swift.Error {
        case historyTransactionConversionFailed
    }

    @Published public var sections: [NSFetchedResultsSectionInfo] = []

    @Published public var debugModeEnabled = false
    @Published public var isOnboarding = false
    
    // We only want to show "Manage Trackers" and "Report an issue" if the user has enabled AppTP at least once
    @UserDefaultsWrapper(key: .appTPUsed, defaultValue: false)
    public var appTPUsed {
        didSet {
            isOnboarding = !appTPUsed
        }
    }

    private let context: NSManagedObjectContext

    private lazy var trackerProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let relativeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private let relativeTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }()

    private let listViewDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public func formattedDate(_ sectionName: String) -> String {
        guard let date = inputFormatter.date(from: sectionName) else {
            return "Invalid Date"
        }
        
        let relativeDate = relativeFormatter.string(from: date)
        if relativeDate.rangeOfCharacter(from: .decimalDigits) != nil {
            return dateFormatter.string(from: date)
        }
        
        return relativeDate
    }
    
    /// Returns a relative datestring for the given timestamp. e.g. "5 min. ago"
    /// If the timestamp is within 1 second of the current time this function will return `nil`
    /// A `nil` return value should be considered "just now".
    public func format(timestamp: Date) -> String? {
        let date = Date()
        let timestampInterval = timestamp.timeIntervalSinceReferenceDate
        let dateInterval = date.timeIntervalSinceReferenceDate
        if fabs(dateInterval - timestampInterval) < 1 {
            // Can't access UserText from Core. To prevent handling the localized string "in 0 seconds"
            // return nil here and replace it with UserText on the view side.
            return nil
        }
        
        return relativeTimeFormatter.localizedString(for: timestamp, relativeTo: Date())
    }

    fileprivate var fetchedResultsController: NSFetchedResultsController<AppTrackerEntity>!

    private func createFetchedResultsController() -> NSFetchedResultsController<AppTrackerEntity> {
        let fetchRequest: NSFetchRequest<AppTrackerEntity> = AppTrackerEntity.fetchRequest()

        let bucketSortDescriptor = NSSortDescriptor(key: #keyPath(AppTrackerEntity.bucket), ascending: false)
        let domainSortDescriptor = NSSortDescriptor(key: #keyPath(AppTrackerEntity.domain), ascending: true)
        let timestampSortDescriptor = NSSortDescriptor(key: #keyPath(AppTrackerEntity.timestamp), ascending: false)
        fetchRequest.sortDescriptors = [bucketSortDescriptor, timestampSortDescriptor, domainSortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.context,
                                                                  sectionNameKeyPath: #keyPath(AppTrackerEntity.bucket),
                                                                  cacheName: nil)

        return fetchedResultsController
    }

    @UserDefaultsWrapper(key: .lastAppTrackingProtectionHistoryFetchTimestamp, defaultValue: Date.distantPast)
    private var lastTrackerHistoryFetchTimestamp: Date

    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        self.context.stalenessInterval = 0

        super.init()
        
        self.isOnboarding = !appTPUsed

        setupFetchedResultsController()
        registerForLifecycleEvents()
        registerForRemoteChangeNotifications()
    }

    private func setupFetchedResultsController() {
        self.fetchedResultsController = createFetchedResultsController()

        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
        self.sections = self.fetchedResultsController.sections ?? []
    }

    public func format(date: Date) -> String {
        return listViewDateFormatter.string(from: date)
    }

    // MARK: - Notifications

    private func registerForLifecycleEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func registerForRemoteChangeNotifications() {
        guard let coordinator = context.persistentStoreCoordinator else {
            Pixel.fire(pixel: .appTPDBPersistentStoreLoadFailure)
            assertionFailure("Failed to get AppTP persistent store coordinator")
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(processStoreRemoteChanges),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: coordinator)
    }

    @objc private func didBecomeActive(_ notification: Notification) {
        trackerProcessingQueue.addOperation { [weak self] in
            self?.processPersistentHistory()
        }
    }

    @objc private func processStoreRemoteChanges(_ notification: Notification) {
        trackerProcessingQueue.addOperation { [weak self] in
            self?.processPersistentHistory()
        }
    }

    // MARK: - Persistent History Tracking

    private func processPersistentHistory() {
        mergeNewPersistentHistoryTransactions()
    }

    // AppTP's database uses persistent history tracking. This is currently not necessary, as the changes are only going one way, but this may not
    // always be the case (eventually the app process may begin making changes to the store), so this change is in place for future proofing.
    @objc private func mergeNewPersistentHistoryTransactions() {
        context.performAndWait {
            do {
                try mergeNewTransactions()
                try removeTransactions(olderThan: lastTrackerHistoryFetchTimestamp)
            } catch {
                Pixel.fire(pixel: .appTPDBHistoryFailure)
                print("Persistent History Tracking failed with error \(error)")
            }
        }
    }

    private func createPersistentHistoryFetchRequest(after date: Date) -> NSPersistentHistoryChangeRequest {
        let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: date)

        if let fetchRequest = NSPersistentHistoryTransaction.fetchRequest {
            historyFetchRequest.fetchRequest = fetchRequest
        } else {
            Pixel.fire(pixel: .appTPDBHistoryFetchFailure)
            assertionFailure("Failed to create AppTP persistent history fetch request")
        }

        return historyFetchRequest
    }

    private func fetchNewTransactions() throws -> [NSPersistentHistoryTransaction] {
        let fetchRequest = createPersistentHistoryFetchRequest(after: self.lastTrackerHistoryFetchTimestamp)

        guard let historyResult = try context.execute(fetchRequest) as? NSPersistentHistoryResult,
              let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            throw Error.historyTransactionConversionFailed
        }

        return history
    }

    private func mergeNewTransactions() throws {
        let newTransactions = try fetchNewTransactions()

        guard !newTransactions.isEmpty else {
            return
        }

        newTransactions.merge(into: context)

        guard let lastTimestamp = newTransactions.last?.timestamp else { return }
        lastTrackerHistoryFetchTimestamp = lastTimestamp
    }

    private func removeTransactions(olderThan date: Date) throws {
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: lastTrackerHistoryFetchTimestamp)
        try context.execute(deleteHistoryRequest)
    }

    // MARK: - NSFetchedResultsController

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
