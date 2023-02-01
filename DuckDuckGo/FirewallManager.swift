//
//  FirewallManager.swift
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

import Foundation
import NetworkExtension
import Core
import os.log

class FirewallController {
    static let shared = FirewallController()
    
    var manager: NETunnelProviderManager?
    
    /**
     * Calling a request will help force the VPN to enable. We can use an invalid dummy URL to make things simple.
     */
    func fireDummyRequest() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        let url = URL(string: "https://bad_url")
        let task = session.dataTask(with: url!) { _, _, _ in
            os_log("[AppTP][INFO] Response from dummy URL while activating VPN", log: generalLog, type: .debug)
        }
        os_log("[AppTP][INFO] Calling dummy URL to force VPN", log: generalLog, type: .debug)
        task.resume()
    }
    
    func status() -> NEVPNStatus {
        guard let manager = manager else {
            return .invalid
        }

        return manager.connection.status
    }
    
    func refreshManager() async {
        // get the reference to the latest manager in Settings
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            if let manager = managers.first {
                if self.manager == manager {
                    os_log("[AppTP][INFO] Already have a reference to this manager, not replacing it.",
                           log: generalLog, type: .debug)
                    return
                }
                
                self.manager = nil
                self.manager = manager
            }
        } catch {
            os_log("[AppTP][ERROR] Could not load managers", log: generalLog, type: .error)
        }
    }
    
    func setState(to enabled: Bool) async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        manager = nil
        if managers.count > 0 {
            manager = managers.first
        } else {
            // create manager instance
            manager = NETunnelProviderManager()
            manager?.protocolConfiguration = NETunnelProviderProtocol()
        }
        manager?.localizedDescription = "DuckDuckGo AppTP"
        manager?.protocolConfiguration?.serverAddress = "DuckDuckGo AppTP"
        manager?.isEnabled = enabled
        manager?.isOnDemandEnabled = enabled
        
        let connectRule = NEOnDemandRuleConnect()
        connectRule.interfaceTypeMatch = .any
        manager?.onDemandRules = [connectRule]
        
        do {
            try await manager?.saveToPreferences()
            try await manager?.loadFromPreferences() // Load again to avoid NEVPNError Code=1
            
        } catch {
            if let error = error as? NEVPNError {
                os_log("[AppTP][ERROR] Error setting VPN enabled to %s %s",
                       log: generalLog, type: .debug, String(enabled), error.localizedDescription)
                throw error
            }
        }
        
        // Manually activate the tunnel
        guard enabled else { return }
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                os_log("[AppTP][INFO] Starting VPN...", log: generalLog, type: .debug)
                do {
                    try manager?.connection.startVPNTunnel()
                    fireDummyRequest()
                    os_log("[AppTP][INFO] Refreshing manager", log: generalLog, type: .debug)
                    await refreshManager()
                        
                    os_log("[AppTP][OK] Refreshed manager", log: generalLog, type: .debug)
                    continuation.resume()
                    
                } catch {
                    os_log("[AppTP][ERROR] Error starting VPN after saving prefs: %s",
                           log: generalLog, type: .error, error.localizedDescription)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
