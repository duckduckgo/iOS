//
//  DDGObserverFactory.swift
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

struct BlockedReason: Error {
    var description: String {
        return "Blocked"
    }
}

class DDGObserverFactory: ObserverFactory {
    
    var trackerData: TrackerDataParser?
    
    override func getObserverForProxySocket(_ socket: ProxySocket) -> Observer<ProxySocketEvent>? {
        return nil
    }
    
    override init() {
        trackerData = TrackerDataParser()
    }
    
    class DDGProxySocketObserver: Observer<ProxySocketEvent> {
        
        var trackerData: TrackerDataParser?
        
        init(trackerData: TrackerDataParser? = nil) {
            self.trackerData = trackerData
        }
        
        /// Main listener. This is called whenever a request is made that matches the domains passed to the proxy
        override func signal(_ event: ProxySocketEvent) {
            switch event {
            case .receivedRequest(let session, let socket):
                // Check for allowlisted trackers
                
                // Check firewall status
                if let trackerData = trackerData, trackerData.shouldBlock(domain: session.host) {
                    print("[BLOCKED] \(session.host) on blocklist")
                    socket.forceDisconnect(becauseOf: BlockedReason())
                }
                
                return
            default:
                break
            }
        }
    }
    
}
