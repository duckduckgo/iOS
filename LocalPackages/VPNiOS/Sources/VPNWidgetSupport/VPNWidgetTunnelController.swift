//
//  VPNWidgetTunnelController.swift
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

import NetworkExtension

@available(iOS 17.0, *)
public struct VPNWidgetTunnelController: Sendable {

    public enum StartFailure: CustomNSError {
        case vpnNotConfigured
    }

    public enum StopFailure: CustomNSError {
        case vpnNotConfigured
    }

    public init() {}

    public var status: NEVPNStatus {
        get async {
            guard let manager = try? await NETunnelProviderManager.loadAllFromPreferences().first else {
                return .invalid
            }

            return manager.connection.status
        }
    }

    public func start() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first else {
            throw StartFailure.vpnNotConfigured
        }

        manager.isOnDemandEnabled = true
        try await manager.saveToPreferences()
        try manager.connection.startVPNTunnel()

        try await awaitUntilStatusIsNoLongerTransitioning(manager: manager)
    }

    public func stop() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        guard let manager = managers.first else {
            throw StopFailure.vpnNotConfigured
        }

        manager.isOnDemandEnabled = false
        try await manager.saveToPreferences()
        manager.connection.stopVPNTunnel()

        try await awaitUntilStatusIsNoLongerTransitioning(manager: manager)
    }

    private func awaitUntilStatusIsNoLongerTransitioning(manager: NETunnelProviderManager) async throws {

        let start = Date()

        while true {
            try await Task.sleep(for: .milliseconds(500))

            if abs(start.timeIntervalSinceNow) > 30
                || (manager.connection.status != .connecting && manager.connection.status != .disconnecting) {

                break
            }
        }
    }
}
