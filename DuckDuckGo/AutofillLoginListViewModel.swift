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
import Common
import UIKit
import Combine
import os.log
import Core

internal enum AutofillLoginListSectionType: Comparable {
    case enableAutofill
    case credentials(title: String, items: [AutofillLoginListItemViewModel])
    
    static func < (lhs: AutofillLoginListSectionType, rhs: AutofillLoginListSectionType) -> Bool {
        if case .credentials(let leftTitle, _) = lhs,
           case .credentials(let rightTitle, _) = rhs {
            if leftTitle == miscSectionHeading {
                return false
            } else if rightTitle == miscSectionHeading {
                return true
            }
            
            return leftTitle.localizedCaseInsensitiveCompare(rightTitle) == .orderedAscending
        }
        return true
    }
    
    static let miscSectionHeading = "#"
}

final class AutofillLoginListViewModel: ObservableObject {
    
    enum ViewState {
        case authLocked
        case noAuthAvailable
        case empty
        case showItems
        case searching
        case searchingNoResults
    }
    
    let authenticator = AutofillLoginListAuthenticator()
    var isSearching: Bool = false
    var authenticationNotRequired = false
    private var accounts = [SecureVaultModels.WebsiteAccount]()
    private var accountsToSuggest = [SecureVaultModels.WebsiteAccount]()
    private var cancellables: Set<AnyCancellable> = []
    private var appSettings: AppSettings
    private let tld: TLD
    private var currentTabUrl: URL?
    private var cachedDeletedCredentials: SecureVaultModels.WebsiteCredentials?
    
    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]() {
        didSet {
            updateViewState()
        }
    }

    var hasAccountsSaved: Bool {
        return !accounts.isEmpty
    }
    
    var isAutofillEnabled: Bool {
        get { appSettings.autofillCredentialsEnabled }
        set {
            appSettings.autofillCredentialsEnabled = newValue
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.autofillEnabledChange, object: self)
        }
    }
    
    init(appSettings: AppSettings, tld: TLD, currentTabUrl: URL? = nil) {
        self.appSettings = appSettings
        self.tld = tld
        self.currentTabUrl = currentTabUrl
        updateData()
        authenticationNotRequired = !hasAccountsSaved
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
        authenticationNotRequired = !hasAccountsSaved
        authenticator.logOut()
    }
    
    func authenticate(completion: @escaping(AutofillLoginListAuthenticator.AuthError?) -> Void) {
        if viewState != .authLocked && viewState != .noAuthAvailable {
            completion(nil)
            return
        }
        
        authenticator.authenticate(completion: completion)
    }

    func authenticateInvalidateContext() {
        authenticator.invalidateContext()
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
        self.accountsToSuggest = fetchSuggestedAccounts()
        self.sections = makeSections(with: accounts)
    }
    
    func filterData(with query: String? = nil) {
        var filteredAccounts = self.accounts
        
        if let query = query, query.count > 0 {
            filteredAccounts = filteredAccounts.filter { account in
                if !account.name(tld: tld).lowercased().contains(query.lowercased()) &&
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

    private func fetchSuggestedAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let url = currentTabUrl,
              let host = url.host,
              let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else {
            os_log("Failed to make vault")
            return []
        }

        do {
            return try secureVault.accountsFor(domain: host)
        } catch {
            os_log("Failed to fetch suggested accounts")
            return []
        }
    }

    private func makeSections(with accounts: [SecureVaultModels.WebsiteAccount]) -> [AutofillLoginListSectionType] {
        var newSections = [AutofillLoginListSectionType]()

        if !isSearching {
            newSections.append(.enableAutofill)
        }

        if !accountsToSuggest.isEmpty {
            let accountItems = accountsToSuggest.map { AutofillLoginListItemViewModel(account: $0, tld: tld) }
            newSections.append(.credentials(title: UserText.autofillLoginListSuggested, items: accountItems))
        }
        
        let viewModelsGroupedByFirstLetter = accounts.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: tld)
        let accountSections = viewModelsGroupedByFirstLetter.autofillLoginListSectionsForViewModelsSortedByTitle()
        
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
        
        if authenticator.state == .loggedOut && !authenticationNotRequired {
            newViewState = .authLocked
        } else if authenticator.state == .notAvailable {
            newViewState = .noAuthAvailable
        } else if isSearching {
            if sections.count == 0 {
                newViewState = .searchingNoResults
            } else {
                newViewState = .searching
            }
        } else {
            newViewState = sections.count > 1 ? .showItems : .empty
        }
        
        // Avoid unnecessary updates
        if newViewState != viewState {
            viewState = newViewState
        }
    }
    
    @discardableResult
    func delete(_ account: SecureVaultModels.WebsiteAccount) -> Bool {
        guard let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared),
              let accountID = account.id,
              let accountIdInt = Int64(accountID) else { return false }
        
        do {
            cachedDeletedCredentials = try secureVault.websiteCredentialsFor(accountId: accountIdInt)
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountIdInt)
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

internal extension Array where Element == SecureVaultModels.WebsiteAccount {
    
    func autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: TLD) -> [String: [AutofillLoginListItemViewModel]] {
        reduce(into: [String: [AutofillLoginListItemViewModel]]()) { result, account in
            
            // Unfortunetly, folding doesn't produce perfect results despite respecting the system locale
            // E.g. Romainian should treat letters with diacritics as seperate letters, but folding doesn't
            // Apple's own apps (e.g. contacts) seem to suffer from the same problem
            let key: String
            if let firstChar = account.name(tld: tld).first,
               let deDistinctionedChar = String(firstChar).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).first,
               deDistinctionedChar.isLetter {
                
                key = String(deDistinctionedChar)
            } else {
                key = AutofillLoginListSectionType.miscSectionHeading
            }
            
            return result[key, default: []].append(AutofillLoginListItemViewModel(account: account, tld: tld))
        }
    }
}

internal extension Dictionary where Key == String, Value == [AutofillLoginListItemViewModel] {
    
    func autofillLoginListSectionsForViewModelsSortedByTitle() -> [AutofillLoginListSectionType] {
        map { dictionaryItem -> AutofillLoginListSectionType in
            let sortedGroup = dictionaryItem.value.sorted { lhs, rhs in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return AutofillLoginListSectionType.credentials(title: dictionaryItem.key,
                                                            items: sortedGroup)
        }.sorted()
    }
}
