//
//  AutofillCredentialsDebugViewController.swift
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
import BrowserServicesKit
import Common
import OSLog

class AutofillCredentialsDebugViewController: UITableViewController {

    struct DisplayCredentials {

        let tld: TLD
        let autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher
        var credential: SecureVaultModels.WebsiteCredentials

        var accountId: String {
            credential.account.id ?? ""
        }

        var accountTitle: String {
            credential.account.title ?? ""
        }

        var displayTitle: String {
            credential.account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        }

        var websiteUrl: String {
            credential.account.domain ?? ""
        }

        var domain: String {
            guard let url = credential.account.domain,
                  let urlComponents = autofillDomainNameUrlMatcher.normalizeSchemeForAutofill(url),
                  let domain = urlComponents.eTLDplus1(tld: tld) ?? urlComponents.host else {
                return ""
            }
            return domain
        }

        var username: String {
            credential.account.username ?? ""
        }

        var displayPassword: String {
            return credential.password.flatMap { String(data: $0, encoding: .utf8) } ?? "FAILED TO DECODE PW"
        }

        var notes: String {
            credential.account.notes ?? ""
        }

        var created: String {
            "\(credential.account.created)"
        }

        var lastUpdated: String {
            "\(credential.account.lastUpdated)"
        }

        var lastUsed: String {
            credential.account.lastUsed != nil ? "\(credential.account.lastUsed!)" : ""
        }

        var signature: String {
            credential.account.signature ?? ""
        }
    }

    private let tld: TLD = AppDependencyProvider.shared.storageCache.tld
    private let autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
    private var credentials: [DisplayCredentials] = []
    private let authenticator = AutofillLoginListAuthenticator(reason: UserText.autofillLoginListAuthenticationReason,
                                                               cancelTitle: UserText.autofillLoginListAuthenticationCancelButton)

    override func viewDidLoad() {
        super.viewDidLoad()

        beginAuthentication()
    }

    private func beginAuthentication() {
        authenticator.authenticate { [weak self] error in
            if error == nil {
                self?.reloadCredentials()
            }
        }
    }

    private func reloadCredentials() {
        credentials = loadCredentials()
        tableView.reloadData()
    }

    private func loadCredentials() -> [DisplayCredentials] {
        credentials = []

        do {
            let secureVault = try AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
            let accounts = try secureVault.accounts()
            var accountsFailedToLoad: [String?] = []

            for account in accounts {
                guard let accountId = account.id,
                      let accountIdInt = Int64(accountId),
                      let credential = try secureVault.websiteCredentialsFor(accountId: accountIdInt) else {
                    accountsFailedToLoad.append(account.id)
                    continue
                }

                let displayCredential = DisplayCredentials(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher, credential: credential)
                credentials.append(displayCredential)
            }

            if !accountsFailedToLoad.isEmpty {
                os_log("Failed to load credentials for accounts: %@", accountsFailedToLoad)
                showErrorAlertFor(accountsFailedToLoad)
            }

            return credentials
        } catch {
            os_log("Failed to fetch accounts")
            return []
        }
    }

    private func showErrorAlertFor(_ accountIds: [String?]) {
        let alert = UIAlertController(title: "Failed to load credentials for accounts:",
                                      message: accountIds.compactMap { $0 }.joined(separator: ", "),
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: UserText.actionOK, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credentials.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CredentialsTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? CredentialsTableViewCell else {
            fatalError("Could not dequeue cell")
        }

        let credential = credentials[indexPath.row]

        let details = """
        <style>
            body { font-size: 15px; }
        </style>
            <b>ID:</b> \(credential.accountId),<br>
            <b>Title:</b> \(credential.accountTitle),<br>
            <b>Display Title:</b> \(credential.displayTitle),<br>
            <b>Website URL:</b> \(credential.websiteUrl),<br>
            <b>Domain:</b> \(credential.domain),<br>
            <b>Username:</b> \(credential.username),<br>
            <b>Password:</b> \(credential.displayPassword),<br>
            <b>Notes:</b> \(credential.notes),<br>
            <b>Created:</b> \(credential.created),<br>
            <b>LastUpdated:</b> \(credential.lastUpdated),<br>
            <b>LastUsed:</b> \(credential.lastUsed),<br>
            <b>Signature:</b> \(credential.signature).<br>
        """

        if let data = details.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            do {
                let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                cell.details.attributedText = attributedString
                cell.details.textColor = .label
            } catch {
                os_log("Error creating attributed string: \(error)")
            }
        }

        return cell
    }

    @IBAction func sortButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Sort By...", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "ID (default)", style: .default, handler: { [weak self] _ in
            self?.reloadCredentials()
        }))
        alert.addAction(UIAlertAction(title: "URL", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.websiteUrl < $1.websiteUrl }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Domain", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.domain < $1.domain }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Display title", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.displayTitle < $1.displayTitle }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Last Updated", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.lastUpdated > $1.lastUpdated }
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Last Used", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.lastUsed > $1.lastUsed }
            self?.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)

    }
}

class CredentialsTableViewCell: UITableViewCell {

    static let reuseIdentifier = "CredentialsTableViewCell"

    @IBOutlet weak var details: UITextView!

}
