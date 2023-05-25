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
import Persistence
import Core
import Common

struct BlockedReason: Error {
    var description: String {
        return "Blocked"
    }
}

class DDGObserverFactory: ObserverFactory {
    
    private var trackerData: TrackerDataParser?
    private var allowlist: AppTrackingProtectionAllowlistModel?
    private let appTrackingProtectionDatabase: CoreDataDatabase
    private let appTrackingProtectionStoringModel: AppTrackingProtectionStoringModel
    
    private var observer: DDGProxySocketObserver?
    
    override func getObserverForProxySocket(_ socket: ProxySocket) -> Observer<ProxySocketEvent>? {
        return observer
    }
    
    override init() {
        trackerData = TrackerDataParser()
        allowlist = AppTrackingProtectionAllowlistModel()
        appTrackingProtectionDatabase = AppTrackingProtectionDatabase.make()
        appTrackingProtectionDatabase.loadStore { context, error in
            guard context != nil else {
                fatalError("Could not create AppTP database stack: \(error?.localizedDescription ?? "err")")
            }
        }

        appTrackingProtectionStoringModel = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: appTrackingProtectionDatabase)
        appTrackingProtectionStoringModel.removeStaleEntries()
        
        observer = DDGProxySocketObserver(trackerData: trackerData,
                                          allowlist: allowlist,
                                          appTrackingProtectionStoringModel: appTrackingProtectionStoringModel)
    }
    
    func refreshAllowlist() {
        allowlist?.readFromFile()
        observer?.allowlist = allowlist
    }
    
    class DDGProxySocketObserver: Observer<ProxySocketEvent> {
        
        private var trackerData: TrackerDataParser?
        public var allowlist: AppTrackingProtectionAllowlistModel?
        private let appTrackingProtectionStoringModel: AppTrackingProtectionStoringModel
        
        init(trackerData: TrackerDataParser? = nil, allowlist: AppTrackingProtectionAllowlistModel?, appTrackingProtectionStoringModel: AppTrackingProtectionStoringModel) {
            self.trackerData = trackerData
            self.allowlist = allowlist
            self.appTrackingProtectionStoringModel = appTrackingProtectionStoringModel
        }
        
        /// Main listener. This is called whenever a request is made that matches the domains passed to the proxy
        override func signal(_ event: ProxySocketEvent) {
            switch event {
            case .receivedRequest(let session, let socket):
                if let trackerData = trackerData, trackerData.shouldBlock(domain: session.host) {
                    var blocked = true
                    if allowlist?.contains(domain: session.host) ?? false {
                        blocked = false
                    }
                    
                    if blocked {
                        socket.forceDisconnect(becauseOf: BlockedReason())
                    }
                    
                    let trackerOwner = trackerData.trackerOwner(forDomain: session.host)
                    let ownerName = trackerOwner?.name ?? "Unknown Owner"
                    appTrackingProtectionStoringModel.storeTracker(domain: session.host, trackerOwner: ownerName, blocked: blocked)
                }
                
                return
            default:
                break
            }
        }
    }
    
}
