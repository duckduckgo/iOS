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
import WidgetKit

@available(iOS 17.0, *)
struct DisableVPNIntent: AppIntent {

    static let title: LocalizedStringResource = "Disable VPN"
    static let description: LocalizedStringResource = "Disables the DuckDuckGo VPN"
    static let openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else {
                return .result()
            }

            manager.isOnDemandEnabled = false
            try await manager.saveToPreferences()
            manager.connection.stopVPNTunnel()

            WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
            var iterations = 0

            while iterations <= 10 {
                try? await Task.sleep(interval: .seconds(0.5))

                if manager.connection.status == .disconnected {
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

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            guard let manager = managers.first else {
                return .result()
            }

            manager.isOnDemandEnabled = true
            try await manager.saveToPreferences()
            try manager.connection.startVPNTunnel()

            WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
            var iterations = 0

            while iterations <= 10 {
                try? await Task.sleep(interval: .seconds(0.5))

                if manager.connection.status == .connected {
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
