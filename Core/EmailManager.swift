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

public class EmailManager {
    
    //TODO load stored version on init
    public var username: String?
    public var token: String?
    public var alias: String?
    
    var isSignedIn: Bool {
        //return true
        return token != nil && username != nil
    }

    func storeToken(_ token: String, username: String) {
        self.token = token
        self.username = username
        EmailKeychainManager.addToKeychainToken(token, forUsername: username)
        
        fetchAlias()
        EmailKeychainManager.retreiveTokenAndUsernameFromKeychain()
    }
    
    private static let apiAddress = URL(string: "https://quackdev.duckduckgo.com/api/email/addresses")!

    private var headers: HTTPHeaders {
        guard let token = token else {
            return [:]
        }
        return ["Authorization": "Bearer " + token]
    }
    
    struct EmailResponse: Decodable {
        let address: String
    }
        
    func fetchAlias() {
        APIRequest.request(url: EmailManager.apiAddress, method: .post, headers: headers) { response, error in
            guard let data = response?.data, error == nil else {
                print("error fetching alias")
                return
            }
            do {
                let decoder = JSONDecoder()
                self.alias = try decoder.decode(EmailResponse.self, from: data).address
                print(self.alias)
            } catch {
                print("invalid alias response")
                return
            }
        }
    }
}

class EmailKeychainManager {
    
    /*
     Uses just kSecAttrService as the primary key, since we don't want to store
     multiple accounts/tokens at the same time
    */
    private enum EmailKeychainService: String {
        case username = "email.duckduckgo.com.username"
        case token = "email.duckduckgo.com.token"
        case alias = "email.duckduckgo.com.alias"
    }
    
    static func deleteAllKeychainData() {
        deleteKeychainItemWithService(.username)
        deleteKeychainItemWithService(.token)
        deleteKeychainItemWithService(.alias)
    }
    
    //TODO what about alias
    static func addToKeychainToken(_ token: String, forUsername username: String) {
        guard let tokenData = token.data(using: String.Encoding.utf8),
              let usernameData = username.data(using: String.Encoding.utf8) else {
            print("oh no")
            return
        }
        deleteAllKeychainData()
        
        addDataToKeychain(tokenData, withService: .token)
        addDataToKeychain(usernameData, withService: .username)
    }
    
    static func retreiveTokenAndUsernameFromKeychain() -> (String, String)? {
        guard let tokenData = retreiveDataFromKeychain(forService: .token),
              let usernameData = retreiveDataFromKeychain(forService: .username),
              let token = String(data: tokenData, encoding: String.Encoding.utf8),
              let username = String(data: usernameData, encoding: String.Encoding.utf8) else {
            print("oh no")
            return nil
        }
        return (token, username)
    }
    
    private static func deleteKeychainItemWithService(_ service: EmailKeychainService) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue]
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess else {
            print("Keychain error")
            print(deleteStatus)
            return
        }
    }
    
    private static func addDataToKeychain(_ data: Data, withService service: EmailKeychainService) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: false,
            kSecAttrService as String: service.rawValue,
            kSecValueData as String: data]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Keychain error")
            print(status)
            return
        }
    }
    
    private static func retreiveDataFromKeychain(forService service: EmailKeychainService) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrService as String: service.rawValue,
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
