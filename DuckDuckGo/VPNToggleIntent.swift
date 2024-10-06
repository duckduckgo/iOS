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

// MARK: - Toggle

@available(iOS 17.0, *)
struct VPNToggleIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Toggle DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Toggles the DuckDuckGo VPN"

    @Parameter(title: "Enabled")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        if value {
            try await enableVPN()
        } else {
            try await disableVPN()
        }

        await VPNSnoozeLiveActivityManager().endSnoozeActivity()

        return .result()
    }

    func enableVPN() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first else {
            return
        }

        manager.isOnDemandEnabled = true
        try await manager.saveToPreferences()
        try manager.connection.startVPNTunnel()
    }

    func disableVPN() async throws {
        do {
            //DailyPixel.fire(pixel: .networkProtectionWidgetDisconnectAttempt)

            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else {
                return
            }

            //manager.connection.status

            manager.isOnDemandEnabled = false
            try await manager.saveToPreferences()
            manager.connection.stopVPNTunnel()

            await VPNSnoozeLiveActivityManager().endSnoozeActivity()

            var iterations = 0

            while iterations <= 10 {
                try? await Task.sleep(interval: .seconds(0.5))

                if manager.connection.status == .disconnected {
                    //DailyPixel.fire(pixel: .networkProtectionWidgetDisconnectSuccess)
                    return
                }

                iterations += 1
            }

            VPNReloadStatusWidgets()
        } catch {
            // no-op
        }
    }
}
