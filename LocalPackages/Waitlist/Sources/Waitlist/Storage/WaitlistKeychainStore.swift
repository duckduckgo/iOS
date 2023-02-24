//
//  WaitlistKeychainStore.swift
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

public class WaitlistKeychainStore: WaitlistStorage {

    public static let inviteCodeDidChangeNotification = Notification.Name("com.duckduckgo.app.waitlist.invite-code-changed")

    public enum WaitlistKeychainField: String {
        case waitlistToken = "token"
        case waitlistTimestamp = "timestamp"
        case inviteCode = "invite-code"
    }


    public init(waitlistIdentifier: String, keychainPrefix: String? = Bundle.main.bundleIdentifier) {
        self.waitlistIdentifier = waitlistIdentifier
        self.keychainPrefix = keychainPrefix ?? "com.duckduckgo"
    }

    public func getWaitlistToken() -> String? {
        return getString(forField: .waitlistToken)
    }

    public func getWaitlistTimestamp() -> Int? {
        guard let timestampString = getString(forField: .waitlistTimestamp) else { return nil }
        return Int(timestampString)
    }

    public func getWaitlistInviteCode() -> String? {
        return getString(forField: .inviteCode)
    }

    public func store(waitlistToken: String) {
        add(string: waitlistToken, forField: .waitlistToken)
    }

    public func store(waitlistTimestamp: Int) {
        let timestampString = String(waitlistTimestamp)
        add(string: timestampString, forField: .waitlistTimestamp)
    }

    public func store(inviteCode: String) {
        add(string: inviteCode, forField: .inviteCode)
        NotificationCenter.default.post(name: Self.inviteCodeDidChangeNotification, object: waitlistIdentifier)
    }

    public func deleteWaitlistState() {
        deleteItem(forField: .waitlistToken)
        deleteItem(forField: .waitlistTimestamp)
        deleteItem(forField: .inviteCode)
    }

    public func delete(field: WaitlistKeychainField) {
        deleteItem(forField: field)
    }

    // MARK: - Keychain Read

    private func getString(forField field: WaitlistKeychainField) -> String? {
        guard let data = retrieveData(forField: field),
              let string = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        return string
    }

    private func retrieveData(forField field: WaitlistKeychainField) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrService as String: keychainServiceName(for: field),
            kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let existingItem = item as? Data else {
            return nil
        }

        return existingItem
    }

    // MARK: - Keychain Write

    private func add(string: String, forField field: WaitlistKeychainField) {
        guard let stringData = string.data(using: .utf8) else {
            return
        }

        deleteItem(forField: field)
        add(data: stringData, forField: field)
    }

    private func add(data: Data, forField field: WaitlistKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: false,
            kSecAttrService as String: keychainServiceName(for: field),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: data]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func deleteItem(forField field: WaitlistKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServiceName(for: field)]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: -

    internal func keychainServiceName(for field: WaitlistKeychainField) -> String {
        [keychainPrefix, "waitlist", waitlistIdentifier, field.rawValue].joined(separator: ".")
    }

    private let waitlistIdentifier: String
    private let keychainPrefix: String
}
