//
//  VPNIntentTunnelController.swift
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

import Core
import NetworkExtension

@available(iOS 17.0, *)
struct VPNIntentTunnelController {

    enum StartFailure: CustomNSError {
        case vpnNotConfigured
    }

    enum StopFailure: CustomNSError {
        case vpnNotConfigured
    }

    func start() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first else {
            throw StartFailure.vpnNotConfigured
        }

        manager.isOnDemandEnabled = true
        try await manager.saveToPreferences()
        try manager.connection.startVPNTunnel()

        await VPNSnoozeLiveActivityManager().endSnoozeActivity()

        VPNReloadStatusWidgets()
    }

    func stop() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first else {
            throw StopFailure.vpnNotConfigured
        }

        manager.isOnDemandEnabled = false
        try await manager.saveToPreferences()
        manager.connection.stopVPNTunnel()

        await VPNSnoozeLiveActivityManager().endSnoozeActivity()

        VPNReloadStatusWidgets()
    }
}
