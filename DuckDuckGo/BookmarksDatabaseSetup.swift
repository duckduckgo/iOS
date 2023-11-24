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
import Common

struct BookmarksDatabaseSetup {

    let crashOnError: Bool

    func loadStoreAndMigrate(bookmarksDatabase: CoreDataDatabase) -> Bool {
        var migrationHappened = false

        let oldFavoritesOrder = getOldFavoritesOrder()

        bookmarksDatabase.loadStore { context, error in
            guard let context = assertContext(context, error: error) else { return }
            self.migrateFromFirstVersionOfBookmarksCoreDataStorage(context)
            migrationHappened = self.migrateToFormFactorSpecificFavorites(context, oldFavoritesOrder: oldFavoritesOrder)
            // Add future bookmarks database migrations here and set boolean to result of whatever the last migration returns
        }
        return migrationHappened
    }

    private func assertContext(_ context: NSManagedObjectContext?, error: Error?) -> NSManagedObjectContext? {
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

    private func getOldFavoritesOrder() -> [String]? {
        let preMigrationErrorHandling = EventMapping<BookmarkFormFactorFavoritesMigration.MigrationErrors> { _, error, _, _ in
            if let error = error {
                Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase,
                           error: error)
            } else {
                Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase)
            }

            if !crashOnError {
                return
            } else {
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create Bookmarks database stack: \(error?.localizedDescription ?? "err")")
            }
        }

        return BookmarkFormFactorFavoritesMigration
            .getFavoritesOrderFromPreV4Model(
                dbContainerLocation: BookmarksDatabase.defaultDBLocation,
                dbFileURL: BookmarksDatabase.defaultDBFileURL,
                errorEvents: preMigrationErrorHandling
            )
    }

    private func migrateFromFirstVersionOfBookmarksCoreDataStorage(_ context: NSManagedObjectContext) {
        let legacyStorage = LegacyBookmarksCoreDataStorage()
        legacyStorage?.loadStoreAndCaches()
        LegacyBookmarksStoreMigration.migrate(from: legacyStorage, to: context)
        legacyStorage?.removeStore()
    }

    private func migrateToFormFactorSpecificFavorites(_ context: NSManagedObjectContext, oldFavoritesOrder: [String]?) -> Bool {
        var migrationHappened = false
        do {
            BookmarkFormFactorFavoritesMigration.migrateToFormFactorSpecificFavorites(byCopyingExistingTo: .mobile,
                                                                                      preservingOrderOf: oldFavoritesOrder,
                                                                                      in: context)
            if context.hasChanges {
                migrationHappened = true
                try context.save(onErrorFire: .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders)
            }
        } catch {
            // Ignore crash on error flag, because getting to this point really is fatal
            Thread.sleep(forTimeInterval: 1)
            fatalError("Could not prepare Bookmarks DB structure")
        }
        return migrationHappened
    }

}
