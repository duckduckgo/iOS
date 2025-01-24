//
//  VPNService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import NetworkProtection
import Subscription
import UIKit
import NotificationCenter
import Core

final class VPNService: NSObject {

    private let tunnelController = AppDependencyProvider.shared.networkProtectionTunnelController
    private let widgetRefreshModel = NetworkProtectionWidgetRefreshModel()
    private let tunnelDefaults = UserDefaults.networkProtectionGroupDefaults

    private lazy var vpnWorkaround: VPNRedditSessionWorkaround = VPNRedditSessionWorkaround(accountManager: accountManager,
                                                                                            tunnelController: tunnelController)
    private let vpnFeatureVisibility: DefaultNetworkProtectionVisibility = AppDependencyProvider.shared.vpnFeatureVisibility

    private let window: UIWindow
    private let accountManager: AccountManager
    private let application: UIApplication
    init(window: UIWindow,
         accountManager: AccountManager = AppDependencyProvider.shared.accountManager,
         application: UIApplication = UIApplication.shared,
         notificationCenter: UNUserNotificationCenter = .current()) {
        self.window = window
        self.accountManager = accountManager
        self.application = application
        super.init()

        notificationCenter.delegate = self
    }

    func beginObservingVPNStatus() {
        widgetRefreshModel.beginObservingVPNStatus()
    }

    func installRedditSessionWorkaround(autoClearTask: Task<Void, Never>? = nil) async { // TODO: optional just for now, but we always have to pass autoClearTask
        await autoClearTask?.value
        await vpnWorkaround.installRedditSessionWorkaround()
    }

    func onForeground(autoClearTask: Task<Void, Never>? = nil, // TODO: optional just for now, but we always have to pass autoClearTask
                      mainViewController: MainViewController) {
        refreshVPNWidget()
        presentExpiredEntitlementAlertIfNeeded(mainViewController: mainViewController)
        presentExpiredEntitlementNotificationIfNeeded()

        Task {
            await stopAndRemoveVPNIfNotAuthenticated()
            await refreshVPNShortcuts()
            await installRedditSessionWorkaround(autoClearTask: autoClearTask)

            if #available(iOS 17.0, *) {
                await VPNSnoozeLiveActivityManager().endSnoozeActivityIfNecessary()
            }
        }
    }

    func onSuspending() {
        Task { @MainActor in
            await application.refreshVPNShortcuts(vpnFeatureVisibility: vpnFeatureVisibility,
                                                  accountManager: accountManager)
            await vpnWorkaround.removeRedditSessionWorkaround()
        }
    }

    private func refreshVPNWidget() {
        widgetRefreshModel.refreshVPNWidget()
    }

    private func presentExpiredEntitlementNotificationIfNeeded() {
        let presenter = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: AppDependencyProvider.shared.vpnSettings,
            defaults: .networkProtectionGroupDefaults,
            wrappee: NetworkProtectionUNNotificationPresenter()
        )
        presenter.showEntitlementNotification()
    }

    private func presentExpiredEntitlementAlertIfNeeded(mainViewController: MainViewController) {
        if tunnelDefaults.showEntitlementAlert {
            presentExpiredEntitlementAlert(mainViewController: mainViewController)
        }
    }

    private func presentExpiredEntitlementAlert(mainViewController: MainViewController) {
        let alertController = CriticalAlerts.makeExpiredEntitlementAlert {
            mainViewController.segueToPrivacyPro()
        }
        application.window?.rootViewController?.present(alertController, animated: true) {
            self.tunnelDefaults.showEntitlementAlert = false
        }
    }

    private func stopAndRemoveVPNIfNotAuthenticated() async {
        // Only remove the VPN if the user is not authenticated, and it's installed:
        guard !accountManager.isUserAuthenticated, await tunnelController.isInstalled else {
            return
        }

        await tunnelController.stop()
        await tunnelController.removeVPN(reason: .didBecomeActiveCheck)
    }

    @MainActor
    private func refreshVPNShortcuts() async {
        guard vpnFeatureVisibility.shouldShowVPNShortcut(),
              case .success(true) = await accountManager.hasEntitlement(forProductName: .networkProtection,
                                                                        cachePolicy: .returnCacheDataDontLoad)
        else {
            application.shortcutItems = nil
            return
        }

        application.shortcutItems = [
            UIApplicationShortcutItem(type: AppDelegate.ShortcutKey.openVPNSettings,
                                      localizedTitle: UserText.netPOpenVPNQuickAction,
                                      localizedSubtitle: nil,
                                      icon: UIApplicationShortcutIcon(templateImageName: "VPN-16"),
                                      userInfo: nil)
        ]
    }

}

extension VPNService: UNUserNotificationCenterDelegate {

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

    // TODO: should be moved to (future) AppCoordinator
    private func presentNetworkProtectionStatusSettingsModal() {
        Task { @MainActor in
            if case .success(let hasEntitlements) = await accountManager.hasEntitlement(forProductName: .networkProtection), hasEntitlements {
                (window.rootViewController as? MainViewController)?.segueToVPN()
            } else {
                (window.rootViewController as? MainViewController)?.segueToPrivacyPro()
            }
        }
    }

}
