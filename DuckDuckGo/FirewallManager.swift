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

#if APP_TRACKING_PROTECTION

import Foundation
import NetworkExtension
import BrowserServicesKit
import Common

public protocol FirewallDelegate: AnyObject {
    func statusDidChange(newStatus: NEVPNStatus)
}

public protocol FirewallManaging {
    func status() -> NEVPNStatus
    func refreshManager() async
    func setState(to enabled: Bool) async throws
    var delegate: FirewallDelegate? { get set }
}

extension NEVPNStatus {
    var description: String {
        switch self {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnected:
            return "disconnected"
        case .disconnecting:
            return "disconnecting"
        case .invalid:
            return "invalid"
        case .reasserting:
            return "reasserting"
        default:
            return "unknown status"
        }
    }
}

public class FirewallManager: FirewallManaging {
    
    public static let apptpLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier, category: "AppTP")
    
    var manager: NETunnelProviderManager?
    public var delegate: FirewallDelegate?
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusDidChange),
                                               name: .NEVPNStatusDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
    }
    
    /**
     * Calling a request will help force the VPN to enable. We can use an invalid dummy URL to make things simple.
     */
    func fireDummyRequest() async {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        let url = URL(string: "https://bad_url")
        
        os_log("[INFO] Calling dummy URL to force VPN", log: FirewallManager.apptpLog, type: .debug)
        _ = try? await session.data(from: url!)
        os_log("[INFO] Response from dummy URL while activating VPN", log: FirewallManager.apptpLog, type: .debug)
    }
    
    public func status() -> NEVPNStatus {
        guard let manager = manager else {
            return .invalid
        }

        return manager.connection.status
    }
    
    @objc func statusDidChange() {
        // Uncomment this noisy line to debug status changes
//        os_log("[INFO] VPN status changed: %s", log: FirewallManager.apptpLog, type: .debug, status().description)
//        if status() == .disconnected || status() == .disconnecting {
//            if #available(iOSApplicationExtension 16.0, *) {
//                manager?.connection.fetchLastDisconnectError { err in
//                    if let err = err {
//                        os_log("Last disconnect error: %s", log: FirewallManager.apptpLog, type: .error, err.localizedDescription)
//                    }
//                }
//            }
//        }
        
        delegate?.statusDidChange(newStatus: status())
    }
    
    public func refreshManager() async {
        // get the reference to the latest manager in Settings
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            if let manager = managers.first {
                if self.manager == manager {
                    os_log("[INFO] Already have a reference to this manager, not replacing it.",
                           log: FirewallManager.apptpLog, type: .debug)
                    return
                }
                
                self.manager = nil
                self.manager = manager
                statusDidChange()
            }
        } catch {
            #if !targetEnvironment(simulator)
                Pixel.fire(pixel: .appTPFailedToAccessPreferences, error: error)
            #endif

            os_log("[ERROR] Could not load managers", log: FirewallManager.apptpLog, type: .error)
        }
    }
    
    public func notifyAllowlistChange() async {
        await refreshManager()
        guard let manager = self.manager else {
            os_log("[ERROR] Could not load managers", log: FirewallManager.apptpLog, type: .error)
            return
        }
        guard let session = manager.connection as? NETunnelProviderSession else {
            os_log("[ERROR] Could not get tunnel session", log: FirewallManager.apptpLog, type: .error)
            return
        }
        guard let messageData = "Refresh Allowlist".data(using: .utf8) else {
            os_log("[ERROR] Could not create message data", log: FirewallManager.apptpLog, type: .error)
            return
        }
        
        do {
            try session.sendProviderMessage(messageData) { data in
                if let data = data, let message = String(data: data, encoding: .utf8) {
                    print(message)
                }
            }
        } catch {
            os_log("[ERROR] Error sending message to tunnel: %s", log: FirewallManager.apptpLog, type: .error, error.localizedDescription)
        }
    }
    
    public func setState(to enabled: Bool) async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        manager = nil
        if managers.count > 0 {
            manager = managers.first
            
            if manager?.isEnabled == enabled {
                // Prevent unnecessarily modifying the VPN configuration
                return
            }
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
            Pixel.fire(pixel: .appTPFailedToAccessPreferencesDuringSetup, error: error)

            if let error = error as? NEVPNError {
                // Trigger .invalid status when there's an error setting preferences
                // This will notify viewModels there was a failure
                manager = nil
                statusDidChange()
                
                os_log("[ERROR] Error setting VPN enabled to %s %s",
                       log: FirewallManager.apptpLog, type: .debug, String(enabled), error.localizedDescription)
                throw error
            }
        }
        
        // Manually activate the tunnel
        guard enabled else { return }
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                os_log("[INFO] Starting VPN...", log: FirewallManager.apptpLog, type: .debug)
                
                do {
                    try manager?.connection.startVPNTunnel()
                    await fireDummyRequest()
                    os_log("[INFO] Refreshing manager", log: FirewallManager.apptpLog, type: .debug)
                    await refreshManager()
                        
                    os_log("[OK] Refreshed manager", log: FirewallManager.apptpLog, type: .debug)
                    continuation.resume()
                    
                } catch {
                    Pixel.fire(pixel: .appTPFailedToStartTunnel, error: error)

                    os_log("[ERROR] Error starting VPN after saving prefs: %s",
                           log: FirewallManager.apptpLog, type: .error, error.localizedDescription)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

#endif
