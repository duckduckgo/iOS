//
//  SubscriptionModel.swift
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

// public final class SubscriptionDebugModel {
    /*
    private let accountManager = AccountManager()

    private var _purchaseManager: Any?
    
    @available(macOS 12.0, iOS 15.0, *)
    fileprivate var purchaseManager: PurchaseManager {
        if _purchaseManager == nil {
            _purchaseManager = PurchaseManager()
        }
        // swiftlint:disable:next force_cast
        return _purchaseManager as! PurchaseManager
    }

    @objc
    func simulateSubscriptionActiveState() {
        accountManager.storeAccount(token: "fake-token", email: "fake@email.com", externalID: "123")
    }

    @objc
    func signOut() {
        accountManager.signOut()
    }

    @objc
    func showAccountDetails() {
        let title = accountManager.isUserAuthenticated ? "Authenticated" : "Not Authenticated"
        let message = accountManager.isUserAuthenticated ? ["AuthToken: \(accountManager.authToken ?? "")",
                                                   "AccessToken: \(accountManager.accessToken ?? "")",
                                                   "Email: \(accountManager.email ?? "")"].joined(separator: "\n") : nil
        showAlert(title: title, message: message)
    }

    @objc
    func validateToken() {
        Task {
            guard let token = accountManager.accessToken else { return }
            switch await AuthService.validateToken(accessToken: token) {
            case .success(let response):
                showAlert(title: "Validate token", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Validate token", message: "\(error)")
            }
        }
    }

    @objc
    func checkEntitlements() {
        Task {
            var results: [String] = []

            for entitlementName in ["fake", "dummy1", "dummy2", "dummy3"] {
                let result = await AccountManager().hasEntitlement(for: entitlementName)
                let resultSummary = "Entitlement check for \(entitlementName): \(result)"
                results.append(resultSummary)
                print(resultSummary)
            }

            showAlert(title: "Check Entitlements", message: results.joined(separator: "\n"))
        }
    }

    @objc
    func getSubscriptionInfo() {
        Task {
            guard let token = accountManager.accessToken else { return }
            switch await SubscriptionService.getSubscriptionInfo(token: token) {
            case .success(let response):
                showAlert(title: "Subscription info", message: "\(response)")
            case .failure(let error):
                showAlert(title: "Subscription info", message: "\(error)")
            }
        }
    }

    @available(macOS 12.0, *)
    @objc
    func syncAppleIDAccount() {
        Task {
            await purchaseManager.syncAppleIDAccount()
        }
    }

    @available(macOS 12.0, *)
    @objc
    func checkProductsAvailability() {
        Task {

            let result = await purchaseManager.hasProductsAvailable()
            showAlert(title: "Check App Store Product Availability",
                      message: "Can purchase: \(result ? "YES" : "NO")")
        }
    }

    @objc
    func restorePurchases(_ sender: Any?) {
        if #available(macOS 12.0, *) {
            Task {
                await AppStoreRestoreFlow.restoreAccountFromPastPurchase()
            }
        }
    }

    /*/
    @objc
    func testError1(_ sender: Any?) {
        Task { @MainActor in
            let alert = NSAlert.init()
            alert.messageText = "Something Went Wrong"
            alert.informativeText = "The App Store was not able to process your purchase. Please try again later."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    @objc
    func testError2(_ sender: Any?) {
        Task { @MainActor in
            let alert = NSAlert.init()
            alert.messageText = "Subscription Not Found"
            alert.informativeText = "The subscription associated with this Apple ID is no longer active."
            alert.addButton(withTitle: "View Plans")
            alert.addButton(withTitle: "Cancel")
            alert.runModal()
        }
    }

    @IBAction func showPurchaseView(_ sender: Any?) {
        if #available(macOS 12.0, *) {
            currentViewController()?.presentAsSheet(DebugPurchaseViewController())
        }
    }

    private func showAlert(title: String, message: String? = nil) {
        Task { @MainActor in
            let alert = NSAlert.init()
            alert.messageText = title
            if let message = message {
                alert.informativeText = message
            }
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    */
}
*/
