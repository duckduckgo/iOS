//
//  AutofillLoginPromptViewModel.swift
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
import UIKit
import BrowserServicesKit

protocol AutofillLoginPromptViewModelDelegate: AnyObject {
    func autofillLoginPromptViewModel(_ viewModel: AutofillLoginPromptViewModel, didSelectAccount account: SecureVaultModels.WebsiteAccount)
    func autofillLoginPromptViewModelDidCancel(_ viewModel: AutofillLoginPromptViewModel)
    func autofillLoginPromptViewModelDidRequestExpansion(_ viewModel: AutofillLoginPromptViewModel)
    func autofillLoginPromptViewModelDidResizeContent(_ viewModel: AutofillLoginPromptViewModel, contentHeight: CGFloat)
}

struct AccountMatchesViewModel {
    let accounts: [AccountViewModel]
    let isPerfectMatch: Bool

    var title: String {
        if isPerfectMatch {
            return UserText.autofillLoginPromptExactMatchTitle
        } else {
            let domain = accounts.first?.account.domain ?? ""
            return UserText.autofillLoginPromptPartialMatchTitle(for: domain)
        }
    }
}

struct AccountViewModel: Hashable {
    
    let account: SecureVaultModels.WebsiteAccount
    var displayString: String {
        if let username = account.username, username.count > 0 {
            return AutofillInterfaceEmailTruncator.truncateEmail(username, maxLength: 36)
        } else {
            return UserText.autofillLoginPromptPasswordButtonTitle(for: account.domain ?? "")
        }
    }
    
    static func == (lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        return lhs.account.id == rhs.account.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account.id)
    }
}

class AutofillLoginPromptViewModel: ObservableObject {

    weak var delegate: AutofillLoginPromptViewModelDelegate?
    
    @Published var accountMatchesViewModels: [AccountMatchesViewModel] = []
    @Published var showMoreOptions = false
    @Published var shouldUseScrollView = false

    var containsPartialMatches: Bool {
        return accounts.partialMatches.count > 0
    }

    private(set) var domain: String
    private var accounts: AccountMatches

    private(set) var expanded = false {
        didSet {
            setUpAccountsViewModels(accounts: accounts)
        }
    }

    var contentHeight: CGFloat = AutofillViews.loginPromptMinHeight {
        didSet {
            guard contentHeight != oldValue, contentHeight > 0 else { return }
            delegate?.autofillLoginPromptViewModelDidResizeContent(self, contentHeight: max(contentHeight, AutofillViews.loginPromptMinHeight))
        }
    }
    
    let message = UserText.autofillLoginPromptTitle
    let moreOptionsButtonString = UserText.autofillLoginPromptMoreOptions
    
    internal init(accounts: AccountMatches, domain: String, isExpanded: Bool) {
        self.accounts = accounts
        self.domain = domain
        self.expanded = isExpanded
        setUpAccountsViewModels(accounts: accounts)
    }
    
    private func setUpAccountsViewModels(accounts: AccountMatches) {
        shouldUseScrollView = expanded
        accountMatchesViewModels = []

        if expanded {
            showMoreOptions = false
            if accounts.perfectMatches.count > 0 {
                accountMatchesViewModels.append(AccountMatchesViewModel(accounts: accounts.perfectMatches.map { AccountViewModel(account: $0) },
                                                                        isPerfectMatch: true))
            }
            for key in accounts.partialMatches.keys.sorted() {
                if let partialMatch = accounts.partialMatches[key] {
                    accountMatchesViewModels.append(AccountMatchesViewModel(accounts: partialMatch.map { AccountViewModel(account: $0) },
                                                                            isPerfectMatch: false))
                }
            }
        } else {
            let limit = AutofillLoginPromptHelper.moreOptionsLimit
            showMoreOptions = AutofillLoginPromptHelper.shouldShowMoreOptions(accounts, limit: limit)

            if !accounts.perfectMatches.isEmpty {
                if accounts.perfectMatches.count > limit || (showMoreOptions && accounts.perfectMatches.count == limit) {
                    accountMatchesViewModels.append(AccountMatchesViewModel(accounts: subsetToDisplay(accounts.perfectMatches,
                                                                                                      limit: limit - 1),
                                                                            isPerfectMatch: true))
                } else {
                    accountMatchesViewModels.append(AccountMatchesViewModel(accounts: accounts.perfectMatches.map { AccountViewModel(account: $0) },
                                                                            isPerfectMatch: true))
                }
            } else {
                if let key = accounts.partialMatches.keys.sorted().first, let firstPartialMatch = accounts.partialMatches[key] {
                    if firstPartialMatch.count > limit || accounts.partialMatches.count > 1 {
                        let maxToDisplay = min(limit - 1, firstPartialMatch.count)
                        accountMatchesViewModels.append(AccountMatchesViewModel(accounts: subsetToDisplay(firstPartialMatch,
                                                                                                          limit: maxToDisplay),
                                                                                isPerfectMatch: false))
                    } else {
                        accountMatchesViewModels.append(AccountMatchesViewModel(accounts: firstPartialMatch.map { AccountViewModel(account: $0) },
                                                                                isPerfectMatch: false))
                    }
                }
            }
        }
    }

    private func subsetToDisplay(_ accounts: [SecureVaultModels.WebsiteAccount], limit: Int) -> [AccountViewModel] {
        return Array(accounts[0..<limit]).map { AccountViewModel(account: $0) }
    }

    func dismissView() {
        delegate?.autofillLoginPromptViewModelDidCancel(self)
    }
    
    func didSelectAccount(_ account: SecureVaultModels.WebsiteAccount) {
        delegate?.autofillLoginPromptViewModel(self, didSelectAccount: account)
    }
    
    func didExpand() {
        delegate?.autofillLoginPromptViewModelDidRequestExpansion(self)
    }
}

internal extension AutofillLoginPromptViewModel {
    static var preview: AutofillLoginPromptViewModel {
        let domain = "example.com"
        let account = SecureVaultModels.WebsiteAccount(title: "Title", username: "test@duck.com", domain: domain)
        let accountMatches = AccountMatches(perfectMatches: [account], partialMatches: [:])
        return AutofillLoginPromptViewModel(accounts: accountMatches, domain: domain, isExpanded: false)
    }
}
