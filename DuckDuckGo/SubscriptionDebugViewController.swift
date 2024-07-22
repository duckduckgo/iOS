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

@available(iOS 15.0, *) final class SubscriptionDebugViewController: UITableViewController {

    let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)
    private var subscriptionManager: SubscriptionManager {
        AppDependencyProvider.shared.subscriptionManager
    }

    private let titles = [
        Sections.authorization: "Authentication",
        Sections.api: "Make API Call",
        Sections.appstore: "App Store",
        Sections.environment: "Environment",
    ]

    enum Sections: Int, CaseIterable {
        case authorization
        case api
        case appstore
        case environment
    }

    enum AuthorizationRows: Int, CaseIterable {
        case restoreSubscription
        case clearAuthData
        case showAccountDetails
    }
    
    enum SubscriptionRows: Int, CaseIterable {
        case validateToken
        case checkEntitlements
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        switch Sections(rawValue: indexPath.section) {

        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .restoreSubscription:
                cell.textLabel?.text = "I Have a Subscription"
            case .clearAuthData:
                cell.textLabel?.text = "Remove Subscription From This Device"
            case .showAccountDetails:
                cell.textLabel?.text = "Show Account Details"
            case .none:
                break
            }

        case .api:
            switch SubscriptionRows(rawValue: indexPath.row) {
            case .validateToken:
                cell.textLabel?.text = "Validate Token"
            case .checkEntitlements:
                cell.textLabel?.text = "Check Entitlements"
            case .getSubscription:
                cell.textLabel?.text = "Get Subscription Details"

            case .none:
                break
            }

        
        case .appstore:
            switch AppStoreRows(rawValue: indexPath.row) {
            case .syncAppStoreAccount:
                cell.textLabel?.text = "Sync App Store Account"
            case .none:
                break
            }
        
        case .environment:
            let currentEnv = subscriptionManager.currentEnvironment.serviceEnvironment
            switch EnvironmentRows(rawValue: indexPath.row) {
            case .staging:
                cell.textLabel?.text = "Staging"
                cell.accessoryType = currentEnv == .staging ? .checkmark : .none
            case .production:
                cell.textLabel?.text = "Production"
                cell.accessoryType = currentEnv == .production ? .checkmark : .none
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
        case .api: return SubscriptionRows.allCases.count
        case .appstore: return AppStoreRows.allCases.count
        case .environment: return EnvironmentRows.allCases.count
        case .none: return 0

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .authorization:
            switch AuthorizationRows(rawValue: indexPath.row) {
            case .restoreSubscription: openSubscriptionRestoreFlow()
            case .clearAuthData: clearAuthData()
            case .showAccountDetails: showAccountDetails()
            default: break
            }
        case .appstore:
            switch AppStoreRows(rawValue: indexPath.row) {
            case .syncAppStoreAccount: syncAppleIDAccount()
            default: break
            }
        case .api:
            switch SubscriptionRows(rawValue: indexPath.row) {
            case .validateToken: validateToken()
            case .checkEntitlements: checkEntitlements()
            case .getSubscription: getSubscriptionDetails()
            default: break
            }
        case .environment:
            guard let subEnv: EnvironmentRows = EnvironmentRows(rawValue: indexPath.row) else { return }
            changeSubscriptionEnvironment(envRows: subEnv)
        case .none:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func changeSubscriptionEnvironment(envRows: EnvironmentRows) {
        var subEnvDesc: String
        switch envRows {
        case .staging:
            subEnvDesc = "STAGING"
        case .production:
            subEnvDesc = "PRODUCTION"
        }
        let message = """
                    Are you sure you want to change the environment to \(subEnvDesc)?
                    This setting IS persisted between app runs. This action will close the app, do you want to proceed?
                    """
        let alertController = UIAlertController(title: "⚠️ App restart required! The changes are persistent",
                                                message: message,
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            switch envRows {
            case .staging:
                self?.setEnvironment(.staging)
            case .production:
                self?.setEnvironment(.production)
            }
            // Close the app
            exit(0)
        })
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func showAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

//    func showAlert(title: String, message: String, alternativeAction)

    // MARK: Account Status Actions

    private func openSubscriptionRestoreFlow() {
        guard let mainVC = view.window?.rootViewController as? MainViewController else { return }

        if let navigationController = mainVC.presentedViewController as? UINavigationController {
            navigationController.popToRootViewController {
                mainVC.segueToSubscriptionRestoreFlow()
            }
        }
    }

    private func clearAuthData() {
        subscriptionManager.accountManager.signOut()
        showAlert(title: "Data cleared!")
    }
    
    private func showAccountDetails() {
        let title = subscriptionManager.accountManager.isUserAuthenticated ? "Authenticated" : "Not Authenticated"
        let message = subscriptionManager.accountManager.isUserAuthenticated ?
        ["Service Environment: \(subscriptionManager.currentEnvironment.serviceEnvironment.description)",
            "AuthToken: \(subscriptionManager.accountManager.authToken ?? "")",
            "AccessToken: \(subscriptionManager.accountManager.accessToken ?? "")",
            "Email: \(subscriptionManager.accountManager.email ?? "")"].joined(separator: "\n") : nil
        showAlert(title: title, message: message)
    }
            
    private func syncAppleIDAccount() {
        Task {
            do {
                try await subscriptionManager.storePurchaseManager().syncAppleIDAccount()
            } catch {
                showAlert(title: "Error syncing!", message: error.localizedDescription)
                return
            }

            showAlert(title: "Account synced!", message: "")
        }
    }
    
    private func validateToken() {
        Task {
            guard let token = subscriptionManager.accountManager.accessToken else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Token not available")
                return
            }
            switch await subscriptionManager.authEndpointService.validateToken(accessToken: token) {
            case .success(let response):
                showAlert(title: "Token details", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Error Validating Token", message: "\(error)")
            }
        }
    }
    
    private func getSubscriptionDetails() {
        Task {
            guard let token = subscriptionManager.accountManager.accessToken else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Subscription not available")
                return
            }
            switch await subscriptionManager.subscriptionEndpointService.getSubscription(accessToken: token,
                                                                                         cachePolicy: .reloadIgnoringLocalCacheData) {
            case .success(let response):
                showAlert(title: "Subscription info", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Subscription Error", message: "\(error)")
            }
        }
    }
    
    private func checkEntitlements() {
        Task {
            var results: [String] = []
            guard subscriptionManager.accountManager.accessToken != nil else {
                showAlert(title: "Not authenticated", message: "No authenticated user found! - Subscription not available")
                return
            }
            let entitlements: [Entitlement.ProductName] = [.networkProtection, .dataBrokerProtection, .identityTheftRestoration]
            for entitlement in entitlements {
                if case let .success(result) = await subscriptionManager.accountManager.hasEntitlement(forProductName: entitlement,
                                                                                                       cachePolicy: .reloadIgnoringLocalCacheData) {
                    let resultSummary = "Entitlement check for \(entitlement.rawValue): \(result)"
                    results.append(resultSummary)
                    print(resultSummary)
                }
            }
            showAlert(title: "Available Entitlements", message: results.joined(separator: "\n"))
        }
    }
    
    private func setEnvironment(_ environment: SubscriptionEnvironment.ServiceEnvironment) {
        
        let subscriptionUserDefaults = UserDefaults(suiteName: subscriptionAppGroup)!
        let currentSubscriptionEnvironment = DefaultSubscriptionManager.getSavedOrDefaultEnvironment(userDefaults: subscriptionUserDefaults)
        var newSubscriptionEnvironment = SubscriptionEnvironment.default
        newSubscriptionEnvironment.serviceEnvironment = environment

        if newSubscriptionEnvironment.serviceEnvironment != currentSubscriptionEnvironment.serviceEnvironment {
            subscriptionManager.accountManager.signOut()

            // Save Subscription environment
            DefaultSubscriptionManager.save(subscriptionEnvironment: newSubscriptionEnvironment, userDefaults: subscriptionUserDefaults)

            // The VPN environment is forced to match the subscription environment
            let settings = AppDependencyProvider.shared.vpnSettings
            switch newSubscriptionEnvironment.serviceEnvironment {
            case .production:
                settings.selectedEnvironment = .production
            case .staging:
                settings.selectedEnvironment = .staging
            }
            NetworkProtectionLocationListCompositeRepository.clearCache()
        }
    }
}

extension UINavigationController {

    func popToRootViewController(animated: Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }

    func popViewControllerWithHandler(animated: Bool = true, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }

    func pushViewController(viewController: UIViewController, animated: Bool = true,  completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

}
