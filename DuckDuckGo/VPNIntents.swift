//
//  VPNIntents.swift
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

import AppIntents
import NetworkExtension
import NetworkProtection
import WidgetKit
import Core
import VPNWidgetSupport

// MARK: - Enable & Disable

/// App intent to disable the VPN
///
/// This is used in App Shortcuts, for things like Shortcuts.app, Spotlight and Siri.
/// This is very similar to ``WidgetDisableVPNIntent``, but this runs in-app, allows continuation in the app if needed,
/// and provides a result dialog.
///
@available(iOS 17.0, *)
struct DisableVPNIntent: AppIntent {

    private enum DisableAttemptFailure: CustomNSError {
        case cancelled
    }

    static let title: LocalizedStringResource = "Disable DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Disables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.stop()

            await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            VPNReloadStatusWidgets()

            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectSuccess)
            return .result(dialog: "DuckDuckGo VPN is disconnecting...")
        } catch VPNWidgetTunnelController.StopFailure.vpnNotConfigured {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectCancelled)
            return .result(dialog: "The DuckDuckGo VPN is not connected")
        } catch {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectFailure, error: error)
            throw error
        }
    }
}

/// App intent to enable the VPN
///
/// This is used in App Shortcuts, for things like Shortcuts.app, Spotlight and Siri.
/// This is very similar to ``WidgetEnableVPNIntent``, but this runs in-app, allows continuation in the app if needed,
/// and provides a result dialog.
///
@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
struct EnableVPNIntent: ForegroundContinuableIntent {
    static let title: LocalizedStringResource = "Enable DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Enables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.start()

            await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            VPNReloadStatusWidgets()

            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectSuccess)
            return .result(dialog: "DuckDuckGo VPN is connecting...")
        } catch {
            switch error {
            case VPNWidgetTunnelController.StartFailure.vpnNotConfigured:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectCancelled)

                let dialog = IntentDialog(stringLiteral: UserText.vpnNeedsToBeEnabledFromApp)
                throw needsToContinueInForegroundError(dialog) {
                    await UIApplication.shared.open(AppDeepLinkSchemes.openVPN.url)
                }
            default:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectFailure, error: error)

                throw error
            }
        }
    }
}
