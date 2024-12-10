//
//  CredentialProviderListViewModel.swift
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
import AuthenticationServices
import BrowserServicesKit
import Combine
import Common
import Core
import os.log

final class CredentialProviderListViewModel: ObservableObject {

    enum ViewState {
        case authLocked
        case noAuthAvailable
        case empty
        case showItems
        case searching
        case searchingNoResults
    }

    var isSearching: Bool = false {
        didSet {
            if oldValue != isSearching, isSearching {
                Pixel.fire(pixel: .autofillExtensionPasswordsSearch)
            }
        }
    }
    var authenticationNotRequired = false

    private let serviceIdentifiers: [ASCredentialServiceIdentifier]
    private let secureVault: (any AutofillSecureVault)?
    private let credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging
    private var accounts = [SecureVaultModels.WebsiteAccount]()
    private var accountsToSuggest = [SecureVaultModels.WebsiteAccount]()
    private var cancellables: Set<AnyCancellable> = []
    private let tld: TLD
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()

    let authenticator = UserAuthenticator(reason: UserText.credentialProviderListAuthenticationReason,
                                          cancelTitle: UserText.credentialProviderListAuthenticationCancelButton)
    var hasAccountsSaved: Bool {
        return !accounts.isEmpty
    }

    var serviceIdentifierPromptLabel: String? {
        guard let identifier = serviceIdentifiers.first?.identifier else {
            return nil
        }
        return String(format: UserText.credentialProviderListPrompt, autofillDomainNameUrlMatcher.normalizeUrlForWeb(identifier))
    }

    @Published private(set) var viewState: CredentialProviderListViewModel.ViewState = .authLocked
    @Published private(set) var sections = [AutofillLoginListSectionType]() {
        didSet {
            updateViewState()
        }
    }

    init(serviceIdentifiers: [ASCredentialServiceIdentifier],
         secureVault: (any AutofillSecureVault)?,
         credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging,
         tld: TLD) {
        self.serviceIdentifiers = serviceIdentifiers
        self.secureVault = secureVault
        self.credentialIdentityStoreManager = credentialIdentityStoreManager
        self.tld = tld

        if let count = getAccountsCount() {
            authenticationNotRequired = count == 0
        }
        updateData()
        setupCancellables()
    }

    private func getAccountsCount() -> Int? {
        guard let secureVault = secureVault else {
            return nil
        }

        do {
            return try secureVault.accountsCount()
        } catch {
            return nil
        }
    }

    private func fetchAccounts() -> [SecureVaultModels.WebsiteAccount] {
        guard let secureVault = secureVault else {
            return []
        }

        do {
            let allAccounts = try secureVault.accounts()
            return allAccounts
        } catch {
            Logger.autofill.error("Failed to fetch accounts \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    func updateData() {
        self.accounts = fetchAccounts()
        self.accountsToSuggest = fetchSuggestedAccounts()
        self.sections = makeSections(with: accounts)

        Task {
            await credentialIdentityStoreManager.replaceCredentialStore(with: accounts)
        }
    }

    private func setupCancellables() {
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateViewState()
            }
            .store(in: &cancellables)
    }

    func authenticate(completion: @escaping (UserAuthenticator.AuthError?) -> Void) {
        if !authenticator.canAuthenticate() {
            viewState = .noAuthAvailable
            completion(.noAuthAvailable)
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

    private func fetchSuggestedAccounts() -> [SecureVaultModels.WebsiteAccount] {

        var suggestedAccounts = [SecureVaultModels.WebsiteAccount]()

        serviceIdentifiers.compactMap { URL(string: $0.identifier) }.forEach { url in
            suggestedAccounts += accounts.filter { account in
                return autofillDomainNameUrlMatcher.isMatchingForAutofill(
                    currentSite: url.absoluteString,
                    savedSite: account.domain ?? "",
                    tld: tld
                )
            }
        }

        let sortedSuggestions = suggestedAccounts.sorted(by: {
            autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0, rhs: $1, tld: tld) == .orderedAscending
        })

        return sortedSuggestions
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

    func rowsInSection(_ section: Int) -> Int {
        switch self.sections[section] {
        case .suggestions(_, let items):
            return items.count
        case .credentials(_, let items):
            return items.count
        default:
            return 0
        }
    }

    private func makeSections(with accounts: [SecureVaultModels.WebsiteAccount]) -> [AutofillLoginListSectionType] {
        var newSections = [AutofillLoginListSectionType]()

        if !isSearching && !accountsToSuggest.isEmpty {
            let accountItems = accountsToSuggest.map { AutofillLoginItem(account: $0,
                                                                         tld: tld,
                                                                         autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                         autofillDomainNameUrlSort: autofillDomainNameUrlSort)
            }
            newSections.append(.suggestions(title: UserText.credentialProviderListSuggested, items: accountItems))
        }

        let viewModelsGroupedByFirstLetter = accounts.groupedByFirstLetter(
            tld: tld,
            autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
            autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        let accountSections = viewModelsGroupedByFirstLetter.sortedIntoSections(autofillDomainNameUrlSort,
                                                                                tld: tld)

        newSections.append(contentsOf: accountSections)
        return newSections
    }

    private func updateViewState() {
        var newViewState: CredentialProviderListViewModel.ViewState

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
            newViewState = sections.count > 0 ? .showItems : .empty
        }


        // Avoid unnecessary updates
        if newViewState != viewState {
            viewState = newViewState
        }
    }

}
