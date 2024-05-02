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

import Subscription
import Core

#if NETWORK_PROTECTION
import NetworkProtection
#endif

@available(iOS 15.0, *)
final class SubscriptionDebugViewController: UITableViewController {
    
    private let accountManager: AccountManaging = AppDelegate.accountManager
    fileprivate var purchaseManager: PurchaseManager = PurchaseManager.shared
    
    @UserDefaultsWrapper(key: .privacyProEnvironment, defaultValue: SubscriptionPurchaseEnvironment.ServiceEnvironment.default.description)
    private var privacyProEnvironment: String
    
    private let titles = [
        Sections.authorization: "Authentication",
        Sections.subscription: "Subscription",
        Sections.appstore: "App Store",
        Sections.environment: "Environment",
    ]

    enum Sections: Int, CaseIterable {
        case authorization
        case subscription
        case appstore
        case environment
    }

    enum AuthorizationRows: Int, CaseIterable {
        case showAccountDetails
        case clearAuthData
        case injectCredentials
    }
    
    enum SubscriptionRows: Int, CaseIterable {
        case validateToken
        case getEntitlements
        case getSubscription
    }
    
    enum AppStoreRows: Int, CaseIterable {
        case syncAppStoreAccount
    }
    
    enum EnvironmentRows: Int, CaseIterable {
        case staging
        case production
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        switch Sections(rawValue: indexPath.section) {

        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .clearAuthData:
                cell.textLabel?.text = "Clear Authorization Data (Sign out)"
            case .showAccountDetails:
                cell.textLabel?.text = "Show Account Details"
            case .injectCredentials:
                cell.textLabel?.text = "Simulate Authentication (Inject Fake token)"
            case .none:
                break
            }

        case.none:
            break
        
        case .appstore:
            switch AppStoreRows(rawValue: indexPath.row) {
            case .syncAppStoreAccount:
                cell.textLabel?.text = "Sync App Store Account"
            case .none:
                break
            }
            
        case .subscription:
            switch SubscriptionRows(rawValue: indexPath.row) {
            case .validateToken:
                cell.textLabel?.text = "Validate Token"
            case .getSubscription:
                cell.textLabel?.text = "Get subscription details"
            case .getEntitlements:
                cell.textLabel?.text = "Get Entitlements"
            case .none:
                break
            }
        
        case .environment:
            let staging = SubscriptionPurchaseEnvironment.ServiceEnvironment.staging
            let prod = SubscriptionPurchaseEnvironment.ServiceEnvironment.production
            switch EnvironmentRows(rawValue: indexPath.row) {
            case .staging:
                cell.textLabel?.text = "Staging"
                cell.accessoryType = SubscriptionPurchaseEnvironment.currentServiceEnvironment == staging ? .checkmark : .none
            case .production:
                cell.textLabel?.text = "Production"
                cell.accessoryType = SubscriptionPurchaseEnvironment.currentServiceEnvironment == prod ? .checkmark : .none
            case .none:
                break
            }
        }
        return cell
    }
    // swiftlint:enable cyclomatic_complexity

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .authorization: return AuthorizationRows.allCases.count
        case .subscription: return SubscriptionRows.allCases.count
        case .appstore: return AppStoreRows.allCases.count
        case .environment: return EnvironmentRows.allCases.count
        case .none: return 0

        }
    }

    // swiftlint:disable cyclomatic_complexity
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .clearAuthData: clearAuthData()
            case .showAccountDetails: showAccountDetails()
            case .injectCredentials: injectCredentials()
            default: break
            }
        case .appstore:
            switch AppStoreRows(rawValue: indexPath.row) {
            case .syncAppStoreAccount: syncAppleIDAccount()
            default: break
            }
        case .subscription:
            switch SubscriptionRows(rawValue: indexPath.row) {
            case .validateToken: validateToken()
            case .getSubscription: getSubscription()
            case .getEntitlements: getEntitlements()
            default: break
            }
        case .environment:
            switch EnvironmentRows(rawValue: indexPath.row) {
            case .staging: setEnvironment(.staging)
            case .production: setEnvironment(.production)
            default: break
            }
        case .none:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    // swiftlint:enable cyclomatic_complexity
    
    private func showAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: Account Status Actions
    private func clearAuthData() {
        accountManager.signOut()
        showAlert(title: "Data cleared!")
    }
    
    private func injectCredentials() {
        accountManager.storeAccount(token: "a-fake-token",
                                    email: "a.fake@email.com",
                                    externalID: "666")
        showAccountDetails()
    }
    
    private func showAccountDetails() {
        let title = accountManager.isUserAuthenticated ? "Authenticated" : "Not Authenticated"
        let message = accountManager.isUserAuthenticated ?
            ["Service Environment: \(SubscriptionPurchaseEnvironment.currentServiceEnvironment.description)",
            "AuthToken: \(accountManager.authToken ?? "")",
            "AccessToken: \(accountManager.accessToken ?? "")",
            "Email: \(accountManager.email ?? "")"].joined(separator: "\n") : nil
        showAlert(title: title, message: message)
    }
            
    private func syncAppleIDAccount() {
        Task {
            switch await purchaseManager.syncAppleIDAccount() {
            case .success:
                showAlert(title: "Account synced!", message: "")
            case .failure(let error):
                showAlert(title: "Error syncing!", message: error.localizedDescription)
            }
        }
    }
    
    private func validateToken() {
        Task {
            guard let token = accountManager.accessToken else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Token not available")
                return
            }
            switch await AuthService.validateToken(accessToken: token) {
            case .success(let response):
                showAlert(title: "Token details", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Error Validating Token", message: "\(error)")
            }
        }
    }
    
    private func getSubscription() {
        Task {
            guard let token = accountManager.accessToken else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Subscription not available")
                return
            }
            switch await SubscriptionService.getSubscription(accessToken: token, cachePolicy: .reloadIgnoringLocalCacheData) {
            case .success(let response):
                showAlert(title: "Subscription info", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Subscription Error", message: "\(error)")
            }
        }
    }
    
    private func getEntitlements() {
        Task {
            var results: [String] = []
            guard accountManager.accessToken != nil else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Subscription not available")
                return
            }
            let entitlements: [Entitlement.ProductName] = [.networkProtection, .dataBrokerProtection, .identityTheftRestoration]
            for entitlement in entitlements {
                if case let .success(result) = await accountManager.hasEntitlement(for: entitlement, cachePolicy: .reloadIgnoringLocalCacheData) {
                    let resultSummary = "Entitlement check for \(entitlement.rawValue): \(result)"
                    results.append(resultSummary)
                    print(resultSummary)
                }
            }
            showAlert(title: "Available Entitlements", message: results.joined(separator: "\n"))
        }
    }
    
    private func setEnvironment(_ environment: SubscriptionPurchaseEnvironment.ServiceEnvironment) {
        if environment.description != privacyProEnvironment {
            
            accountManager.signOut()
            
            // Update Subscription environment
            privacyProEnvironment = environment.rawValue
            SubscriptionPurchaseEnvironment.currentServiceEnvironment = environment
            
            // Update VPN Environment
            VPNSettings(defaults: .networkProtectionGroupDefaults).selectedEnvironment = environment == .production
                ? .production
                : .staging
            NetworkProtectionLocationListCompositeRepository.clearCache()
            
            tableView.reloadData()
        }
        
    }
}
