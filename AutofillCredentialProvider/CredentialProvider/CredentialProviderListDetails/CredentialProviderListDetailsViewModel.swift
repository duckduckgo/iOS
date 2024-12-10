//
//  CredentialProviderListDetailsViewModel.swift
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

import UIKit
import SwiftUI
import BrowserServicesKit
import Common
import Combine
import Core

protocol CredentialProviderListDetailsViewModelDelegate: AnyObject {
    func credentialProviderListDetailsViewModelShowActionMessage(message: String)
    func credentialProviderListDetailsViewModelDidProvideText(text: String)
}

final class CredentialProviderListDetailsViewModel: ObservableObject {
    enum ViewMode {
        case view
    }

    enum PasteboardCopyAction {
        case username
        case password
        case address
        case notes
    }

    weak var delegate: CredentialProviderListDetailsViewModelDelegate?
    var account: SecureVaultModels.WebsiteAccount?

    private let tld: TLD
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()

    @ObservedObject var headerViewModel: CredentialProviderListDetailsHeaderViewModel
    @Published var isPasswordHidden = true
    @Published var username = ""
    @Published var password = ""
    @Published var address = ""
    @Published var notes = ""
    @Published var title = ""
    @Published var selectedCell: UUID?

    private var passwordData: Data {
        password.data(using: .utf8)!
    }

    var navigationTitle: String {
        return title.isEmpty ? address : title
    }

    var websiteIsValidUrl: Bool {
        account?.domain?.toTrimmedURL != nil
    }

    var userVisiblePassword: String {
        let passwordHider = PasswordHider(password: password)
        return isPasswordHidden ? passwordHider.hiddenPassword : passwordHider.password
    }

    var usernameDisplayString: String {
        AutofillInterfaceEmailTruncator.truncateEmail(username, maxLength: 36)
    }

    let shouldProvideTextToInsert: Bool

    internal init(account: SecureVaultModels.WebsiteAccount? = nil,
                  tld: TLD,
                  emailManager: EmailManager = EmailManager(),
                  shouldProvideTextToInsert: Bool) {
        self.account = account
        self.tld = tld
        self.headerViewModel = CredentialProviderListDetailsHeaderViewModel()
        self.shouldProvideTextToInsert = shouldProvideTextToInsert
        if let account = account {
            self.updateData(with: account)
        }
    }

    func updateData(with account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        username = account.username ?? ""
        address = account.domain ?? ""
        title = account.title ?? ""
        notes = account.notes ?? ""
        headerViewModel.updateData(with: account,
                                   tld: tld,
                                   autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                   autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        setupPassword(with: account)
    }

    func copyToPasteboard(_ action: PasteboardCopyAction) {
        var message = ""
        switch action {
        case .username:
            message = UserText.credentialProviderDetailsCopyToastUsernameCopied
            UIPasteboard.general.string = username
            Pixel.fire(pixel: .autofillManagementCopyUsername)
        case .password:
            message = UserText.credentialProviderDetailsCopyToastPasswordCopied
            UIPasteboard.general.string = password
            Pixel.fire(pixel: .autofillManagementCopyPassword)
        case .address:
            message = UserText.credentialProviderDetailsCopyToastAddressCopied
            UIPasteboard.general.string = address
        case .notes:
            message = UserText.credentialProviderDetailsCopyToastNotesCopied
            UIPasteboard.general.string = notes
        }

        delegate?.credentialProviderListDetailsViewModelShowActionMessage(message: message)
    }

    func textToReturn(_ action: PasteboardCopyAction) {
        var text = ""
        switch action {
        case .username:
            text = username
        case .password:
            text = password
        default:
            return
        }

        delegate?.credentialProviderListDetailsViewModelDidProvideText(text: text)
    }

    private func setupPassword(with account: SecureVaultModels.WebsiteAccount) {
        do {
            if let accountID = account.id, let accountIdInt = Int64(accountID) {
                let vault = try AutofillSecureVaultFactory.makeVault(reporter: nil)

                if let credential = try
                    vault.websiteCredentialsFor(accountId: accountIdInt) {
                    self.password = credential.password.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                }
            }
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
        }
    }

    private func handleSecureVaultError(_ error: Error) {
        Pixel.fire(pixel: .secureVaultError, error: error)
    }
}

final class CredentialProviderListDetailsHeaderViewModel: ObservableObject {
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var domain: String = ""
    @Published var favicon: UIImage = UIImage(named: "Logo")!

    func updateData(with account: SecureVaultModels.WebsiteAccount, tld: TLD, autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher, autofillDomainNameUrlSort: AutofillDomainNameUrlSort) {
        self.title = account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        self.subtitle = UserText.credentialProviderDetailsLastUpdated(for: (dateFormatter.string(from: account.lastUpdated)))
        self.domain = account.domain ?? ""

        // Update favicon
        let accountName = account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        let accountTitle = (account.title?.isEmpty == false) ? account.title! : "#"
        let preferredFakeFaviconLetters = tld.eTLDplus1(accountName) ?? accountTitle
        if let image = FaviconHelper.loadImageFromCache(forDomain: domain, preferredFakeFaviconLetters: preferredFakeFaviconLetters) {
            self.favicon = image
        }
    }

}
