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
    let uuid: String
    let domain: String
    let trackerOwner: String
    let blocking: Bool
}

@MainActor
class AppTPManageTrackersViewModel: ObservableObject {
    
    private var blocklist: TrackerDataParser
    private var allowlist: AppTrackingProtectionAllowlistModel
    
    @Published public var trackerList: [ManagedTrackerRepresentable] = []
    
    // This is set to true when a tracker is disabled
    // If this is true we know to show the "report breakage" dialog when the
    // tracker list updates in the view
    public var trackerDisabled: Bool = false
    
    init(blocklist: TrackerDataParser = TrackerDataParser(),
         allowlist: AppTrackingProtectionAllowlistModel = AppTrackingProtectionAllowlistModel()) {
        self.blocklist = blocklist
        self.allowlist = allowlist
    }
    
    public func buildTrackerList() {
        var newList = [ManagedTrackerRepresentable]()
        for blockedTracker in blocklist.flatDomainList() {
            let tracker = ManagedTrackerRepresentable(
                uuid: UUID().uuidString,
                domain: blockedTracker,
                trackerOwner: blocklist.trackerOwner(forDomain: blockedTracker)?.name ?? "Unknown",
                blocking: !allowlist.contains(domain: blockedTracker)
            )
            newList.append(tracker)
        }
        // Sort the list by Tracker Network then by domain
        newList.sort(by: { ($0.trackerOwner.lowercased(), $0.domain) < ($1.trackerOwner.lowercased(), $1.domain) })
        Task { @MainActor in
            trackerList = newList
        }
    }
    
    public func changeState(for trackerDomain: String, blocking: Bool) {
        if !blocking {
            allowlist.allow(domain: trackerDomain)
            trackerDisabled = true
        } else {
            allowlist.remove(domain: trackerDomain)
        }
        
        // Update the tracker list
        if let index = trackerList.firstIndex(where: { $0.domain == trackerDomain }) {
            trackerList[index] = ManagedTrackerRepresentable(
                uuid: UUID().uuidString, // New UUID string forces view updates
                domain: trackerDomain,
                trackerOwner: blocklist.trackerOwner(forDomain: trackerDomain)?.name ?? "Unknown",
                blocking: blocking
            )
        }
    }
    
    public func resetAllowlist() {
        allowlist.clearList()
        buildTrackerList()
    }
}
