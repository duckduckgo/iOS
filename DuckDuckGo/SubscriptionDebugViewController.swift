//
//  SubscriptionDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

#if !SUBSCRIPTION

final class SubscriptionDebugViewController: UITableViewController {
    // Just an empty VC
}

#else

final class SubscriptionDebugViewController: UITableViewController {
    
    private let accountManager = AccountManager()
 
    @available(macOS 12.0, iOS 15.0, *)
    fileprivate var purchaseManager: PurchaseManager = PurchaseManager.shared
    
    private let titles = [
        Sections.authorization: "Authentication",
    ]

    enum Sections: Int, CaseIterable {
        case authorization
    }

    enum AuthorizationRows: Int, CaseIterable {
        case showDetails
        case clearAuthData
        case injectCredentials
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.detailTextLabel?.text = nil

        switch Sections(rawValue: indexPath.section) {

        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .clearAuthData:
                cell.textLabel?.text = "Clear Authorization Data (Sign out)"
            case .showDetails:
                cell.textLabel?.text = "Show Account Details"
            case .injectCredentials:
                cell.textLabel?.text = "Simulate Authentication (Inject Fake token)"
            case .none:
                break
            }

        case.none:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .authorization: return AuthorizationRows.allCases.count
        case .none: return 0

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .clearAuthData: clearAuthData()
            case .showDetails: showDetails()
            case .injectCredentials: injectCredentials()
            default: break
            }
        case .none:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)

            // Assuming this function is in a UIViewController subclass
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: Account Status Actions
    private func clearAuthData() {
        accountManager.signOut()
    }
    
    private func injectCredentials() {
        accountManager.storeAccount(token: "a-fake-token",
                                    email: "a.fake@email.com",
                                    externalID: "666")
    }
    
    private func showDetails() {
        let title = accountManager.isUserAuthenticated ? "Authenticated" : "Not Authenticated"
        let message = accountManager.isUserAuthenticated ? ["AuthToken: \(accountManager.authToken ?? "")",
                                                   "AccessToken: \(accountManager.accessToken ?? "")",
                                                   "Email: \(accountManager.email ?? "")"].joined(separator: "\n") : nil
        showAlert(title: title, message: message)
    }
}

#endif
