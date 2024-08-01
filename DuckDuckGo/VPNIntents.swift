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

@available(iOS 17.0, *)
struct DisableVPNIntent: AppIntent {

    static let title: LocalizedStringResource = "Disable VPN"
    static let description: LocalizedStringResource = "Disables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            DailyPixel.fire(pixel: .networkProtectionWidgetDisconnectAttempt)

            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else {
                return .result()
            }

            manager.isOnDemandEnabled = false
            try await manager.saveToPreferences()
            manager.connection.stopVPNTunnel()

            WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
            await VPNSnoozeLiveActivityManager().endSnoozeActivity()

            var iterations = 0

            while iterations <= 10 {
                try? await Task.sleep(interval: .seconds(0.5))

                if manager.connection.status == .disconnected {
                    DailyPixel.fire(pixel: .networkProtectionWidgetDisconnectSuccess)
                    return .result()
                }

                iterations += 1
            }

            return .result()
        } catch {
            return .result()
        }
    }

}

@available(iOS 17.0, *)
struct EnableVPNIntent: AppIntent {

    static let title: LocalizedStringResource = "Enable VPN"
    static let description: LocalizedStringResource = "Enables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            DailyPixel.fire(pixel: .networkProtectionWidgetConnectAttempt)

            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else {
                return .result()
            }

            manager.isOnDemandEnabled = true
            try await manager.saveToPreferences()
            try manager.connection.startVPNTunnel()

            WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
            await VPNSnoozeLiveActivityManager().endSnoozeActivity()

            var iterations = 0

            while iterations <= 10 {
                try? await Task.sleep(interval: .seconds(0.5))

                if manager.connection.status == .connected {
                    DailyPixel.fire(pixel: .networkProtectionWidgetConnectSuccess)
                    return .result()
                }

                iterations += 1
            }

            return .result()
        } catch {
            return .result()
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
            WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
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
        WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")

        return .result()
    }
}
