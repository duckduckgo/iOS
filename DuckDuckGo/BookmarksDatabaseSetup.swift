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

        let oldFavoritesOrder = BookmarkFormFactorFavoritesMigration
            .getFavoritesOrderFromPreV4Model(
                dbContainerLocation: BookmarksDatabase.defaultDBLocation,
                dbFileURL: BookmarksDatabase.defaultDBFileURL,
                errorEvents: preMigrationErrorHandling
            )

        bookmarksDatabase.loadStore { context, error in
            guard let context = context else {
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

            let legacyStorage = LegacyBookmarksCoreDataStorage()
            legacyStorage?.loadStoreAndCaches()
            LegacyBookmarksStoreMigration.migrate(from: legacyStorage,
                                                  to: context)
            legacyStorage?.removeStore()

            do {
                BookmarkFormFactorFavoritesMigration.migrateToFormFactorSpecificFavorites(byCopyingExistingTo: .mobile,
                                                                                          preservingOrderOf: oldFavoritesOrder,
                                                                                          in: context)
                if context.hasChanges {
                    try context.save(onErrorFire: .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders)
                }
            } catch {
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not prepare Bookmarks DB structure")
            }

        }
        return true
   }

}
