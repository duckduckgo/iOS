//
//  AppTrackingProtectionStoringModel.swift
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
import Persistence
import CoreData
import os

public class AppTrackingProtectionStoringModel: ObservableObject {

    private let context: NSManagedObjectContext
    private let dateFormatter: DateFormatter

    private var timer: DispatchSourceTimer?

    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"

        // Uncomment this to start a timer that saves a fake tracker to the database every 3 seconds
        // startFakeTrackerTimer()
    }

    public func storeBlockedTracker(domain: String, trackerOwner: String, date: Date = Date()) {
        let bucket = dateFormatter.string(from: date)

        context.performAndWait {
            do {
                let existingTrackersFetchRequest = AppTrackerEntity.fetchRequest(domain: domain, bucket: bucket)

                if let existingTracker = try context.fetch(existingTrackersFetchRequest).first {
                    existingTracker.count += 1
                    existingTracker.timestamp = date
                } else {
                    _ = AppTrackerEntity.makeTracker(domain: domain,
                                                     trackerOwner: trackerOwner,
                                                     date: date,
                                                     bucket: bucket,
                                                     context: context)
                }

                if let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: date) {
                    let staleTrackersFetchRequest = AppTrackerEntity.fetchRequest(trackersOlderThan: sevenDaysAgo)
                    context.deleteAll(matching: staleTrackersFetchRequest)
                }

                save()
            } catch {
                context.rollback()
            }
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            os_log("[AppTP] Failed to save tracker to database", log: generalLog, type: .error)
            context.rollback()
        }
    }

}

// MARK: - Debugging

extension AppTrackingProtectionStoringModel {

    fileprivate func startFakeTrackerTimer() {
        self.timer = DispatchSource.timer(interval: .seconds(3)) { [weak self] in
            self?.storeBlockedTracker(domain: "fakedomain.com", trackerOwner: "Fake Tracker")
        }
    }

}

extension DispatchSource {

    class func timer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .nanoseconds(0), handler: @escaping () -> Void) -> DispatchSourceTimer {
        let result = DispatchSource.makeTimerSource(queue: DispatchQueue.global())

        result.setEventHandler(handler: handler)
        result.schedule(deadline: DispatchTime.now() + interval, repeating: interval, leeway: leeway)
        result.resume()

        return result
    }

}
