//
//  BookmarksDatabaseSetupTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import XCTest
import Persistence
import CoreData
import Bookmarks
@testable import DuckDuckGo
@testable import Core
import PersistenceTestingUtils

class DummyCoreDataStoreMock: CoreDataStoring {

    init() {
        model = NSManagedObjectModel()
        coordinator = NSPersistentStoreCoordinator()
    }

    var isDatabaseFileInitialized: Bool = false
    var model: NSManagedObjectModel
    var coordinator: NSPersistentStoreCoordinator
    
    var onLoadStore: ((NSManagedObjectContext?, Error?) -> Void) -> Void = { _ in }
    func loadStore(completion: @escaping (NSManagedObjectContext?, Error?) -> Void) {
        onLoadStore(completion)
    }

    var onMakeContext = { }
    func makeContext(concurrencyType: NSManagedObjectContextConcurrencyType, name: String?) -> NSManagedObjectContext {
        onMakeContext()

        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
}

class CoreDataStoreMock: CoreDataStoring {

    let db: CoreDataDatabase
    init(db: CoreDataDatabase) {
        self.db = db
    }

    var isDatabaseFileInitialized: Bool = false
    var model: NSManagedObjectModel {
        db.model
    }
    var coordinator: NSPersistentStoreCoordinator {
        db.coordinator
    }

    var onLoadStore: () -> Void = { }
    func loadStore(completion: @escaping (NSManagedObjectContext?, Error?) -> Void) {
        onLoadStore()
        db.loadStore(completion: completion)
    }

    var onMakeContext = { }
    func makeContext(concurrencyType: NSManagedObjectContextConcurrencyType, name: String?) -> NSManagedObjectContext {
        onMakeContext()
        return db.makeContext(concurrencyType: concurrencyType, name: name)
    }
}

class FormFactorMigratingMock: BookmarkFormFactorFavoritesMigrating {

    var onGetFavs: () throws -> [String]? = { return nil }
    func getFavoritesOrderFromPreV4Model(dbContainerLocation: URL, dbFileURL: URL) throws -> [String]? {
        try onGetFavs()
    }
}

class BookmarksStateValidationMock: BookmarksStateValidation {

    var onValidateInitialState: () -> Bool = { return true }
    func validateInitialState(context: NSManagedObjectContext, validationError: Core.BookmarksStateValidator.ValidationError) -> Bool {
        onValidateInitialState()
    }
    
    var onValidateBookmarksStructure: () -> Void = { }
    func validateBookmarksStructure(context: NSManagedObjectContext) {
        onValidateBookmarksStructure()
    }
}

class BookmarksDatabaseSetupTests: XCTestCase {

    let validatorMock = BookmarksStateValidationMock()
    let ffMock = FormFactorMigratingMock()

    func setUpValidBookmarksDatabase() -> CoreDataDatabase? {
        let location = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let bundle = Bookmarks.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "BookmarksModel") else {
            XCTFail("Failed to load model")
            return nil
        }
        return CoreDataDatabase(name: type(of: self).description(),
                                containerLocation: location,
                                model: model)
    }

    func testWhenDatabaseLoadsCorrectlyThenValidationIsPerformed() {

        guard let bookmarksDB = setUpValidBookmarksDatabase() else {
            XCTFail("Could not create DB")
            return
        }

        let dbMock = CoreDataStoreMock(db: bookmarksDB)

        let storeLoaded = expectation(description: "store loaded")
        dbMock.onLoadStore = {
            storeLoaded.fulfill()
        }

        // Used in Validation
        let contextPrepared = expectation(description: "context loaded")
        dbMock.onMakeContext = {
            contextPrepared.fulfill()
        }

        let favsObtained = expectation(description: "Favorites queried")
        ffMock.onGetFavs = {
            favsObtained.fulfill()
            return nil
        }

        let initialValidation = expectation(description: "Initial validation")
        validatorMock.onValidateInitialState = {
            initialValidation.fulfill()
            return true
        }

        let structureValidation = expectation(description: "Structure validation")
        validatorMock.onValidateBookmarksStructure = {
            structureValidation.fulfill()
        }

        let setup = BookmarksDatabaseSetup(migrationAssertion: BookmarksMigrationAssertion(store: MockKeyValueStore()))

        switch setup.loadStoreAndMigrate(bookmarksDatabase: dbMock,
                                         formFactorFavoritesMigrator: ffMock,
                                         validator: validatorMock) {
        case .success:
            break
        case .failure(let error):
            XCTFail("Unexpected error: \(error)")
        }

        wait(for: [storeLoaded, contextPrepared, favsObtained, initialValidation, structureValidation], timeout: 5)
    }

    func testWhenFetchingOldStateFailsThenErrorIsReturned() {

        let dbMock = DummyCoreDataStoreMock()
        dbMock.onLoadStore = { _ in
            XCTFail("Store should not be loaded")
        }
        dbMock.onMakeContext = {
            XCTFail("Context should not be requested")
        }

        let favsObtained = expectation(description: "Favorites queried")
        ffMock.onGetFavs = {
            favsObtained.fulfill()
            throw BookmarksModelError.bookmarkFolderExpected
        }

        validatorMock.onValidateInitialState = {
            XCTFail("Validation should not be called")
            return true
        }

        validatorMock.onValidateBookmarksStructure = {
            XCTFail("Validation should not be called")
        }

        let setup = BookmarksDatabaseSetup(migrationAssertion: BookmarksMigrationAssertion(store: MockKeyValueStore()))

        switch setup.loadStoreAndMigrate(bookmarksDatabase: dbMock,
                                         formFactorFavoritesMigrator: ffMock,
                                         validator: validatorMock) {
        case .success:
            XCTFail("Unexpected")
        case .failure(let error):
            XCTAssertEqual(error as? BookmarksModelError, BookmarksModelError.bookmarkFolderExpected)
        }

        wait(for: [favsObtained], timeout: 5)
    }

    func testWhenLoadingStoreFailsThenErrorIsReturned() {

        let dbMock = DummyCoreDataStoreMock()

        let onLoadStore = expectation(description: "Favorites queried")
        dbMock.onLoadStore = { completion in
            onLoadStore.fulfill()
            completion(nil, BookmarksModelError.bookmarkFolderExpected)
        }
        dbMock.onMakeContext = {
            XCTFail("Context should not be requested")
        }

        let favsObtained = expectation(description: "Favorites queried")
        ffMock.onGetFavs = {
            favsObtained.fulfill()
            return nil
        }

        validatorMock.onValidateInitialState = {
            XCTFail("Validation should not be called")
            return true
        }

        validatorMock.onValidateBookmarksStructure = {
            XCTFail("Validation should not be called")
        }

        let setup = BookmarksDatabaseSetup(migrationAssertion: BookmarksMigrationAssertion(store: MockKeyValueStore()))

        switch setup.loadStoreAndMigrate(bookmarksDatabase: dbMock,
                                         formFactorFavoritesMigrator: ffMock,
                                         validator: validatorMock) {
        case .success:
            XCTFail("Unexpected")
        case .failure(let error):
            XCTAssertEqual(error as? BookmarksModelError, BookmarksModelError.bookmarkFolderExpected)
        }

        wait(for: [onLoadStore, favsObtained], timeout: 5)
    }

}
