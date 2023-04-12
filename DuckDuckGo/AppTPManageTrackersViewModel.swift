//
//  AppTPManageTrackersViewModel.swift
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

struct ManagedTrackerRepresentable: Hashable {
    let domain: String
    let trackerOwner: String
    let blocking: Bool
}

class AppTPManageTrackersViewModel: ObservableObject {
    
    private var blocklist: TrackerDataParser
    private var allowlist: AppTrackingProtectionAllowlistModel
    
    @Published public var trackerList: [ManagedTrackerRepresentable] = []
    
    init(blocklist: TrackerDataParser = TrackerDataParser(),
         allowlist: AppTrackingProtectionAllowlistModel = AppTrackingProtectionAllowlistModel()) {
        self.blocklist = blocklist
        self.allowlist = allowlist
        buildTrackerList()
    }
    
    private func buildTrackerList() {
        trackerList.removeAll()
        for blockedTracker in blocklist.flatDomainList() {
            var tracker = ManagedTrackerRepresentable(
                domain: blockedTracker,
                trackerOwner: blocklist.trackerOwner(forDomain: blockedTracker)?.name ?? "Unknown",
                blocking: !allowlist.contains(domain: blockedTracker)
            )
            trackerList.append(tracker)
        }
        // Sort the list by Tracker Network
        trackerList.sort(by: { $0.trackerOwner < $1.trackerOwner })
    }
    
    public func changeState(for trackerDomain: String, blocking: Bool) {
        if !blocking {
            allowlist.allow(domain: trackerDomain)
        } else {
            allowlist.remove(domain: trackerDomain)
        }
        buildTrackerList()
    }
    
    public func resetAllowlist() {
        allowlist.clearList()
        buildTrackerList()
    }
}
