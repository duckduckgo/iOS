//
//  EmailManager.swift
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

import WebKit

private struct EmailAliasResponse: Decodable {
    let address: String
}

public class EmailManager {
    
    //todo these can probably be private once we're done testing
    public var username: String? {
        EmailKeychainManager.getStringFromKeychain(forField: .username)
    }
    public var token: String? {
        EmailKeychainManager.getStringFromKeychain(forField: .token)
    }
    private var alias: String? {
        EmailKeychainManager.getStringFromKeychain(forField: .alias)
    }
    
    public var isSignedIn: Bool {
        return token != nil && username != nil
    }
    
    public var userEmail: String? {
        guard let username = username else { return nil }
        return username + "@" + EmailManager.emailDomain
    }
    
    public init() {
    }
    
    public func signOut() {
        EmailKeychainManager.deleteAllKeychainData()
    }

    func storeToken(_ token: String, username: String) {
        EmailKeychainManager.addToKeychain(token: token, forUsername: username)
        fetchAndStoreAlias()
    }
    //TODO settings action should copy to clipboard and notify user
    //"Reference UI that we use for Fireproof - Alerts and CTAs doc in Figma"
    private static let apiAddress = URL(string: "https://quackdev.duckduckgo.com/api/email/addresses")!
    
    private static let emailDomain = "duck.com"

    private var headers: HTTPHeaders {
        guard let token = token else {
            return [:]
        }
        return ["Authorization": "Bearer " + token]
    }
    
    //TODO general error handling
    //TODO should guard that we're actually signed in
    
    public func getAliasEmailIfNeededAndConsume(timeoutInterval: TimeInterval = 5.0, completionHandler: @escaping (String?) -> Void) {
        if let alias = alias {
            completionHandler(emailFromAlias(alias))
            consumeAliasAndReplace()
            return
        }
        fetchAndStoreAlias(timeoutInterval: timeoutInterval) { [weak self] newAlias in
            if let newAlias = newAlias {
                completionHandler(self?.emailFromAlias(newAlias))
                self?.consumeAliasAndReplace()
            }
            completionHandler(newAlias)
        }
    }
    
    func fetchAndStoreAlias(timeoutInterval: TimeInterval = 60.0, completionHandler: ((String?) -> Void)? = nil) {
        fetchAlias(timeoutInterval: timeoutInterval) { alias in
            guard let alias = alias else {
                //todo error handling
                print("oh no")
                completionHandler?(nil)
                return
            }
            EmailKeychainManager.addToKeychain(alias: alias)
            completionHandler?(alias)
        }
    }
    
    private func consumeAliasAndReplace() {
        EmailKeychainManager.deleteFromKeychainAlias()
        fetchAndStoreAlias()
    }
        
    private func fetchAlias(timeoutInterval: TimeInterval = 60.0, completionHandler: ((String?) -> Void)? = nil) {
        APIRequest.request(url: EmailManager.apiAddress, method: .post, headers: headers, timeoutInterval: timeoutInterval) { response, error in
            guard let data = response?.data, error == nil else {
                //TODO getting an error here, need to investigate
                print("error fetching alias")
                completionHandler?(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let alias = try decoder.decode(EmailAliasResponse.self, from: data).address
                completionHandler?(alias)
            } catch {
                print("invalid alias response")
                completionHandler?(nil)
            }
        }
    }
    
    private func emailFromAlias(_ alias: String) -> String {
        return alias + "@" + EmailManager.emailDomain
    }
}

//TODO might want a generic storage protocol and abstract this away...
class EmailKeychainManager {
    
    /*
     Uses just kSecAttrService as the primary key, since we don't want to store
     multiple accounts/tokens at the same time
    */
    enum EmailKeychainField: String {
        case username = "email.duckduckgo.com.username"
        case token = "email.duckduckgo.com.token"
        case alias = "email.duckduckgo.com.alias"
    }
    
    static func deleteAllKeychainData() {
        deleteKeychainItem(forField: .username)
        deleteKeychainItem(forField: .token)
        deleteKeychainItem(forField: .alias)
    }
    
    static func addToKeychain(token: String, forUsername username: String) {
        guard let tokenData = token.data(using: String.Encoding.utf8),
              let usernameData = username.data(using: String.Encoding.utf8) else {
            print("oh no")
            return
        }
        deleteAllKeychainData()
        
        addDataToKeychain(tokenData, forField: .token)
        addDataToKeychain(usernameData, forField: .username)
    }
    
    static func addToKeychain(alias: String) {
        guard let aliasData = alias.data(using: String.Encoding.utf8) else {
            print("oh no")
            return
        }
        deleteKeychainItem(forField: .alias)
        addDataToKeychain(aliasData, forField: .alias)
    }
    
    static func deleteFromKeychainAlias() {
        deleteKeychainItem(forField: .alias)
    }
    
    static func getStringFromKeychain(forField field: EmailKeychainField) -> String? {
        guard let data = retreiveDataFromKeychain(forField: field),
              let string = String(data: data, encoding: String.Encoding.utf8) else {
            print("oh no")
            return nil
        }
        return string
    }
    
    private static func deleteKeychainItem(forField field: EmailKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: field.rawValue]
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess else {
            print("Keychain error")
            print(deleteStatus)
            return
        }
    }
    
    private static func addDataToKeychain(_ data: Data, forField field: EmailKeychainField) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: false,
            kSecAttrService as String: field.rawValue,
            kSecValueData as String: data]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Keychain error")
            print(status)
            return
        }
    }
    
    private static func retreiveDataFromKeychain(forField field: EmailKeychainField) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrService as String: field.rawValue,
            kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            print("Keychain error: item not found")
            print(status)
            return nil
        }
        guard status == errSecSuccess else {
            print("Keychain error")
            print(status)
            return nil
        }
        
        guard let existingItem = item as? Data else {
            print("oh no")
            return nil
        }
        return existingItem
    }
}
