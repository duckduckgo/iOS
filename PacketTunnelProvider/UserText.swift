//
//  UserText.swift
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

import Foundation

// swiftlint:disable line_length
final class UserText {

    // MARK: - Network Protection Notifications

    static let networkProtectionNotificationsTitle = NSLocalizedString("network.protection.notification.title", value: "DuckDuckGo", comment: "The title of the notifications shown from Network Protection")

    static let networkProtectionConnectionSuccessNotificationBody = NSLocalizedString("network.protection.success.notification.body", value: "Network Protection is On. Your location and online activity are protected.", comment: "The body of the notification shown when Network Protection reconnects successfully")

    static func networkProtectionConnectionSuccessNotificationBody(serverLocation: String) -> String {
        let localized = NSLocalizedString(
            "network.protection.success.notification.subtitle.including.serverLocation",
            value: "Routing device traffic through %@.",
            comment: "The body of the notification shown when Network Protection connects successfully with the city + state/country as formatted parameter"
        )
        return String(format: localized, serverLocation)
    }

    static let networkProtectionConnectionInterruptedNotificationBody = NSLocalizedString("network.protection.interrupted.notification.body", value: "Network Protection was interrupted. Attempting to reconnect now...", comment: "The body of the notification shown when Network Protection's connection is interrupted")

    static let networkProtectionConnectionFailureNotificationBody = NSLocalizedString("network.protection.failure.notification.body", value: "Network Protection failed to connect. Please try again later.", comment: "The body of the notification shown when Network Protection fails to reconnect")
}
// swiftlint:enable line_length
