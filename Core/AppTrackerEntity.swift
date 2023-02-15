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

    public static func makeTracker(
        domain: String,
        context: NSManagedObjectContext
    ) -> AppTrackerEntity {
        let object = AppTrackerEntity(context: context)
        object.domain = domain
        object.timestamp = Date()

        return object
    }

    @NSManaged public var uuid: String
    @NSManaged public var domain: String
    @NSManaged public var timestamp: Date

}

extension AppTrackerEntity: Identifiable { }
