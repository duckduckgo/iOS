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

public struct AutofillVaultKeychainMigrator {

    public init() {}

    public func resetVaultMigrationIfRequired(fileManager: FileManager = FileManager.default) {
        let originalVaultLocation = DefaultAutofillDatabaseProvider.defaultDatabaseURL()
        let sharedVaultLocation = DefaultAutofillDatabaseProvider.defaultSharedDatabaseURL()

        // only care about users who have have both the original and migrated vaults
        guard fileManager.fileExists(atPath: originalVaultLocation.path),
              fileManager.fileExists(atPath: sharedVaultLocation.path) else {
            return
        }

        let hasV4Items = hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v4")

        guard hasV4Items else {
            return
        }

        let hasV3Items = hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v3")
        let hasV2Items = hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault v2")
        let hasV1Items = hasKeychainItemsMatching(serviceName: "DuckDuckGo Secure Vault")

        // Only continue if there are original keychain items to migrate from
        guard hasV1Items || hasV2Items || hasV3Items else {
            return
        }

        deleteKeychainItems(matching: "DuckDuckGo Secure Vault v4")
        let backupFilePath = sharedVaultLocation.appendingPathExtension("bak")
        do {
            // Creating a backup of the migrated file
            try fileManager.moveItem(at: sharedVaultLocation, to: backupFilePath)
            Logger.autofill.info("Move migrated file to backup \(backupFilePath.path)")
        } catch {
            Logger.autofill.error("Failed to create backup of migrated file: \(error.localizedDescription)")
            return
        }
    }

    private func hasKeychainItemsMatching(serviceName: String) -> Bool {
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

    private func deleteKeychainItems(matching serviceName: String) {
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
