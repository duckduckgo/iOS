//
//  AutofillVaultKeychainMigrator.swift
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
import BrowserServicesKit
import os.log
import Persistence
import GRDB
import SecureStorage

public protocol AutofillKeychainService {
    func hasKeychainItemsMatching(serviceName: String) -> Bool
    func deleteKeychainItems(matching serviceName: String)
}

public struct DefaultAutofillKeychainService: AutofillKeychainService {

    public init() {}

    public func hasKeychainItemsMatching(serviceName: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let items = result as? [[String: Any]] {
            for item in items {
                if let service = item[kSecAttrService as String] as? String,
                   service.lowercased() == serviceName.lowercased() {
                    Logger.autofill.debug("Found keychain items matching service name: \(serviceName)")
                    return true
                }
            }
        }

        return false
    }

    public func deleteKeychainItems(matching serviceName: String) {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]

        let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
        if deleteStatus == errSecSuccess {
            Logger.autofill.debug("Deleted keychain item: \(serviceName)")
        } else {
            Logger.autofill.debug("Failed to delete keychain item: \(serviceName), error: \(deleteStatus)")
        }
    }
}

public class AutofillVaultKeychainMigrator {

    internal let keychainService: AutofillKeychainService

    private let store: KeyValueStoring

    @UserDefaultsWrapper(key: .autofillVaultMigrated, defaultValue: false)
    var wasVaultMigrated: Bool

    private var vaultMigrated: Bool {
        get {
            return (store.object(forKey: UserDefaultsWrapper<Bool>.Key.autofillVaultMigrated.rawValue) as? Bool) ?? false
        }
        set {
            store.set(newValue, forKey: UserDefaultsWrapper<Bool>.Key.autofillVaultMigrated.rawValue)
        }
    }

    public init(keychainService: AutofillKeychainService = DefaultAutofillKeychainService(), store: KeyValueStoring = UserDefaults.app) {
        self.keychainService = keychainService
        self.store = store
    }

    public func resetVaultMigrationIfRequired(fileManager: FileManager = FileManager.default) {
        guard !vaultMigrated else {
            return
        }

        let originalVaultLocation = DefaultAutofillDatabaseProvider.defaultDatabaseURL()
        let sharedVaultLocation = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL()
        let hasV4Items = keychainService.hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v4")

        // only care about users who have have both the original and migrated vaults, as well as v4 keychain items
        guard fileManager.fileExists(atPath: originalVaultLocation.path),
              fileManager.fileExists(atPath: sharedVaultLocation.path),
              hasV4Items else {
            vaultMigrated = true
            return
        }

        let hasV3Items = keychainService.hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v3")
        let hasV2Items = keychainService.hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v2")
        let hasV1Items = keychainService.hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault")

        // Only continue if there are original keychain items to migrate from
        guard hasV1Items || hasV2Items || hasV3Items else {
            vaultMigrated = true
            return
        }

        let backupFilePath = sharedVaultLocation.appendingPathExtension("bak")
        do {
            // only complete the migration if the shared database is empty
            let databaseIsEmpty = try databaseIsEmpty(at: sharedVaultLocation)
            if !databaseIsEmpty {
                Pixel.fire(pixel: .secureVaultV4MigrationSkipped)
            } else {
                // Creating a backup of the migrated file
                try fileManager.moveItem(at: sharedVaultLocation, to: backupFilePath)
                keychainService.deleteKeychainItems(matching: "DuckDuckGo Secure Vault v4")
                Pixel.fire(pixel: .secureVaultV4Migration)
            }
            wasVaultMigrated = true
        } catch {
            Logger.autofill.error("Failed to create backup of migrated file: \(error.localizedDescription)")
            return
        }
    }

    internal func databaseIsEmpty(at url: URL) throws -> Bool {
        let keyStoreProvider: SecureStorageKeyStoreProvider = AutofillSecureVaultFactory.makeKeyStoreProvider(nil)
        guard let existingL1Key = try keyStoreProvider.l1Key() else {
            return false
        }

        var config = Configuration()
        config.prepareDatabase {
            try $0.usePassphrase(existingL1Key)
        }

        let dbQueue = try DatabaseQueue(path: url.path, configuration: config)

        try dbQueue.write { db in
            try db.usePassphrase(existingL1Key)
        }

        let isEmpty = try dbQueue.read { db in
            // Find all user-created tables (excluding system tables)
            let tableNames = try Row.fetchAll(
                db,
                sql: """
                SELECT name
                FROM sqlite_master
                WHERE type='table'
                  AND name NOT LIKE 'sqlite_%'
                """
            ).map { row -> String in
                row["name"]
            }

            // No user tables at all -> definitely empty
            if tableNames.isEmpty {
                return true
            }

            // Check each table for rows
            for table in tableNames {
                if table == "grdb_migrations" {
                    continue
                }

                let rowCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0
                if rowCount > 0 {
                    // Found data in at least one table -> not empty
                    return false
                }
            }

            // There's at least one user table, but all are empty
            return true
        }

        return isEmpty
    }

}
