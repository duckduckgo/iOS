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
import OSLog

// MARK: - Toggle

/// `ForegroundContinuableIntent` isn't available for extensions, which makes it impossible to call
/// from extensions.  This is the recommended workaround from:
///     https://mastodon.social/@mgorbach/110812347476671807
///
@available(iOS 17.0, *)
struct VPNToggleIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Toggles the DuckDuckGo VPN"
    static let isDiscoverable: Bool = false

    @Parameter(title: "Enabled")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        if value {
            try await startVPN()
            return .result()
        } else {
            try await stopVPN()
            return .result()
        }
    }

    private func startVPN() async throws {
        do {
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectAttempt)

            let controller = VPNIntentTunnelController()
            try await controller.start()
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectSuccess)
        } catch {
            switch error {
            case VPNIntentTunnelController.StartFailure.vpnNotConfigured:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectCancelled)

                throw error
            default:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterConnectFailure, error: error)
                throw error
            }
        }
    }

    private func stopVPN() async throws {
        do {
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectAttempt)

            let controller = VPNIntentTunnelController()
            try await controller.stop()
            DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectSuccess)
        } catch {
            switch error {
            case VPNIntentTunnelController.StopFailure.vpnNotConfigured:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectCancelled)
                throw error
            default:
                DailyPixel.fireDailyAndCount(pixel: .vpnControlCenterDisconnectFailure, error: error)
                throw error
            }
        }
    }
}
