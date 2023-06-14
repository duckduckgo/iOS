//
//  AppTrackingProtectionPacketTunnelProvider.swift
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

import NetworkExtension
import Common
import Core

public let generalLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "DDG AppTP", category: "DDG AppTP")

class AppTrackingProtectionPacketTunnelProvider: NEPacketTunnelProvider {

    let proxyServerPort: UInt16 = 9090
    let proxyServerAddress = "127.0.0.1"
    var proxyServer: GCDHTTPProxyServer!
    
    // Dispatch objects for memory warnings
    let dispatchSource: DispatchSourceMemoryPressure
    let dispatchQueue: DispatchQueue
    
    override init() {
        dispatchSource = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: nil)
        dispatchQueue = DispatchQueue.init(label: "AppTPMemoryPressure")
        
        super.init()
        
        dispatchQueue.async {
            self.dispatchSource.setEventHandler {
                let event: DispatchSource.MemoryPressureEvent = self.dispatchSource.mask
                print(event)
                switch event {
                case DispatchSource.MemoryPressureEvent.normal:
                    break
                case DispatchSource.MemoryPressureEvent.warning:
                    os_log("[ERROR] AppTP VPN memory warning", log: generalLog, type: .error)
                    Pixel.fire(pixel: .appTPVPNMemoryWarning)
                case DispatchSource.MemoryPressureEvent.critical:
                    os_log("[ERROR] AppTP VPN memory critical", log: generalLog, type: .error)
                    Pixel.fire(pixel: .appTPVPNMemoryCritical)
                default:
                    break
                }
                
            }
            self.dispatchSource.resume()
        }
    }
    
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("[AppTP] Starting tunnel...", log: generalLog, type: .debug)
        
        if proxyServer != nil {
            proxyServer.stop()
        }
        proxyServer = nil
        
        // Set up local proxy server to route requests that match the blocklist
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: proxyServerAddress)

        settings.mtu = NSNumber(value: 1500)
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: proxyServerAddress, port: Int(proxyServerPort))
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: proxyServerAddress, port: Int(proxyServerPort))
        proxySettings.excludeSimpleHostnames = false
        proxySettings.exceptionList = []
        
        // Get blocklist
        os_log("[AppTP] Loading blocklist", log: generalLog, type: .debug)
        let blocked = TrackerDataParser()
        proxySettings.matchDomains = blocked.flatDomainList()
        
        settings.dnsSettings = NEDNSSettings(servers: [proxyServerAddress])
        settings.proxySettings = proxySettings
        RawSocketFactory.TunnelProvider = self
        ObserverFactory.currentFactory = DDGObserverFactory()
        
        self.setTunnelNetworkSettings(settings) { error in
            if let error {
                Pixel.fire(pixel: .appTPFailedToSetTunnelNetworkSettings, error: error) { _ in
                    completionHandler(error)
                }

                return
            }

            self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: self.proxyServerAddress), port: Port(port: self.proxyServerPort))

            do {
                try self.proxyServer.start()
                completionHandler(nil)
            } catch {
                os_log("[ERROR] Error starting proxy server %s", log: generalLog, type: .error, error.localizedDescription)

                Pixel.fire(pixel: .appTPFailedToCreateProxyServer, error: error) { _ in
                    completionHandler(error)
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        RawSocketFactory.TunnelProvider = nil
        ObserverFactory.currentFactory = nil
        proxyServer.stop()
        proxyServer = nil

        Pixel.fire(pixel: .appTPVPNDisconnect, withAdditionalParameters: ["reason": String(reason.rawValue)]) { _ in
            completionHandler()
            exit(EXIT_SUCCESS)
        }
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        if let factory = ObserverFactory.currentFactory as? DDGObserverFactory {
            factory.refreshAllowlist()
            
            if let handler = completionHandler {
                handler(messageData)
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
    }
    
    override func wake() {
    }
}
