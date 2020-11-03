//
//  EmailKeyChainManager.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

public class EmailKeychainManager {
    public init() {}
}

extension EmailKeychainManager: EmailManagerStorage {
    public func getUsername() -> String? {
        EmailKeychainManager.getString(forField: .username)
    }
    
    public func getToken() -> String? {
        EmailKeychainManager.getString(forField: .token)
    }
    
    public func getAlias() -> String? {
        EmailKeychainManager.getString(forField: .alias)
    }
    
    public func store(token: String, username: String) {
        EmailKeychainManager.add(token: token, forUsername: username)
    }
    
    public func store(alias: String) {
        EmailKeychainManager.add(alias: alias)
    }
    
    public func deleteAlias() {
        EmailKeychainManager.deleteItem(forField: .alias)
    }
    
    public func deleteAll() {
        EmailKeychainManager.deleteAll()
    }
}

private extension EmailKeychainManager {
    
    /*
     Uses just kSecAttrService as the primary key, since we don't want to store
     multiple accounts/tokens at the same time
    */
    enum EmailKeychainField: String {
        case username = "email.duckduckgo.com.username"
        case token = "email.duckduckgo.com.token"
        case alias = "email.duckduckgo.com.alias"
    }
    
    static func getString(forField field: EmailKeychainField) -> String? {
        guard let data = retreiveData(forField: field),
              let string = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        return string
    }
    
    static func retreiveData(forField field: EmailKeychainField) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrService as String: field.rawValue,
            kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let existingItem = item as? Data else {
            return nil
        }

        return existingItem
    }
    
    static func add(token: String, forUsername username: String) {
        guard let tokenData = token.data(using: String.Encoding.utf8),
              let usernameData = username.data(using: String.Encoding.utf8) else {
            return
        }
        deleteAll()
        
        add(data: tokenData, forField: .token)
        add(data: usernameData, forField: .username)
    }
    
    static func add(alias: String) {
        guard let aliasData = alias.data(using: String.Encoding.utf8) else {
            return
        }
        deleteItem(forField: .alias)
        add(data: aliasData, forField: .alias)
    }
    
    static func add(data: Data, forField field: EmailKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: false,
            kSecAttrService as String: field.rawValue,
            kSecValueData as String: data]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func deleteAll() {
        deleteItem(forField: .username)
        deleteItem(forField: .token)
        deleteItem(forField: .alias)
    }
    
    static func deleteItem(forField field: EmailKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: field.rawValue]
        SecItemDelete(query as CFDictionary)
    }
}
