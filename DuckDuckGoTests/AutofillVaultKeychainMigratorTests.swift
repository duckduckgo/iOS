//
//  AutofillVaultKeychainMigratorTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import XCTest
@testable import Core
import BrowserServicesKit
import PersistenceTestingUtils

final class AutofillVaultKeychainMigratorTests: XCTestCase {

    private var mockKeychain: MockKeychainService!
    private var mockFileManager: MockFileManager!
    private var mockStore: MockKeyValueStore!
    private var migrator: TestableAutofillVaultKeychainMigrator!
    private let autofillVaultMigratedKey = "com.duckduckgo.app.autofill.VaultMigrated"

    override func setUpWithError() throws {
        super.setUp()
        mockKeychain = MockKeychainService()
        mockFileManager = MockFileManager()
        mockStore = MockKeyValueStore()

        // Create a testable migrator that overrides databaseIsEmpty
        migrator = TestableAutofillVaultKeychainMigrator(
            keychainService: mockKeychain,
            store: mockStore
        )
    }

    override func tearDownWithError() throws {
        migrator = nil
        mockStore.clearAll()
        mockStore = nil
        mockFileManager = nil
        mockKeychain = nil

        try super.tearDownWithError()
    }

    func testSkipsIfAlreadyMigrated() {
        // Mark vault as already migrated
        mockStore.set(true, forKey: autofillVaultMigratedKey)

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        // Because vault was already migrated, we skip everything
        XCTAssertFalse(mockFileManager.didMoveItem, "Should not move files if already migrated")
        XCTAssertTrue(mockKeychain.deletedServices.isEmpty, "Should not delete keychain items if already migrated")
    }

    func testSetsVaultMigratedToTrueIfOriginalMissing() {
        // Arrange:
        // Suppose only shared vault exists
        let sharedPath   = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL().path
        mockFileManager.existingPaths = [sharedPath] // Missing the original vault

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        let migratedValue = mockStore.object(forKey: autofillVaultMigratedKey) as? Bool
        XCTAssertTrue(migratedValue == true, "Migrator should set wasVaultMigrated = true if original is missing")
    }

    func testSetsVaultMigratedToTrueIfSharedMissing() {
        // Suppose only original vault exists
        let originalPath = DefaultAutofillDatabaseProvider.defaultDatabaseURL().path
        mockFileManager.existingPaths = [originalPath] // Missing the shared vault

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        let migratedValue = mockStore.object(forKey: autofillVaultMigratedKey) as? Bool
        XCTAssertTrue(migratedValue == true, "Migrator should set wasVaultMigrated = true if shared is missing")
    }

    func testSetsVaultMigratedToTrueIfNoV4Items() {
        // Both vaults exist but no V4 items in keychain
        let originalPath = DefaultAutofillDatabaseProvider.defaultDatabaseURL().path
        let sharedPath = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL().path
        mockFileManager.existingPaths = [originalPath, sharedPath]

        // Simulate no v4 items
        mockKeychain.servicesWithItems = ["DuckDuckGo Secure Vault v3"] // just v3, no v4

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        let migratedValue = mockStore.object(forKey: autofillVaultMigratedKey) as? Bool
        XCTAssertTrue(migratedValue == true, "Migrator should set wasVaultMigrated = true if v4 items not found")
    }

    func testSkipsIfNoOriginalKeychainItems() {
        // We have v4 items, but no v1/v2/v3 items
        let originalPath = DefaultAutofillDatabaseProvider.defaultDatabaseURL().path
        let sharedPath = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL().path
        mockFileManager.existingPaths = [originalPath, sharedPath]

        // v4 exists, but no older items
        mockKeychain.servicesWithItems = ["DuckDuckGo Secure Vault v4"]

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        // No file move, no keychain deletion, wasVaultMigrated should remain false if we read it
        XCTAssertFalse(mockFileManager.didMoveItem, "Should not move item if no original keychain items")
        XCTAssertTrue(mockKeychain.deletedServices.isEmpty, "Should not delete any keychain service if no older items exist")

        let migratedValue = mockStore.object(forKey: autofillVaultMigratedKey) as? Bool
        XCTAssertTrue(migratedValue == true, "Migrator should set wasVaultMigrated = true if no v1/v2/v3 items items found")
    }

    func testSkipsIfDatabaseIsNotEmpty() {
        // We have original and shared vaults, plus v4 items, plus older items
        let originalPath = DefaultAutofillDatabaseProvider.defaultDatabaseURL().path
        let sharedPath = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL().path
        mockFileManager.existingPaths = [originalPath, sharedPath]

        // Keychain has both v4 and older items
        mockKeychain.servicesWithItems = [
            "DuckDuckGo Secure Vault v4",
            "DuckDuckGo Secure Vault v3"
        ]

        // Simulate the "database is NOT empty" to cause skipping
        migrator.databaseIsEmptyReturnValue = false

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        // The code checks the DB, sees it’s not empty, logs and sets wasVaultMigrated = true,
        // but does NOT move or delete the v4 items.
        XCTAssertFalse(mockFileManager.didMoveItem, "Should not move item if DB is not empty")
        XCTAssertTrue(mockKeychain.deletedServices.isEmpty, "Should not delete if DB is not empty")
    }

    func testDeletesV4AndMovesFileIfDatabaseIsEmpty() {
        // Arrange: Both vaults exist, v4 + older items exist
        let originalPath = DefaultAutofillDatabaseProvider.defaultDatabaseURL().path
        let sharedPath   = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL().path
        mockFileManager.existingPaths = [originalPath, sharedPath]

        // Keychain has v4 and older items
        mockKeychain.servicesWithItems = [
            "DuckDuckGo Secure Vault v4",
            "DuckDuckGo Secure Vault v2"
        ]

        // Simulate the DB is empty
        migrator.databaseIsEmptyReturnValue = true

        migrator.resetVaultMigrationIfRequired(fileManager: mockFileManager)

        XCTAssertTrue(mockFileManager.didMoveItem, "Should move the shared vault file to .bak if DB is empty")
        XCTAssertEqual(mockKeychain.deletedServices, ["DuckDuckGo Secure Vault v4"], "Should delete v4 items")
    }

}

private class MockKeychainService: AutofillKeychainService {

    var servicesWithItems: Set<String> = []
    var deletedServices: [String] = []

    func hasKeychainItemsMatching(serviceName: String) -> Bool {
        return servicesWithItems.contains(serviceName)
    }

    func deleteKeychainItems(matching serviceName: String) {
        deletedServices.append(serviceName)
        // Simulate that they no longer exist
        servicesWithItems.remove(serviceName)
    }
}

private class MockFileManager: FileManager {

    var existingPaths = Set<String>()

    var didMoveItem = false
    var movedFromPath: String?
    var movedToPath: String?

    override func fileExists(atPath path: String) -> Bool {
        return existingPaths.contains(path)
    }

    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        didMoveItem = true
        movedFromPath = srcURL.path
        movedToPath = dstURL.path
        // In a real test double, you might simulate an error if you want to test error paths
    }
}

private class TestableAutofillVaultKeychainMigrator: AutofillVaultKeychainMigrator {

    var databaseIsEmptyReturnValue: Bool = true
    var databaseIsEmptyCalledCount = 0

    override func databaseIsEmpty(at url: URL) throws -> Bool {
        databaseIsEmptyCalledCount += 1
        return databaseIsEmptyReturnValue
    }
}
