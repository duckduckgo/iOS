//
//  AppTPTrackerDetailViewModel.swift
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
import Core

class AppTPTrackerDetailViewModel: ObservableObject {
    
    @Published var isOn: Bool
    @Published var isBlocking: Bool
    
    let trackerDomain: String
    let allowlist: AppTrackingProtectionAllowlistModel
    let blocklist: TrackerDataParser
    
    init(trackerDomain: String,
         allowlist: AppTrackingProtectionAllowlistModel = AppTrackingProtectionAllowlistModel(),
         blocklist: TrackerDataParser = TrackerDataParser()) {
        self.trackerDomain = trackerDomain
        self.allowlist = allowlist
        self.blocklist = blocklist
        
        let isBlocked = !allowlist.contains(domain: trackerDomain)
        self.isBlocking = isBlocked
        self.isOn = isBlocked
    }
    
    func changeTrackerState() {
        // Find tracker that matches the domain rule
        guard let tracker = blocklist.matchingTracker(forDomain: trackerDomain) else {
            return
        }
        
        if isBlocking {
            allowlist.remove(domain: tracker)
        } else {
            allowlist.allow(domain: tracker)
        }
        self.isOn = self.isBlocking
    }
    
}
