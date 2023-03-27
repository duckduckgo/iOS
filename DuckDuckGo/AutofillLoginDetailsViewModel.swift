//
//  AutofillLoginDetailsViewModel.swift
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
import SwiftUI
import Core

protocol AutofillLoginDetailsViewModelDelegate: AnyObject {
    func autofillLoginDetailsViewModelDidSave()
    func autofillLoginDetailsViewModelDidAttemptToSaveDuplicateLogin()
    func autofillLoginDetailsViewModelDelete(account: SecureVaultModels.WebsiteAccount, title: String)
    func autofillLoginDetailsViewModelDismiss()
}

final class AutofillLoginDetailsViewModel: ObservableObject {
    enum ViewMode {
        case edit
        case view
        case new
    }
    
    enum PasteboardCopyAction {
        case username
        case password
        case address
        case notes
    }
    
    weak var delegate: AutofillLoginDetailsViewModelDelegate?
    var account: SecureVaultModels.WebsiteAccount?
    private let tld: TLD
    private let autofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()

    @ObservedObject var headerViewModel: AutofillLoginDetailsHeaderViewModel
    @Published var isPasswordHidden = true
    @Published var username = ""
    @Published var password = ""
    @Published var address = ""
    @Published var notes = ""
    @Published var title = ""
    @Published var selectedCell: UUID?
    @Published var viewMode: ViewMode = .view {
        didSet {
            selectedCell = nil
            if viewMode == .edit && password.isEmpty {
                isPasswordHidden = false
            } else {
                isPasswordHidden = true
            }
        }
    }
    
    private var passwordData: Data {
        password.data(using: .utf8)!
    }
    
    var navigationTitle: String {
        switch viewMode {
        case .edit:
            return UserText.autofillLoginDetailsEditTitle
        case .view:
            return title.isEmpty ? address : title
        case .new:
            return UserText.autofillLoginDetailsNewTitle
        }
    }
    
    var shouldShowSaveButton: Bool {
        guard viewMode == .new else { return false }
        
        return !username.isEmpty || !password.isEmpty || !address.isEmpty || !title.isEmpty
    }

    var websiteIsValidUrl: Bool {
        account?.domain.toTrimmedURL != nil
    }
    
    var userVisiblePassword: String {
        let passwordHider = PasswordHider(password: password)
        return isPasswordHidden ? passwordHider.hiddenPassword : passwordHider.password
    }

    var usernameDisplayString: String {
        AutofillInterfaceEmailTruncator.truncateEmail(username, maxLength: 36)
    }

    internal init(account: SecureVaultModels.WebsiteAccount? = nil, tld: TLD) {
        self.account = account
        self.tld = tld
        self.headerViewModel = AutofillLoginDetailsHeaderViewModel()
        if let account = account {
            self.updateData(with: account)
            AppDependencyProvider.shared.autofillLoginSession.lastAccessedAccount = account
        } else {
            viewMode = .new
        }
    }
    
    private func updateData(with account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        username = account.username
        address = account.domain
        title = account.title ?? ""
        notes = account.notes ?? ""
        headerViewModel.updateData(with: account,
                                   tld: tld,
                                   autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                   autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        setupPassword(with: account)
    }
    
    func toggleEditMode() {
        withAnimation {
            if viewMode == .edit {
                viewMode = .view
                if let account = account {
                    updateData(with: account)
                }
            } else {
                viewMode = .edit
            }
        }
    }
    
    func copyToPasteboard(_ action: PasteboardCopyAction) {
        var message = ""
        switch action {
        case .username:
            message = UserText.autofillCopyToastUsernameCopied
            UIPasteboard.general.string = username
        case .password:
            message = UserText.autofillCopyToastPasswordCopied
            UIPasteboard.general.string = password
        case .address:
            message = UserText.autofillCopyToastAddressCopied
            UIPasteboard.general.string = address
        case .notes:
            message = UserText.autofillCopyToastNotesCopied
            UIPasteboard.general.string = notes
        }
        
        presentCopyConfirmation(message: message)
    }
    
    private func presentCopyConfirmation(message: String) {
        DispatchQueue.main.async {
            ActionMessageView.present(message: message,
                                      actionTitle: "",
                                      onAction: {})
        }
    }
    
    private func setupPassword(with account: SecureVaultModels.WebsiteAccount) {
        do {
            if let accountID = account.id, let accountIdInt = Int64(accountID) {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                
                if let credential = try
                    vault.websiteCredentialsFor(accountId: accountIdInt) {
                    self.password = String(data: credential.password, encoding: .utf8) ?? ""
                }
            }
        } catch {
            Pixel.fire(pixel: .secureVaultError)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func save() {
        guard let vault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared) else {
            return
        }
            
        switch viewMode {
        case .edit:
            guard let accountID = account?.id else {
                assertionFailure("Trying to save edited account, but the account doesn't exist")
                return
            }
                           
            do {
                if let accountIdInt = Int64(accountID),
                   var credential = try vault.websiteCredentialsFor(accountId: accountIdInt) {
                    credential.account.username = username
                    credential.account.title = title
                    credential.account.domain = autofillDomainNameUrlMatcher.normalizeUrlForWeb(address)
                    credential.account.notes = notes
                    credential.password = passwordData
                    
                    try vault.storeWebsiteCredentials(credential)
                    delegate?.autofillLoginDetailsViewModelDidSave()
                    
                    // Refetch after save to get updated properties like "lastUpdated"
                    if let newCredential = try vault.websiteCredentialsFor(accountId: accountIdInt) {
                        self.updateData(with: newCredential.account)
                    }
                    viewMode = .view
                }
            } catch let error {
                Pixel.fire(pixel: .secureVaultError, error: error)
            }
        case .view:
            break
        case .new:
            let cleanAddress = autofillDomainNameUrlMatcher.normalizeUrlForWeb(address)
            let account = SecureVaultModels.WebsiteAccount(title: title, username: username, domain: cleanAddress, notes: notes)
            let credentials = SecureVaultModels.WebsiteCredentials(account: account, password: passwordData)

            do {
                let id = try vault.storeWebsiteCredentials(credentials)
                
                delegate?.autofillLoginDetailsViewModelDidSave()
                
                // Refetch after save to get updated properties like "lastUpdated"
                if let newCredential = try vault.websiteCredentialsFor(accountId: id) {
                    self.updateData(with: newCredential.account)
                }
                
            } catch let error {
                if case SecureVaultError.duplicateRecord = error {
                    Pixel.fire(pixel: .autofillLoginsSettingsAddNewLoginErrorAttemptedToCreateDuplicate)
                    delegate?.autofillLoginDetailsViewModelDidAttemptToSaveDuplicateLogin()
                } else {
                    Pixel.fire(pixel: .secureVaultError, error: error)
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func delete() {
        guard let account = account else {
            assertionFailure("Trying to delete account, but the account doesn't exist")
            return
        }
        delegate?.autofillLoginDetailsViewModelDelete(account: account, title: headerViewModel.title)
    }

    func openUrl() {
        guard let url = account?.domain.toTrimmedURL else { return }

        LaunchTabNotification.postLaunchTabNotification(urlString: url.absoluteString)
        delegate?.autofillLoginDetailsViewModelDismiss()
    }
}

final class AutofillLoginDetailsHeaderViewModel: ObservableObject {
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var domain: String = ""
    @Published var preferredFakeFaviconLetter: String?
    
    func updateData(with account: SecureVaultModels.WebsiteAccount, tld: TLD, autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher, autofillDomainNameUrlSort: AutofillDomainNameUrlSort) {
        self.title = account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        self.subtitle = UserText.autofillLoginDetailsLastUpdated(for: (dateFormatter.string(from: account.lastUpdated)))
        self.domain = account.domain
        self.preferredFakeFaviconLetter = account.faviconLetter(tld: tld, autofillDomainNameUrlSort: autofillDomainNameUrlSort)
    }

}
