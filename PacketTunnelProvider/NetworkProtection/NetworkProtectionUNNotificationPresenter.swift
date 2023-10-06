//
//  NetworkProtectionUNNotificationPresenter.swift
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
import NetworkProtection
import Core

/// This class takes care of requesting the presentation of notifications using UNNotificationCenter
///
final class NetworkProtectionUNNotificationPresenter: NSObject, NetworkProtectionNotificationsPresenter {

    private let userNotificationCenter: UNUserNotificationCenter

    private var threadIdentifier: String {
        let bundleId = Bundle(for: Self.self).bundleIdentifier ?? "com.duckduckgo.mobile.ios.NetworkExtension"
        return bundleId + ".threadIdentifier"
    }

    init(userNotificationCenter: UNUserNotificationCenter = .current()) {
        self.userNotificationCenter = userNotificationCenter

        super.init()
    }

    // MARK: - Setup

    func requestAuthorization() {
        userNotificationCenter.delegate = self
        requestAlertAuthorization()
    }

    // MARK: - Notification Utility methods

    private func requestAlertAuthorization(completionHandler: ((Bool) -> Void)? = nil) {
        let options: UNAuthorizationOptions = .alert

        userNotificationCenter.requestAuthorization(options: options) { authorized, _ in
            completionHandler?(authorized)
        }
    }

    private func notificationContent(body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()

        content.threadIdentifier = threadIdentifier
        content.title = UserText.networkProtectionNotificationsTitle
        content.body = body

        if #available(iOSApplicationExtension 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 0
        }

        return content
    }

    func showTestNotification() {
        // Debug only string. Doesn't need localized
        let content = notificationContent(body: "Test notification")
        showNotification(.test, content)
    }

    func showConnectedNotification(serverLocation: String?) {
        let body: String
        if let serverLocation {
            body = UserText.networkProtectionConnectionSuccessNotificationBody(serverLocation: serverLocation)
        } else {
            body = UserText.networkProtectionConnectionSuccessNotificationBody
        }
        let content = notificationContent(body: body)
        showNotification(.connection, content)
    }

    func showConnectionNotification(serverLocation: String?) {
        let content = notificationContent(body: UserText.networkProtectionConnectionSuccessNotificationBody)
        showNotification(.connection, content)
    }

    func showReconnectingNotification() {
        let content = notificationContent(body: UserText.networkProtectionConnectionInterruptedNotificationBody)
        showNotification(.connection, content)
    }

    func showConnectionFailureNotification() {
        let content = notificationContent(body: UserText.networkProtectionConnectionFailureNotificationBody)
        showNotification(.connection, content)
    }

    func showSupersededNotification() {
    }

    private func showNotification(_ identifier: NetworkProtectionNotificationIdentifier, _ content: UNNotificationContent) {
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: .none)

        requestAlertAuthorization { authorized in
            guard authorized else {
                return
            }
            self.userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier.rawValue])
            self.userNotificationCenter.add(request)
        }
    }
}

extension NetworkProtectionUNNotificationPresenter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return .banner
    }
}
