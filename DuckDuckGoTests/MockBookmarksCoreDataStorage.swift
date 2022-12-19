//
//  MockBookmarksCoreDataStorage.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Bookmarks
import Persistence
@testable import DuckDuckGo
@testable import Core

class MockBookmarksDatabase {
    
    static func tempDBDir() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }
    
    static func make(prepareFolderStructure: Bool = true) -> CoreDataDatabase {
        let db = BookmarksDatabase.make(location: tempDBDir())
        db.loadStore()
        
        if prepareFolderStructure {
            let context = db.makeContext(concurrencyType: .privateQueueConcurrencyType)
            context.performAndWait {
                do {
                    BookmarkUtils.prepareFoldersStructure(in: context)
                    try context.save()
                } catch {
                    fatalError("Could not setup mock DB")
                }
            }
        }
        
        return db
    }
}
