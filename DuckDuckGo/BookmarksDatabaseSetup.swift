//
//  BookmarksDatabaseSetup.swift
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
import Bookmarks
import Persistence

struct BookmarksDatabaseSetup {

    static func loadStoreAndMigrate(bookmarksDatabase: CoreDataDatabase, crashOnLoadStoreError: Bool) -> Bool {
        var migrationHappened = false
        bookmarksDatabase.loadStore { context, error in
            guard let context = assertContext(context, error: error, crashOnError: crashOnLoadStoreError) else { return }
            self.migrateFromFirstVersionOfBookmarksCoreDataStorage(context)
            migrationHappened = self.migrateToFormFactorSpecificFavorites(context)
            // Add future bookmarks database migrations here and set boolean to result of whatever the last migration returns
        }
        return migrationHappened
    }

    private static func assertContext(_ context: NSManagedObjectContext?, error: Error?, crashOnError: Bool) -> NSManagedObjectContext? {
        guard let context = context else {
            if let error = error {
                Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase, error: error)
            } else {
                Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase)
            }

            if !crashOnError {
                return nil
            } else {
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create Bookmarks database stack: \(error?.localizedDescription ?? "err")")
            }
        }
        return context
    }

    private static func migrateFromFirstVersionOfBookmarksCoreDataStorage(_ context: NSManagedObjectContext) {
        let legacyStorage = LegacyBookmarksCoreDataStorage()
        legacyStorage?.loadStoreAndCaches()
        LegacyBookmarksStoreMigration.migrate(from: legacyStorage, to: context)
        legacyStorage?.removeStore()
    }

    private static func migrateToFormFactorSpecificFavorites(_ context: NSManagedObjectContext) -> Bool {
        var migrationHappened = false
        do {
            BookmarkUtils.migrateToFormFactorSpecificFavorites(byCopyingExistingTo: .mobile, in: context)
            if context.hasChanges {
                migrationHappened = true
                try context.save(onErrorFire: .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders)
            }
        } catch {
            Thread.sleep(forTimeInterval: 1)
            fatalError("Could not prepare Bookmarks DB structure")
        }
        return migrationHappened
    }

}
