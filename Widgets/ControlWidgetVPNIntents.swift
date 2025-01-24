//
//  ControlWidgetVPNIntents.swift
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

import AppIntents
import NetworkExtension
import NetworkProtection
import WidgetKit
import Core
import OSLog
import VPNWidgetSupport

// MARK: - Toggle

@available(iOS 17.0, *)
struct ControlWidgetToggleVPNIntent: SetValueIntent {

    private enum EnableAttemptFailure: CustomNSError, LocalizedError {
        case cancelled

        var errorDescription: String? {
            switch self {
            case .cancelled:
                return UserText.vpnNeedsToBeEnabledFromApp
            }
        }
    }

    static let title: LocalizedStringResource = "Toggle DuckDuckGo VPN from the Control Center Widget"
    static let description: LocalizedStringResource = "Toggles the DuckDuckGo VPN from the Control Center widget"
    static let isDiscoverable = false

    @Parameter(title: "Enabled")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        if value {
            try await startVPN()
        } else {
            try await stopVPN()
        }

        return .result()
    }

    private func startVPN() async throws {
        do {
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.start()

            await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            VPNReloadStatusWidgets()

            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectSuccess)
        } catch {
            switch error {
            case VPNWidgetTunnelController.StartFailure.vpnNotConfigured,
                // On update the VPN configuration becomes disabled, until started manually from
                // the app.
                NEVPNError.configurationDisabled:

                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectCancelled)
                throw EnableAttemptFailure.cancelled
            default:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectFailure, error: error)
                throw error
            }
        }
    }

    private func stopVPN() async throws {
        do {
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectAttempt)

            let controller = VPNWidgetTunnelController()
            try await controller.stop()

            await VPNSnoozeLiveActivityManager().endSnoozeActivity()
            VPNReloadStatusWidgets()

            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectSuccess)
        } catch {
            switch error {
            case VPNWidgetTunnelController.StopFailure.vpnNotConfigured:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectCancelled)
                throw error
            default:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectFailure, error: error)
                throw error
            }
        }
    }
}
