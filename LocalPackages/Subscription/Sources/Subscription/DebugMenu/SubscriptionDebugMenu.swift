//
//  SubscriptionDebugMenu.swift
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

import AppKit
import Account
import Purchase

public final class SubscriptionDebugMenu: NSMenuItem {

    var currentViewController: () -> NSViewController?
    private let accountManager = AccountManager()

    private var _purchaseManager: Any?
    @available(macOS 12.0, *)
    fileprivate var purchaseManager: PurchaseManager {
        if _purchaseManager == nil {
            _purchaseManager = PurchaseManager()
        }
        // swiftlint:disable:next force_cast
        return _purchaseManager as! PurchaseManager
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(currentViewController: @escaping () -> NSViewController?) {
        self.currentViewController = currentViewController
        super.init(title: "Subscription", action: nil, keyEquivalent: "")
        self.submenu = submenuItem
    }

    private lazy var submenuItem: NSMenu = {
        let menu = NSMenu(title: "")

        menu.addItem(NSMenuItem(title: "Simulate Subscription Active State (fake token)", action: #selector(simulateSubscriptionActiveState), target: self))
        menu.addItem(NSMenuItem(title: "Clear Subscription Authorization Data", action: #selector(signOut), target: self))
        menu.addItem(NSMenuItem(title: "Show account details", action: #selector(showAccountDetails), target: self))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Validate Token", action: #selector(validateToken), target: self))
        menu.addItem(NSMenuItem(title: "Check Entitlements", action: #selector(checkEntitlements), target: self))
        menu.addItem(NSMenuItem(title: "Get Subscription Info", action: #selector(getSubscriptionInfo), target: self))
        if #available(macOS 12.0, *) {
            menu.addItem(NSMenuItem(title: "Check Purchase Products Availability", action: #selector(checkProductsAvailability), target: self))
        }
        menu.addItem(NSMenuItem(title: "Restore Subscription from App Store transaction", action: #selector(restorePurchases), target: self))
        menu.addItem(.separator())
        if #available(macOS 12.0, *) {
            menu.addItem(NSMenuItem(title: "Sync App Store AppleID Account (re- sign-in)", action: #selector(syncAppleIDAccount), target: self))
            menu.addItem(NSMenuItem(title: "Purchase Subscription from App Store", action: #selector(showPurchaseView), target: self))
        }
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Error message #1", action: #selector(testError1), target: self))
        menu.addItem(NSMenuItem(title: "Error message #2", action: #selector(testError2), target: self))
        return menu
    }()

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
}

extension NSMenuItem {

    convenience init(title string: String, action selector: Selector?, target: AnyObject?, keyEquivalent charCode: String = "", representedObject: Any? = nil) {
        self.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = target
        self.representedObject = representedObject
    }
}
