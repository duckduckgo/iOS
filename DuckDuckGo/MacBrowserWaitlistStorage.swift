//
//  MacBrowserWaitlistStorage.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import Core

protocol MacBrowserWaitlistStorage {
    
    func getWaitlistToken() -> String?
    func getWaitlistTimestamp() -> Int?
    func getWaitlistInviteCode() -> String?

    func store(waitlistToken: String)
    func store(waitlistTimestamp: Int)
    func store(inviteCode: String)

    func deleteWaitlistState()

}

extension MacBrowserWaitlistStorage {
    
    var isOnWaitlist: Bool {
        return getWaitlistToken() != nil && getWaitlistTimestamp() != nil && !isInvited
    }
    
    var isInvited: Bool {
        return getWaitlistInviteCode() != nil
    }
    
}

class MacBrowserWaitlistKeychainStore: MacBrowserWaitlistStorage {
    
    enum MacWaitlistKeychainField: String {
        case waitlistToken = ".waitlist.mac.token"
        case waitlistTimestamp = ".waitlist.mac.timestamp"
        case inviteCode = ".waitlist.mac.invite-code"
        
        var keyValue: String {
            (Bundle.main.bundleIdentifier ?? "com.duckduckgo") + rawValue
        }
    }
    
    func getWaitlistToken() -> String? {
        return getString(forField: .waitlistToken)
    }

    func getWaitlistTimestamp() -> Int? {
        guard let timestampString = getString(forField: .waitlistTimestamp) else { return nil }
        return Int(timestampString)
    }
    
    func getWaitlistInviteCode() -> String? {
        return getString(forField: .inviteCode)
    }

    func store(waitlistToken: String) {
        add(string: waitlistToken, forField: .waitlistToken)
    }
    
    func store(waitlistTimestamp: Int) {
        let timestampString = String(waitlistTimestamp)
        add(string: timestampString, forField: .waitlistTimestamp)
    }
    
    func store(inviteCode: String) {
        add(string: inviteCode, forField: .inviteCode)
        NotificationCenter.default.post(name: MacBrowserWaitlist.Notifications.inviteCodeChanged, object: nil)
    }

    func deleteWaitlistState() {
        deleteItem(forField: .waitlistToken)
        deleteItem(forField: .waitlistTimestamp)
        deleteItem(forField: .inviteCode)
    }
    
    func delete(field: MacWaitlistKeychainField) {
        deleteItem(forField: field)
    }
    
    // MARK: - Keychain Read
    
    private func getString(forField field: MacWaitlistKeychainField) -> String? {
        guard let data = retrieveData(forField: field),
              let string = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        return string
    }
    
    private func retrieveData(forField field: MacWaitlistKeychainField) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrService as String: field.keyValue,
            kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let existingItem = item as? Data else {
            return nil
        }

        return existingItem
    }
    
    // MARK: - Keychain Write
    
    private func add(string: String, forField field: MacWaitlistKeychainField) {
        guard let stringData = string.data(using: .utf8) else {
            return
        }

        deleteItem(forField: field)
        add(data: stringData, forField: field)
    }
    
    private func add(data: Data, forField field: MacWaitlistKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: false,
            kSecAttrService as String: field.keyValue,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: data]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func deleteItem(forField field: MacWaitlistKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: field.keyValue]
        SecItemDelete(query as CFDictionary)
    }
    
}
