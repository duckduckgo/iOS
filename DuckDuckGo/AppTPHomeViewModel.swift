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

import Foundation
import CoreData
import Persistence
import Core

class AppTPHomeViewModel: ObservableObject {
    @Published public var blockCount: Int32 = 0
    
    private let context: NSManagedObjectContext
    
    public init(appTrackingProtectionDatabase: CoreDataDatabase) {
        self.context = appTrackingProtectionDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        fetchTrackerCount()
    }
    
    /// Use Core Data aggregation to fetch the sum of trackers from the last 24 hours
    public func fetchTrackerCount() {
        let keyPathExpr = NSExpression(forKeyPath: "count")
        let expr = NSExpression(forFunction: "sum:", arguments: [keyPathExpr])
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expr
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer32AttributeType
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AppTrackerEntity")
        fetchRequest.predicate = NSPredicate(format: "%K > %@", #keyPath(AppTrackerEntity.timestamp), Date(timeIntervalSinceNow: -24 * 60 * 60) as NSDate)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        
        if let result = try? context.fetch(fetchRequest) as? [[String: Any]],
           let sum = result.first?[sumDesc.name] as? Int32 {
            blockCount = sum
        }
    }
}
