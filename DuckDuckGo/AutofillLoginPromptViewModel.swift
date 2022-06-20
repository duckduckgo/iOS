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
}

struct AccountViewModel: Hashable {
    
    let account: SecureVaultModels.WebsiteAccount
    var displayString: String {
        if account.username.count > 0 {
            return AutofillInterfaceEmailTruncator.truncateEmail(account.username, maxLength: 36)
        } else {
            let urlString = URL(string: account.domain)?.absoluteString.dropPrefix(prefix: "www.")
            let string = urlString ?? account.domain
            return "Login for \(string)"
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
    
    @Published var accountsViewModels: [AccountViewModel] = []
    @Published var showMoreOptions = false
    @Published var shouldUseScrollView = false
    
    private(set) var domain: String
    private var accounts: [SecureVaultModels.WebsiteAccount]
    
    private var expanded = false {
        didSet {
            setUpAccountsViewModels(accounts: accounts)
        }
    }
    
    let message = UserText.autofillLoginPromptTitle
    let moreOptionsButtonString = UserText.autofillLoginPromptMoreOptions
    
    internal init?(accounts: [SecureVaultModels.WebsiteAccount], isExpanded: Bool) {
        guard let firstAccount = accounts.first else {
            return nil
        }
        self.domain = firstAccount.domain
        self.expanded = isExpanded
        self.accounts = accounts
        setUpAccountsViewModels(accounts: accounts)
    }
    
    private func setUpAccountsViewModels(accounts: [SecureVaultModels.WebsiteAccount]) {
        let accountsToShow: [SecureVaultModels.WebsiteAccount]
        shouldUseScrollView = expanded
        if expanded || accounts.count <= 3 {
            accountsToShow = accounts
            showMoreOptions = false
        } else {
            accountsToShow = Array(accounts[0...1])
            showMoreOptions = true
        }
        accountsViewModels = accountsToShow.map { AccountViewModel(account: $0) }
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
        let account = SecureVaultModels.WebsiteAccount(title: "Title", username: "test@duck.com", domain: "example.com")
        return AutofillLoginPromptViewModel(accounts: [account], isExpanded: false)!
    }
}

@available(iOS 14.0, *)
extension AutofillLoginPromptViewModel: AutofillLoginPromptViewControllerExpansionResponseDelegate {
    func autofillLoginPromptViewController(_ viewController: AutofillLoginPromptViewController, isExpanded: Bool) {
        if self.expanded {
            return // Never collapse after expanding
        }
        self.expanded = isExpanded
    }
}
