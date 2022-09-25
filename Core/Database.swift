//
//  Database.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

public class Database {
    
    fileprivate struct Constants {
        static let databaseGroupID = "\(Global.groupIdPrefix).database"
        
        static let databaseName = "Database"
    }
    
    public static let shared = makeCoreDataDatabase()
    
    static func makeCoreDataDatabase() -> CoreDataDatabase {
        
        let mainBundle = Bundle.main
        let coreBundle = Bundle(identifier: "com.duckduckgo.mobile.ios.Core")!
        
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [mainBundle, coreBundle]) else { fatalError("No DB scheme found") }
        
        
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Database.Constants.databaseGroupID)!
        return CoreDataDatabase(name: "Database",
                                url: url,
                                model: managedObjectModel,
                                errorEvents: nil,
                                log: .disabled)
    }
}
