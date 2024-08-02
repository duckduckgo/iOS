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

class AutofillCredentialsDebugViewController: UITableViewController {

    struct DisplayCredentials {
        private let tld: TLD = AppDependencyProvider.shared.storageCache.tld
        private let autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher = AutofillDomainNameUrlMatcher()
        
        let credential: SecureVaultModels.WebsiteCredentials

        var displayTitle: String {
            return credential.account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        }

        var displayPassword: String {
            return credential.password.flatMap { String(data: $0, encoding: .utf8) } ?? "FAILED TO DECODE PW"
        }

        var domain: String {
            guard let url = credential.account.domain,
                  let urlComponents = autofillDomainNameUrlMatcher.normalizeSchemeForAutofill(url),
                  let domain = urlComponents.eTLDplus1(tld: tld) ?? urlComponents.host else {
                return ""
            }
            return domain
        }

        var lastUsed: String {
            return credential.account.lastUsed != nil ? "\(credential.account.lastUsed!)" : ""
        }
    }

    private var credentials: [DisplayCredentials] = []
    private let authenticator = AutofillLoginListAuthenticator(reason: UserText.autofillLoginListAuthenticationReason)

    override func viewDidLoad() {
        super.viewDidLoad()

        authenticator.authenticate { [weak self] error in
            if error == nil {
                self?.loadAllCredentials()
            }
        }
    }

    private func loadAllCredentials() {
        credentials = []

        do {
            let secureVault = try AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
            let accounts = try secureVault.accounts()
            for account in accounts {
                if let accountID = account.id,
                   let accountIdInt = Int64(accountID),
                   let credential = try secureVault.websiteCredentialsFor(accountId: accountIdInt) {
                    let displayCredential = DisplayCredentials(credential: credential)
                    credentials.append(displayCredential)
                }
            }
            tableView.reloadData()
        } catch {
            os_log("Failed to fetch accounts")
        }
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
            <b>ID:</b> \(credential.credential.account.id ?? ""),<br>
            <b>Title:</b> \(credential.credential.account.title ?? ""),<br>
            <b>Display Title:</b> \(credential.displayTitle),<br>
            <b>Website URL:</b> \(credential.credential.account.domain ?? ""),<br>
            <b>Domain:</b> \(credential.domain),<br>
            <b>Username:</b> \(credential.credential.account.username ?? ""),<br>
            <b>Password:</b> \(credential.displayPassword),<br>
            <b>Notes:</b> \(credential.credential.account.notes ?? ""),<br>
            <b>Created:</b> \(credential.credential.account.created),<br>
            <b>LastUpdated:</b> \(credential.credential.account.lastUpdated),<br>
            <b>LastUsed:</b> \(credential.lastUsed),<br>
            <b>Signature:</b> \(credential.credential.account.signature ?? "").<br>
        """

        if let data = details.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            do {
                let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                cell.details.attributedText = attributedString
            } catch {
                os_log("Error creating attributed string: \(error)")
            }
        }

        return cell
    }

    @IBAction func sortButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Sort By...", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "ID (default)", style: .default, handler: { [weak self] _ in
            self?.loadAllCredentials()
            self?.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "URL", style: .default, handler: { [weak self] _ in
            self?.credentials.sort { $0.credential.account.domain ?? "" < $1.credential.account.domain ?? "" }
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
            self?.credentials.sort { $0.credential.account.lastUpdated > $1.credential.account.lastUpdated }
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
