//
//  AutofillLoginListViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import UIKit
import Combine
import os.log
import Core

final class AutofillLoginListViewModel: ObservableObject {
    
    enum AutofillLoginListSectionType: Comparable {
        case enableAutofill
        case credentials(title: String, items: [AutofillLoginListItemViewModel])
        
        static func < (lhs: AutofillLoginListSectionType, rhs: AutofillLoginListSectionType) -> Bool {
            if case .credentials(let left, _) = lhs,
               case .credentials(let right, _) = rhs {
                return left < right
            }
            return true
        }
    }
    enum ViewState {
        case authLocked
        case empty
        case showItems
        case searching
        case searchingNoResults
    }
    
    let authenticator = AutofillLoginListAuthenticator()
    var isSearching: Bool = false
    private var accounts = [SecureVaultModels.WebsiteAccount]()
    private var cancellables: Set<AnyCancellable> = []
    private var appSettings: AppSettings
    private var cachedDeletedCredentials: SecureVaultModels.WebsiteCredentials?
    
    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]() {
        didSet {
            updateViewState()
        }
    }
    
    var isAutofillEnabled: Bool {
        get { appSettings.autofill }
        set {
            appSettings.autofill = newValue
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.autofillEnabledChange, object: self)
        }
    }
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        updateData()
        setupCancellables()
    }
    
 // MARK: Public Methods

    func delete(at indexPath: IndexPath) -> Bool {
        let section = sections[indexPath.section]
        switch section {
        case .credentials(_, let items):
            let item = items[indexPath.row]
            let success = delete(item.account)
            updateData()
            return success
        default:
            break
        }
        return false
    }
    
    func undoLastDelete() {
        guard let cachedDeletedCredentials = cachedDeletedCredentials else {
            return
        }
        undelete(cachedDeletedCredentials)
    }
    
    func clearUndoCache() {
        cachedDeletedCredentials = nil
    }
    
    func lockUI() {
        authenticator.logOut()
    }
    
    func authenticate(completion: @escaping(AutofillLoginListAuthenticator.AuthError?) -> Void) {
        if viewState != .authLocked {
            completion(nil)
            return
        }
        
        authenticator.authenticate(completion: completion)
    }

    func rowsInSection(_ section: Int) -> Int {
        switch self.sections[section] {
        case .enableAutofill:
            return 1
        case .credentials(_, let items):
            return items.count
        }
    }
    
    func updateData() {
        self.accounts = fetchAccounts()
        self.sections = makeSections(with: accounts)
    }
    
    func filterData(with query: String? = nil) {
        var filteredAccounts = self.accounts
        
        if let query = query, query.count > 0 {
            filteredAccounts = filteredAccounts.filter { account in
                if !account.name.lowercased().contains(query.lowercased()) &&
                    !account.domain.lowercased().contains(query.lowercased()) &&
                    !account.username.lowercased().contains(query.lowercased()) {
                    return false
                }
                return true
            }
        }
        self.sections = makeSections(with: filteredAccounts)
    }
    
    
    // MARK: Private Methods
    
    private func fetchAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else {
            os_log("Failed to make vault")
            return []
        }
        
        do {
            return try secureVault.accounts()
        } catch {
            os_log("Failed to fetch accounts")
            return []
        }
    }
    
    private func makeSections(with accounts: [SecureVaultModels.WebsiteAccount]) -> [AutofillLoginListSectionType] {
        var newSections = [AutofillLoginListSectionType]()

        if !isSearching {
            newSections.append(.enableAutofill)
        }
        
        let accountSections = accounts.reduce(into: [:]) { result, account in
            return result[account.name.first?.lowercased() ?? "", default: []].append(AutofillLoginListItemViewModel(account: account))
        }.map { dictionaryItem -> AutofillLoginListSectionType in
            AutofillLoginListSectionType.credentials(title: dictionaryItem.key,
                                                     items: dictionaryItem.value.sorted())
        }.sorted()
        
        newSections.append(contentsOf: accountSections)
        return newSections
    }
    
    private func setupCancellables() {
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateViewState()
            }
            .store(in: &cancellables)
    }
    
    private func updateViewState() {
        var newViewState: AutofillLoginListViewModel.ViewState
        
        if authenticator.state == .loggedOut {
            newViewState = .authLocked
        } else if isSearching {
            if sections.count == 0 {
                newViewState = .searchingNoResults
            } else {
                newViewState = .searching
            }
        } else {
            newViewState = self.sections.count > 1 ? .showItems : .empty
        }
        
        // Avoid unnecessary updates
        if newViewState != viewState {
            viewState = newViewState
        }
    }
    
    @discardableResult
    func delete(_ account: SecureVaultModels.WebsiteAccount) -> Bool {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared),
              let accountID = account.id else { return false }
        
        do {
            cachedDeletedCredentials = try secureVault.websiteCredentialsFor(accountId: accountID)
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountID)
            return true
        } catch {
            Pixel.fire(pixel: .secureVaultError)
            return false
        }
    }
    
    private func undelete(_ account: SecureVaultModels.WebsiteCredentials) {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared),
              var cachedDeletedCredentials = cachedDeletedCredentials else {
            return
        }
        do {
            // We need to make a new account object. If we try to use the old one, secure vault will try to process it as an update, which will fail
            let oldAccount = cachedDeletedCredentials.account
            let newAccount = SecureVaultModels.WebsiteAccount(title: oldAccount.title, username: oldAccount.username, domain: oldAccount.domain)
            cachedDeletedCredentials.account = newAccount
            try secureVault.storeWebsiteCredentials(cachedDeletedCredentials)
            clearUndoCache()
            updateData()
        } catch {
            Pixel.fire(pixel: .secureVaultError)
        }
    }
}

extension AutofillLoginListItemViewModel: Comparable {
    static func < (lhs: AutofillLoginListItemViewModel, rhs: AutofillLoginListItemViewModel) -> Bool {
        lhs.title < rhs.title
    }
}
