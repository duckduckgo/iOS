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
import CoreData
import Core
import os

public class AppTrackingProtectionStoringModel: ObservableObject {

    private let context: NSManagedObjectContext

    public init(appTrackingProtectionDatabase: TemporaryAppTrackingProtectionDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
    }

    public func storeBlockedTracker(domain: String) {
        let tracker = AppTrackerEntity.makeTracker(domain: domain,
                                                   context: context)

        save()

        os_log("[AppTP][DATABASE] Wrote tracker to database with domain %{public}s", log: generalLog, type: .error, domain)
    }

    private func save() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

}
