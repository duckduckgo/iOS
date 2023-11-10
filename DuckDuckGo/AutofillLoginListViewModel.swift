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

internal enum EnableAutofillRows: Int, CaseIterable {
    case toggleAutofill
    case resetNeverPromptWebsites
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
    private let secureVault: (any AutofillSecureVault)?
    private let autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager
    private var cachedDeletedCredentials: SecureVaultModels.WebsiteCredentials?
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()


    @Published private (set) var viewState: AutofillLoginListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]() {
        didSet {
            updateViewState()
        }
    }

    var hasAccountsSaved: Bool {
        return !accounts.isEmpty
    }
    
    var isAutofillEnabledInSettings: Bool {
        get { appSettings.autofillCredentialsEnabled }
        set {
            appSettings.autofillCredentialsEnabled = newValue
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.autofillEnabledChange, object: self)
        }
    }
    
    init(appSettings: AppSettings, tld: TLD, secureVault: (any AutofillSecureVault)?, currentTabUrl: URL? = nil, autofillNeverPromptWebsitesManager: AutofillNeverPromptWebsitesManager = AppDependencyProvider.shared.autofillNeverPromptWebsitesManager) {
        self.appSettings = appSettings
        self.tld = tld
        self.secureVault = secureVault
        self.currentTabUrl = currentTabUrl
        self.autofillNeverPromptWebsitesManager = autofillNeverPromptWebsitesManager

        updateData()
        authenticationNotRequired = !hasAccountsSaved || AppDependencyProvider.shared.autofillLoginSession.isValidSession
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
        if !authenticator.canAuthenticate() {
            viewState = .noAuthAvailable
            completion(nil)
            return
        }

        if viewState != .authLocked {
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
            return autofillNeverPromptWebsitesManager.neverPromptWebsites.isEmpty ? 1 : 2
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
                if !account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher).lowercased().contains(query.lowercased()) &&
                    !(account.domain ?? "").lowercased().contains(query.lowercased()) &&
                    !(account.username ?? "").lowercased().contains(query.lowercased()) {
                    return false
                }
                return true
            }
        }
        self.sections = makeSections(with: filteredAccounts)
    }

    func resetNeverPromptWebsites() {
        _ = autofillNeverPromptWebsitesManager.deleteAllNeverPromptWebsites()
    }

    // MARK: Private Methods
    
    private func fetchAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let secureVault = secureVault else {
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
        guard let currentUrl = currentTabUrl else {
            return []
        }

        let suggestedAccounts = accounts.filter { account in
            return autofillDomainNameUrlMatcher.isMatchingForAutofill(
                currentSite: currentUrl.absoluteString,
                savedSite: account.domain ?? "",
                tld: tld
            )
        }

        let sortedSuggestions = suggestedAccounts.sorted(by: {
            autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0, rhs: $1, tld: tld) == .orderedAscending
        })

        return sortedSuggestions
    }

    private func makeSections(with accounts: [SecureVaultModels.WebsiteAccount]) -> [AutofillLoginListSectionType] {
        var newSections = [AutofillLoginListSectionType]()

        if !isSearching {
            newSections.append(.enableAutofill)

            if !accountsToSuggest.isEmpty {
                let accountItems = accountsToSuggest.map { AutofillLoginListItemViewModel(account: $0,
                                                                                          tld: tld,
                                                                                          autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                                          autofillDomainNameUrlSort: autofillDomainNameUrlSort)
                }
                newSections.append(.credentials(title: UserText.autofillLoginListSuggested, items: accountItems))
            }
        }

        let viewModelsGroupedByFirstLetter = accounts.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(
                tld: tld,
                autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        let accountSections = viewModelsGroupedByFirstLetter.autofillLoginListSectionsForViewModelsSortedByTitle(autofillDomainNameUrlSort,
                                                                                                                 tld: tld)
        
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

    func tableContentsToDelete(accountId: String?) -> (sectionsToDelete: [Int], rowsToDelete: [IndexPath]) {
        var sectionsToDelete: [Int] = []
        var rowsToDelete: [IndexPath] = []

        for (index, section) in sections.enumerated() {
            if case .credentials(_, let items) = section, items.contains(where: { $0.account.id == accountId }) {
                if items.count == 1 {
                    sectionsToDelete.append(index)
                } else if let rowIndex = items.firstIndex(where: { $0.account.id == accountId }) {
                    rowsToDelete.append(IndexPath(row: rowIndex, section: index))
                }
            }
        }

        return (sectionsToDelete: sectionsToDelete, rowsToDelete: rowsToDelete)
    }

    @discardableResult
    func delete(_ account: SecureVaultModels.WebsiteAccount) -> Bool {
        guard let secureVault = secureVault,
              let accountID = account.id,
              let accountIdInt = Int64(accountID) else { return false }
        
        do {
            cachedDeletedCredentials = try secureVault.websiteCredentialsFor(accountId: accountIdInt)
            try secureVault.deleteWebsiteCredentialsFor(accountId: accountIdInt)
            return true
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            return false
        }
    }
    
    private func undelete(_ account: SecureVaultModels.WebsiteCredentials) {
        guard let secureVault = secureVault,
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
            Pixel.fire(pixel: .secureVaultError, error: error)
        }
    }
}

extension AutofillLoginListItemViewModel: Comparable {
    static func < (lhs: AutofillLoginListItemViewModel, rhs: AutofillLoginListItemViewModel) -> Bool {
        lhs.title < rhs.title
    }
}

internal extension Array where Element == SecureVaultModels.WebsiteAccount {
    
    func autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: TLD,
                                                                        autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher,
                                                                        autofillDomainNameUrlSort: AutofillDomainNameUrlSort)
            -> [String: [AutofillLoginListItemViewModel]] {
        reduce(into: [String: [AutofillLoginListItemViewModel]]()) { result, account in
            
            // Unfortunetly, folding doesn't produce perfect results despite respecting the system locale
            // E.g. Romainian should treat letters with diacritics as seperate letters, but folding doesn't
            // Apple's own apps (e.g. contacts) seem to suffer from the same problem
            let key: String
            if let firstChar = autofillDomainNameUrlSort.firstCharacterForGrouping(account, tld: tld),
               let deDistinctionedChar = String(firstChar).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).first,
               deDistinctionedChar.isLetter {
                
                key = String(deDistinctionedChar)
            } else {
                key = AutofillLoginListSectionType.miscSectionHeading
            }
            
            return result[key, default: []].append(AutofillLoginListItemViewModel(account: account,
                                                                                  tld: tld,
                                                                                  autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                                  autofillDomainNameUrlSort: autofillDomainNameUrlSort))
        }
    }
}

internal extension Dictionary where Key == String, Value == [AutofillLoginListItemViewModel] {
    
    func autofillLoginListSectionsForViewModelsSortedByTitle(_ autofillDomainNameUrlSort: AutofillDomainNameUrlSort, tld: TLD) -> [AutofillLoginListSectionType] {
        map { dictionaryItem -> AutofillLoginListSectionType in
            let sortedGroup = dictionaryItem.value.sorted(by: {
                autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0.account, rhs: $1.account, tld: tld) == .orderedAscending
            })
            return AutofillLoginListSectionType.credentials(title: dictionaryItem.key,
                                                            items: sortedGroup)
        }.sorted()
    }
}
