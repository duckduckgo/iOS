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

import Foundation
import NetworkExtension
class AppTPToggleViewModel: ObservableObject {
    
    var firewallManager: FirewallManaging
    
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
    
    func setStatus(to status: Bool) async throws {
        try await firewallManager.setState(to: status)
    }
}

extension AppTPToggleViewModel: FirewallDelegate {
    func statusDidChange(newStatus: NEVPNStatus) {
        firewallStatus = newStatus
    }
}
