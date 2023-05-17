//
//  AppTPToggleViewModel.swift
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

#if APP_TRACKING_PROTECTION

import Foundation
import Core
import NetworkExtension
import Common

class AppTPToggleViewModel: ObservableObject {
    
    var firewallManager: FirewallManaging
    
    @Published var isOn: Bool = false
    @Published var connectFirewall: Bool = false
    
    @Published var firewallStatus: NEVPNStatus = .disconnected
    
    init(firewallManager: FirewallManaging = FirewallManager()) {
        self.firewallManager = firewallManager
        self.firewallManager.delegate = self
    }
    
    func status() -> NEVPNStatus {
        return firewallManager.status()
    }
    
    func refreshManager() async {
        await firewallManager.refreshManager()
    }
    
    func changeFirewallStatus() async {
        os_log("VPN status change requested: %s", log: FirewallManager.apptpLog, type: .info, String(connectFirewall))
        if status() == .connecting || status() == .disconnecting {
            // Don't change status while we're busy
            return
        }
        
        do {
            try await firewallManager.setState(to: connectFirewall)
            let status = status()
            Task { @MainActor in
                isOn = status == .connected || status == .connecting
            }
        } catch {
            os_log("Error changing VPN status", log: FirewallManager.apptpLog, type: .error)
        }
    }
    
    func isLoading() -> Bool {
        return firewallStatus != .connected && firewallStatus != .disconnected && firewallStatus != .invalid
    }
}

extension AppTPToggleViewModel: FirewallDelegate {
    func statusDidChange(newStatus: NEVPNStatus) {
        Task { @MainActor in
            // Don't react to status changes that are the same
            if newStatus == firewallStatus {
                return
            }
            
            firewallStatus = newStatus
            if newStatus == .connected || newStatus == .disconnected {
                connectFirewall = newStatus == .connected
                isOn = connectFirewall
            }
        }
    }
}

#endif
