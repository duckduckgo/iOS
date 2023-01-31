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
        let task = session.dataTask(with: url!) { (data, response, error) in
            print("[INFO] Response from dummy URL while activating VPN")
        }
        print("[INFO] Calling dummy URL to force VPN")
        task.resume()
    }
    
    func status() -> NEVPNStatus {
        guard let manager = manager else {
            return .invalid
        }

        return manager.connection.status
    }
    
    func refreshManager(completion: @escaping (_ error: Error?) -> Void = {_ in }) {
        // get the reference to the latest manager in Settings
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) -> Void in
            if let managers = managers, managers.count > 0 {
                if (self.manager == managers[0]) {
                    print("[INFO] Already have a reference to this manager, not replacing it.")
                    completion(nil)
                    return
                }
                self.manager = nil
                self.manager = managers[0]
            }
            completion(error)
        }
    }
    
    func setState(to enabled: Bool, completion: @escaping (_ error: Error?) -> Void = {_ in }) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            self?.manager = nil
            if let managers = managers, managers.count > 0 {
                self?.manager = managers.first
            } else {
                // create manager instance
                self?.manager = NETunnelProviderManager()
                self?.manager?.protocolConfiguration = NETunnelProviderProtocol()
            }
            self?.manager?.localizedDescription = "DuckDuckGo AppTP"
            self?.manager?.protocolConfiguration?.serverAddress = "DuckDuckGo AppTP"
            self?.manager?.isEnabled = enabled
            self?.manager?.isOnDemandEnabled = enabled
            
            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = .any
            self?.manager?.onDemandRules = [connectRule]
            self?.manager?.saveToPreferences() { error in
                if let error = error as? NEVPNError {
                    print("[ERROR] Error setting VPN enabled to \(enabled) \(error)")
                    completion(nil)
                } else if let error = error {
                    completion(error)
                } else {
                    // Manually activate the tunnel
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if enabled {
                            print("[INFO] Starting VPN...")
                            do {
                                try self?.manager?.connection.startVPNTunnel()
                                self?.fireDummyRequest()
                                print("[INFO] Refreshing manager")
                                self?.refreshManager() { error in
                                    if let error = error {
                                        print("[ERROR] Error while refreshing manager: \(error)")
                                    } else {
                                        print("[OK] Refreshed manager")
                                    }
                                    completion(nil)
                                }
                                
                            } catch {
                                print("[ERROR] Error starting VPN after saving prefs: \(error.localizedDescription)")
                                completion(error)
                            }
                        } else {
                            print("[OK] VPN disabled no need to continue.")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
