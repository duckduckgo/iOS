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

public protocol EmailManagerStorage: class {
    func getUsername() -> String?
    func getToken() -> String?
    func getAlias() -> String?
    func store(token: String, username: String)
    func store(alias: String)
    func deleteAlias()
    func deleteAll()
}

public protocol EmailManagerPresentationDelegate: class {
    func emailManager(_ emailManager: EmailManager, didRequestPermissionToProvideAlias alias: String, completionHandler: @escaping (Bool) -> Void)
}

public enum AliasRequestError: Error {
    case networkError
    case signedOut
    case invalidResponse
    case userRefused
}

public typealias AliasCompletion = (String?, AliasRequestError?) -> Void

public class EmailManager {
    
    private static let emailDomain = "duck.com"
    
    private let storage: EmailManagerStorage
    public weak var delegate: EmailManagerPresentationDelegate?
    
    private lazy var appUrls = AppUrls()
    private lazy var aliasAPIURL = appUrls.emailAliasAPI
    
    private var username: String? {
        storage.getUsername()
    }
    private var token: String? {
        storage.getToken()
    }
    private var alias: String? {
        storage.getAlias()
    }
    
    public var isSignedIn: Bool {
        return token != nil && username != nil
    }
    
    public var userEmail: String? {
        guard let username = username else { return nil }
        return username + "@" + EmailManager.emailDomain
    }
    
    public init(storage: EmailManagerStorage = EmailKeychainManager()) {
        self.storage = storage
    }
    
    public func signOut() {
        storage.deleteAll()
        Pixel.fire(pixel: .emailUserSignedOut)
    }
    
    public func getAliasEmailIfNeededAndConsume(timeoutInterval: TimeInterval = 4.0, completionHandler: @escaping AliasCompletion) {
        getAliasEmailIfNeeded(timeoutInterval: timeoutInterval) { [weak self] newAlias, error in
            completionHandler(newAlias, error)
            if error == nil {
                self?.consumeAliasAndReplace()
            }
        }
    }
}

extension EmailManager: EmailUserScriptDelegate {
    public func emailUserScriptDidRequestSignedInStatus(emailUserScript: EmailUserScript) -> Bool {
        isSignedIn
    }
    
    public func emailUserScriptDidRequestAlias(emailUserScript: EmailUserScript, completionHandler: @escaping AliasCompletion) {
        getAliasEmailIfNeeded { [weak self] newAlias, error in
            guard let newAlias = newAlias, error == nil, let self = self else {
                completionHandler(nil, error)
                return
            }
            self.delegate?.emailManager(self, didRequestPermissionToProvideAlias: newAlias) { [weak self] permissionsGranted in
                if permissionsGranted {
                    completionHandler(newAlias, nil)
                    self?.consumeAliasAndReplace()
                } else {
                    completionHandler(nil, .userRefused)
                }
            }
        }
    }
    
    public func emailUserScript(_ emailUserScript: EmailUserScript, didRequestStoreToken token: String, username: String) {
        Pixel.fire(pixel: .emailUserSignedIn)
        storeToken(token, username: username)
    }
}

// Token Management
private extension EmailManager {
    func storeToken(_ token: String, username: String) {
        storage.store(token: token, username: username)
        fetchAndStoreAlias()
    }
}

// Alias managment
private extension EmailManager {
    
    struct EmailAliasResponse: Decodable {
        let address: String
    }
    
    var aliasHeaders: HTTPHeaders {
        guard let token = token else {
            return [:]
        }
        return ["Authorization": "Bearer " + token]
    }
    
    func consumeAliasAndReplace() {
        storage.deleteAlias()
        fetchAndStoreAlias()
    }
    
    func getAliasEmailIfNeeded(timeoutInterval: TimeInterval = 4.0, completionHandler: @escaping AliasCompletion) {
        if let alias = alias {
            completionHandler(emailFromAlias(alias), nil)
            return
        }
        fetchAndStoreAlias(timeoutInterval: timeoutInterval) { [weak self] newAlias, error in
            guard let newAlias = newAlias, error == nil  else {
                completionHandler(nil, error)
                return
            }
            completionHandler(self?.emailFromAlias(newAlias), nil)
        }
    }
    
    func fetchAndStoreAlias(timeoutInterval: TimeInterval = 60.0, completionHandler: AliasCompletion? = nil) {
        fetchAlias(timeoutInterval: timeoutInterval) { [weak self] alias, error in
            guard let alias = alias, error == nil else {
                completionHandler?(nil, error)
                return
            }
            // Check we haven't signed out whilst waiting
            // if so we don't want to save sensitive data
            guard let self = self, self.isSignedIn else {
                completionHandler?(nil, .signedOut)
                return
            }
            self.storage.store(alias: alias)
            completionHandler?(alias, nil)
        }
    }

    func fetchAlias(timeoutInterval: TimeInterval = 60.0, completionHandler: AliasCompletion? = nil) {
        guard isSignedIn else {
            completionHandler?(nil, .signedOut)
            return
        }
        APIRequest.request(url: aliasAPIURL,
                           method: .post,
                           headers: aliasHeaders,
                           timeoutInterval: timeoutInterval) { response, error in
            guard let data = response?.data, error == nil else {
                completionHandler?(nil, .networkError)
                return
            }
            do {
                let decoder = JSONDecoder()
                let alias = try decoder.decode(EmailAliasResponse.self, from: data).address
                Pixel.fire(pixel: .emailAliasGenerated)
                completionHandler?(alias, nil)
            } catch {
                completionHandler?(nil, .invalidResponse)
            }
        }
    }
    
    func emailFromAlias(_ alias: String) -> String {
        return alias + "@" + EmailManager.emailDomain
    }
}
