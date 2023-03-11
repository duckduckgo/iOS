//
//  AppTrackingProtectionFeedbackModel.swift
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
import Persistence

public class AppTrackingProtectionFeedbackModel: ObservableObject {

    private let context: NSManagedObjectContext

    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
    }

    public func trackers(moreRecentThan date: Date) -> [AppTrackerEntity] {
        let fetchRequest = AppTrackerEntity.fetchRequest(trackersMoreRecentThan: date)

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            Pixel.fire(pixel: .appTPDBFeedbackTrackerFetchFailed)
            assertionFailure("Failed to fetch trackers, with error: \(error.localizedDescription)")
            return []
        }
    }
    
    public func sendReport(appName: String, category: String, description: String) {
        let date = Calendar.current.date(byAdding: .minute, value: -10, to: Date())!
        let trackers = trackers(moreRecentThan: date)
        let trackersString = trackers.map { $0.domain }.joined(separator: ",")
        
        let parameters = [
            "appName": appName,
            "category": category,
            "description": description,
            "blockedTrackers": trackersString
        ]
        
        Pixel.fire(pixel: .appTPBreakageReport, withAdditionalParameters: parameters)
    }

}
