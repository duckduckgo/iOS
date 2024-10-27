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

    enum Result {
        case success
        case failure(Error)
    }

    private let migrationAssertion: BookmarksMigrationAssertion

    init(migrationAssertion: BookmarksMigrationAssertion = BookmarksMigrationAssertion()) {
        self.migrationAssertion = migrationAssertion
    }

    static func makeValidator() -> BookmarksStateValidator {
        return BookmarksStateValidator(keyValueStore: UserDefaults.app) { validationError in
            switch validationError {
            case .bookmarksStructureLost:
                DailyPixel.fire(pixel: .debugBookmarksStructureLost, includedParameters: [.appVersion])
            case .bookmarksStructureNotRecovered:
                DailyPixel.fire(pixel: .debugBookmarksStructureNotRecovered, includedParameters: [.appVersion])
            case .bookmarksStructureBroken(let additionalParams):
                DailyPixel.fire(pixel: .debugBookmarksInvalidRoots,
                                withAdditionalParameters: additionalParams,
                                includedParameters: [.appVersion])
            case .validatorError(let underlyingError):
                let processedErrors = CoreDataErrorsParser.parse(error: underlyingError as NSError)

                DailyPixel.fireDailyAndCount(pixel: .debugBookmarksValidationFailed,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             withAdditionalParameters: processedErrors.errorPixelParameters,
                                             includedParameters: [.appVersion])
            }
        }
    }

    func loadStoreAndMigrate(bookmarksDatabase: CoreDataStoring,
                             formFactorFavoritesMigrator: BookmarkFormFactorFavoritesMigrating = BookmarkFormFactorFavoritesMigration(),
                             validator: BookmarksStateValidation = Self.makeValidator()) -> Result {

        let oldFavoritesOrder: [String]?
        do {
            oldFavoritesOrder = try formFactorFavoritesMigrator.getFavoritesOrderFromPreV4Model(
                dbContainerLocation: BookmarksDatabase.defaultDBLocation,
                dbFileURL: BookmarksDatabase.defaultDBFileURL
            )
        } catch {
            return .failure(error)
        }

        var migrationHappened = false
        var loadError: Error?
        bookmarksDatabase.loadStore { context, error in
            guard let context = context, error == nil else {
                loadError = error
                return
            }

            // Perform pre-setup/migration validation
            let isMissingStructure = !validator.validateInitialState(context: context,
                                                                     validationError: .bookmarksStructureLost)

            self.migrateFromLegacyCoreDataStorageIfNeeded(context)
            migrationHappened = self.migrateToFormFactorSpecificFavorites(context, oldFavoritesOrder)

            if isMissingStructure {
                _ = validator.validateInitialState(context: context,
                                                   validationError: .bookmarksStructureNotRecovered)
            }

            // Add new migrations and set migrationHappened flag above this comment. Only the last migration is relevant.
            // Also bump the int passed to the assert function below.
        }

        if let loadError {
            return .failure(loadError)
        }

        // Perform post-setup validation
        let contextForValidation = bookmarksDatabase.makeContext(concurrencyType: .privateQueueConcurrencyType)
        contextForValidation.performAndWait {
            validator.validateBookmarksStructure(context: contextForValidation)
            repairDeletedFlag(context: contextForValidation)
        }

        if migrationHappened {
            do {
                try migrationAssertion.assert(migrationVersion: 1)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        return .success
    }

    private func repairDeletedFlag(context: NSManagedObjectContext) {
        let stateRepair = BookmarksStateRepair(keyValueStore: UserDefaults.app)
        let status = stateRepair.validateAndRepairPendingDeletionState(in: context)
        switch status {
        case .alreadyPerformed, .noBrokenData:
            break
        case .dataRepaired:
            Pixel.fire(pixel: .debugBookmarksPendingDeletionFixed)
        case .repairError(let underlyingError):
            let processedErrors = CoreDataErrorsParser.parse(error: underlyingError as NSError)

            DailyPixel.fireDailyAndCount(pixel: .debugBookmarksPendingDeletionRepairError,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                         withAdditionalParameters: processedErrors.errorPixelParameters,
                                         includedParameters: [.appVersion])
        }
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
}

class BookmarksMigrationAssertion {
    
    enum Error: Swift.Error {
        case unexpectedMigration
    }

    let store: KeyValueStoring

    init(store: KeyValueStoring = UserDefaults.app) {
        self.store = store
    }

    var lastGoodVersion: String? {
        get {
            return store.object(forKey: UserDefaultsWrapper<Int>.Key.bookmarksLastGoodVersion.rawValue) as? String
        }
        set {
            store.set(newValue, forKey: UserDefaultsWrapper<Int>.Key.bookmarksLastGoodVersion.rawValue)
        }
    }

    var migrationVersion: Int {
        get {
            return (store.object(forKey: UserDefaultsWrapper<Int>.Key.bookmarksMigrationVersion.rawValue) as? Int) ?? 0
        }
        set {
            store.set(newValue, forKey: UserDefaultsWrapper<Int>.Key.bookmarksMigrationVersion.rawValue)
        }
    }

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
