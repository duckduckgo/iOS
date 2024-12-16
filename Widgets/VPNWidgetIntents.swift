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

// MARK: - Enable & Disable

/// App intent to disable the VPN
///
/// This is used in our Widget only.
/// This is very similar to ``DisableVPNAppIntent``, but this can run in both widget and app,
/// does not support continuation in the app and does not provide any result dialog.
///
@available(iOS 17.0, *)
struct VPNWidgetDisableIntent: AppIntent {

    private enum DisableAttemptFailure: CustomNSError {
        case cancelled
    }

    static let title: LocalizedStringResource = "Disable DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Disables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectAttempt)

            let controller = VPNIntentTunnelController()
            try await controller.stop()

            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectSuccess)
            return .result()
        } catch VPNIntentTunnelController.StopFailure.vpnNotConfigured {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectCancelled)
            return .result()
        } catch {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetDisconnectFailure, error: error)
            throw error
        }
    }
}

/// App intent to disable the VPN
///
/// This is used in our Widget only.
/// This is very similar to ``DisableVPNAppIntent``, but this can run in both widget and app,
/// does not support continuation in the app and does not provide any result dialog.
///
@available(iOS 17.0, *)
struct VPNWidgetEnableIntent: AppIntent {
    static let title: LocalizedStringResource = "Enable DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Enables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = true
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectAttempt)

            let controller = VPNIntentTunnelController()
            try await controller.start()

            DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectSuccess)
            return .result()
        } catch {
            switch error {
            case VPNIntentTunnelController.StartFailure.vpnNotConfigured:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectCancelled)
                throw error
            default:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectFailure, error: error)
                throw error
            }
        }
    }
}

// MARK: - Snooze

@available(iOS 17.0, *)
struct CancelSnoozeVPNIntent: AppIntent {

    static let title: LocalizedStringResource = "Resume VPN"
    static let description: LocalizedStringResource = "Resumes the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first, let session = manager.connection as? NETunnelProviderSession else {
                return .result()
            }

            try? await session.sendProviderMessage(.cancelSnooze)
            VPNReloadStatusWidgets()
            await VPNSnoozeLiveActivityManager().endSnoozeActivity()

            return .result()
        } catch {
            return .result()
        }
    }

}

@available(iOS 17.0, *)
struct CancelSnoozeLiveActivityAppIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "Cancel Snooze"
    static var isDiscoverable: Bool = false
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first, let session = manager.connection as? NETunnelProviderSession else {
            return .result()
        }

        try? await session.sendProviderMessage(.cancelSnooze)
        await VPNSnoozeLiveActivityManager().endSnoozeActivity()
        VPNReloadStatusWidgets()

        return .result()
    }
}
