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
    
    private let migrationAssertion = BookmarksMigrationAssertion()

    func loadStoreAndMigrate(bookmarksDatabase: CoreDataDatabase) -> Bool {
        let preMigrationErrorHandling = createErrorHandling()

        let oldFavoritesOrder = BookmarkFormFactorFavoritesMigration
            .getFavoritesOrderFromPreV4Model(
                dbContainerLocation: BookmarksDatabase.defaultDBLocation,
                dbFileURL: BookmarksDatabase.defaultDBFileURL,
                errorEvents: preMigrationErrorHandling
            )

        let validator = BookmarksStateValidation(keyValueStore: UserDefaults.app) { validationError, underlyingError, errorInfo in
            switch validationError {
            case .bookmarksStructureLost:
                DailyPixel.fire(pixel: .debugBookmarksStructureLost,
                                withAdditionalParameters: errorInfo,
                                includedParameters: [.appVersion])
            case .bookmarksStructureBroken:
                DailyPixel.fire(pixel: .debugBookmarksInvalidRoots,
                                withAdditionalParameters: errorInfo,
                                includedParameters: [.appVersion])
            case .validatorError:
                var params = [String: String]()
                if let cdError = underlyingError as? NSError {
                    let processedErrors = CoreDataErrorsParser.parse(error: cdError)
                    params = processedErrors.errorPixelParameters
                }

                DailyPixel.fireDailyAndCount(pixel: .debugBookmarksValidationFailed,
                                             withAdditionalParameters: params,
                                             includedParameters: [.appVersion])
            }
        }

        var migrationHappened = false
        bookmarksDatabase.loadStore { context, error in
            guard let context = assertContext(context, error, crashOnError) else { return }

            validator.validateInitialState(context: context)

            self.migrateFromLegacyCoreDataStorageIfNeeded(context)
            migrationHappened = self.migrateToFormFactorSpecificFavorites(context, oldFavoritesOrder)
            // Add new migrations and set migrationHappened flag here. Only the last migration is relevant.
            // Also bump the int passed to the assert function below.
        }

        let contextForValidation = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        contextForValidation.performAndWait {
            validator.validateBookmarksStructure(context: contextForValidation)
        }

        if migrationHappened {
            do {
                try migrationAssertion.assert(migrationVersion: 1)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        return migrationHappened
    }
    
    private func migrateToFormFactorSpecificFavorites(_ context: NSManagedObjectContext, _ oldFavoritesOrder: [String]?) -> Bool {
        do {
            BookmarkFormFactorFavoritesMigration.migrateToFormFactorSpecificFavorites(byCopyingExistingTo: .mobile,
                                                                                      preservingOrderOf: oldFavoritesOrder,
                                                                                      in: context)
            if context.hasChanges {
                try context.save(onErrorFire: .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders)
                return true
            }
        } catch {
            Thread.sleep(forTimeInterval: 1)
            fatalError("Could not prepare Bookmarks DB structure")
        }
        return false
    }
    
    private func migrateFromLegacyCoreDataStorageIfNeeded(_ context: NSManagedObjectContext) {
        let legacyStorage = LegacyBookmarksCoreDataStorage()
        legacyStorage?.loadStoreAndCaches()
        LegacyBookmarksStoreMigration.migrate(from: legacyStorage, to: context)
        legacyStorage?.removeStore()
    }
    
    private func assertContext(_ context: NSManagedObjectContext?, _ error: Error?, _ crashOnError: Bool) -> NSManagedObjectContext? {
        guard let context = context else {
            if let error = error {
                Pixel.fire(pixel: .bookmarksCouldNotLoadDatabase,
                           error: error)
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

    private func createErrorHandling() -> EventMapping<BookmarkFormFactorFavoritesMigration.MigrationErrors> {
        return EventMapping<BookmarkFormFactorFavoritesMigration.MigrationErrors> { _, error, _, _ in
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
    }
    
}

class BookmarksMigrationAssertion {
    
    enum Error: Swift.Error {
        case unexpectedMigration
    }
    
    @UserDefaultsWrapper(key: .bookmarksLastGoodVersion, defaultValue: nil)
    var lastGoodVersion: String?
    
    @UserDefaultsWrapper(key: .bookmarksMigrationVersion, defaultValue: 0)
    var migrationVersion: Int

    // Wanted to use assertions here, but that's trick to test.
    func assert(migrationVersion: Int) throws {
        if migrationVersion != self.migrationVersion {
            // this is a new migration, so save the app version and move on
            self.lastGoodVersion = Bundle.main.releaseVersionNumber
            self.migrationVersion = migrationVersion
            return
        }
        
        Pixel.fire(pixel: .debugBookmarksMigratedMoreThanOnce, withAdditionalParameters: [
            PixelParameters.bookmarksLastGoodVersion: lastGoodVersion ?? ""
        ])
        
        throw Error.unexpectedMigration
    }
    
}
