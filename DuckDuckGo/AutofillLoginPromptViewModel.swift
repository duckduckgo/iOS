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
}

struct AccountViewModel: Hashable {
    
    let account: SecureVaultModels.WebsiteAccount
    var displayString: String {
        return account.username //TODO email formatting //TODO should be title, or username?
    }
    
    static func == (lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        return lhs.account.id == rhs.account.id //TODO should make SecureVaultModels.WebsiteAccount actually do this conforming
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account.id)
    }
}

class AutofillLoginPromptViewModel: ObservableObject {
    
    weak var delegate: AutofillLoginPromptViewModelDelegate?
    
    @Published var accountsViewModels: [AccountViewModel] = []
    @Published var faviconImage = UIImage(named: "Logo")!
    private(set) var domain: String

    var message: String {
        return "Use Saved Login?" //TODO string
    }
    
    var moreOptionsButtonString: String {
        return "More Options" //TODO string
    }
    
    internal init?(accounts: [SecureVaultModels.WebsiteAccount]) {
        guard let firstAccount = accounts.first else {
            return nil
        }
        self.domain = firstAccount.domain
        setUpAccountsViewModels(accounts: accounts)
        loadFavicon()
    }
    
    private func setUpAccountsViewModels(accounts: [SecureVaultModels.WebsiteAccount]) {
        accountsViewModels = accounts.map { AccountViewModel(account: $0) }
    }
    
    private func loadFavicon() {
        FaviconsHelper.loadFaviconSync(forDomain: domain,
                                       usingCache: .tabs,
                                       useFakeFavicon: true) { image, _ in
            if let image = image {
                self.faviconImage = image
            }
        }
    }
    
    func dismissView() {
        delegate?.autofillLoginPromptViewModelDidCancel(self)
    }
    
    func didSelectAccount(_ account: SecureVaultModels.WebsiteAccount) {
        delegate?.autofillLoginPromptViewModel(self, didSelectAccount: account)
    }
}

internal extension AutofillLoginPromptViewModel {
    static var preview: AutofillLoginPromptViewModel {
        let account = SecureVaultModels.WebsiteAccount(title: "Title", username: "test@duck.com", domain: "example.com")
        return AutofillLoginPromptViewModel(accounts: [account])!
    }
}
