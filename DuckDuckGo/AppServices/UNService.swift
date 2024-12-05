//
//  UNService.swift
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

import Foundation
import NotificationCenter
import Core
import Subscription

final class UNService: NSObject {

    let window: () -> UIWindow? // possibly non optional
    let accountManager: AccountManager

    init(window: @autoclosure @escaping () -> UIWindow?,
         accountManager: AccountManager) {
        self.window = window
        self.accountManager = accountManager
    }

}

extension UNService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let identifier = response.notification.request.identifier

            if NetworkProtectionNotificationIdentifier(rawValue: identifier) != nil {
                presentNetworkProtectionStatusSettingsModal()
            }
        }

        completionHandler()
    }

    private func presentNetworkProtectionStatusSettingsModal() {
        Task { @MainActor in
            if case .success(let hasEntitlements) = await accountManager.hasEntitlement(forProductName: .networkProtection), hasEntitlements {
                (window()?.rootViewController as? MainViewController)?.segueToVPN()
            } else {
                (window()?.rootViewController as? MainViewController)?.segueToPrivacyPro()
            }
        }
    }

    private func presentSettings(with viewController: UIViewController) {
        guard let window = window(), let rootViewController = window.rootViewController as? MainViewController else { return }

        if let navigationController = rootViewController.presentedViewController as? UINavigationController {
            if let lastViewController = navigationController.viewControllers.last, lastViewController.isKind(of: type(of: viewController)) {
                // Avoid presenting dismissing and re-presenting the view controller if it's already visible:
                return
            } else {
                // Otherwise, replace existing view controllers with the presented one:
                navigationController.popToRootViewController(animated: false)
                navigationController.pushViewController(viewController, animated: false)
                return
            }
        }

        // If the previous checks failed, make sure the nav stack is reset and present the view controller from scratch:
        rootViewController.clearNavigationStack()

        // Give the `clearNavigationStack` call time to complete.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            rootViewController.segueToSettings()
            let navigationController = rootViewController.presentedViewController as? UINavigationController
            navigationController?.popToRootViewController(animated: false)
            navigationController?.pushViewController(viewController, animated: false)
        }
    }
}
