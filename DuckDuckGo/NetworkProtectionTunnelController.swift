//
//  NetworkProtectionTunnelController.swift
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

#if NETWORK_PROTECTION

import Foundation
import Combine
import Core
import NetworkExtension
import NetworkProtection

final class NetworkProtectionTunnelController: TunnelController {

    /// Starts the VPN connection used for Network Protection
    ///
    func start() async {
        do {
            try await startWithError()
        } catch {
            // Will handle this as part of https://app.asana.com/0/0/1205084446087081/f
        }
    }

    func stop() async {
        do {
            try await ConnectionSessionUtilities.activeSession()?.stopVPNTunnel()
        } catch {
            // Will handle this as part of https://app.asana.com/0/0/1205084446087081/f
        }
    }

    private let tokenStore = NetworkProtectionKeychainTokenStore(useSystemKeychain: false, errorEvents: nil)
    private let connectionObserver = ConnectionStatusObserverThroughSession()

    private func startWithError() async throws {
        let tunnelManager: NETunnelProviderManager

        do {
            tunnelManager = try await loadOrMakeTunnelManager()
        } catch {
            throw error
        }

        switch tunnelManager.connection.status {
        case .invalid:
            reloadTunnelManager()
            try await startWithError()
        case .connected:
            // Intentional no-op
            break
        default:
            try start(tunnelManager)
        }
    }

    /// Reloads the tunnel manager from preferences.
    ///
    private func reloadTunnelManager() {
        internalTunnelManager = nil
    }

    private func start(_ tunnelManager: NETunnelProviderManager) throws {
        var options = [String: NSObject]()

        options["activationAttemptId"] = UUID().uuidString as NSString
        options["authToken"] = try tokenStore.fetchToken() as NSString?

        do {
            try tunnelManager.connection.startVPNTunnel(options: options)
        } catch {
            throw error
        }
    }

    /// The actual storage for our tunnel manager.
    ///
    private var internalTunnelManager: NETunnelProviderManager?

    /// The tunnel manager: will try to load if it its not loaded yet, but if one can't be loaded from preferences,
    /// a new one will not be created.  This is useful for querying the connection state and information without triggering
    /// a VPN-access popup to the user.
    ///
    private var tunnelManager: NETunnelProviderManager? {
        get async {
            guard let tunnelManager = internalTunnelManager else {
                let tunnelManager = await loadTunnelManager()
                internalTunnelManager = tunnelManager
                return tunnelManager
            }

            return tunnelManager
        }
    }

    private func loadTunnelManager() async -> NETunnelProviderManager? {
        try? await NETunnelProviderManager.loadAllFromPreferences().first
    }

    private func loadOrMakeTunnelManager() async throws -> NETunnelProviderManager {
        guard let tunnelManager = await tunnelManager else {
            let tunnelManager = NETunnelProviderManager()
            try await setupAndSave(tunnelManager)
            internalTunnelManager = tunnelManager
            return tunnelManager
        }

        try await setupAndSave(tunnelManager)
        return tunnelManager
    }

    private func setupAndSave(_ tunnelManager: NETunnelProviderManager) async throws {
        try await setup(tunnelManager)
        try await tunnelManager.saveToPreferences()
        try await tunnelManager.loadFromPreferences()
        try await tunnelManager.saveToPreferences()
    }

    /// Setups the tunnel manager if it's not set up already.
    ///
    private func setup(_ tunnelManager: NETunnelProviderManager) async throws {
        tunnelManager.localizedDescription = "DuckDuckGo Network Protection"
        tunnelManager.isEnabled = true

        tunnelManager.protocolConfiguration = {
            let protocolConfiguration = NETunnelProviderProtocol()
            protocolConfiguration.serverAddress = "127.0.0.1" // Dummy address... the NetP service will take care of grabbing a real server

            // always-on
            protocolConfiguration.disconnectOnSleep = false

            return protocolConfiguration
        }()

        // reconnect on reboot
        tunnelManager.onDemandRules = [NEOnDemandRuleConnect()]
    }
}

#endif
