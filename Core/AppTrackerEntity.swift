//
//  AppTrackerEntity.swift
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

@objc(AppTrackerEntity)
public class AppTrackerEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppTrackerEntity> {
        return NSFetchRequest<AppTrackerEntity>(entityName: "AppTrackerEntity")
    }

    @nonobjc public class func fetchRequest(domain: String, bucket: String) -> NSFetchRequest<AppTrackerEntity> {
        let request = NSFetchRequest<AppTrackerEntity>(entityName: "AppTrackerEntity")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(AppTrackerEntity.domain), domain,
                                        #keyPath(AppTrackerEntity.bucket), bucket)
        return request
    }

    @nonobjc public class func fetchRequest(trackersMoreRecentThan date: Date) -> NSFetchRequest<AppTrackerEntity> {
        let request = NSFetchRequest<AppTrackerEntity>(entityName: "AppTrackerEntity")
        request.predicate = NSPredicate(format: "%K > %@", #keyPath(AppTrackerEntity.timestamp), date as NSDate)
        return request
    }

    public static func makeTracker(domain: String,
                                   trackerOwner: String,
                                   date: Date,
                                   bucket: String,
                                   context: NSManagedObjectContext) -> AppTrackerEntity {
        let object = AppTrackerEntity(context: context)
        object.uuid = UUID().uuidString
        object.domain = domain
        object.trackerOwner = trackerOwner
        object.count = 1
        object.timestamp = date
        object.bucket = bucket

        return object
    }

    @NSManaged public var uuid: String
    @NSManaged public var domain: String
    @NSManaged public var trackerOwner: String
    @NSManaged public var bucket: String
    @NSManaged public var timestamp: Date
    @NSManaged public var count: Int32

}

extension AppTrackerEntity: Identifiable { }
