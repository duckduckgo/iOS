//
//  SiteRating.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class SiteRating {
    
    public var url: URL
    public var hasOnlySecureContent: Bool
    public let domain: String
    public var finishedLoading = false
    private var trackersDetected = [Tracker: Int]()
    private var trackersBlocked = [Tracker: Int]()

    private let termsOfServiceStore: TermsOfServiceStore
    let disconnectMeTrackers: [String: Tracker]
    let majorTrackerNetworkStore: MajorTrackerNetworkStore
    
    public init?(url: URL, disconnectMeTrackers: [String: Tracker] = DisconnectMeStore().trackers, termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore(), majorTrackerNetworkStore: MajorTrackerNetworkStore = EmbeddedMajorTrackerNetworkStore()) {
        guard let domain = url.host else {
            return nil
        }
        self.url = url
        self.domain = domain
        self.disconnectMeTrackers = disconnectMeTrackers
        self.termsOfServiceStore = termsOfServiceStore
        self.majorTrackerNetworkStore = majorTrackerNetworkStore
        self.hasOnlySecureContent = url.isHttps()
    }
    
    public var https: Bool {
        return url.isHttps()
    }

    public var uniqueMajorTrackerNetworksDetected: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersDetected)
    }

    public var uniqueMajorTrackerNetworksBlocked: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersBlocked)
    }

    public var containsMajorTracker: Bool {
        return trackersDetected.contains(where: { majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "" ) != nil } )
    }

    public var containsIpTracker: Bool {
        return trackersDetected.contains(where: { $0.key.isIpTracker } )
    }
    
    public var termsOfService: TermsOfService? {
        return termsOfServiceStore.terms.filter( { domain.hasSuffix($0.0) } ).first?.value
    }

    public func trackerDetected(_ tracker: Tracker, blocked: Bool) {
        let detectedCount = trackersDetected[tracker] ?? 0
        trackersDetected[tracker] = detectedCount + 1
        
        if blocked {
            let blockCount = trackersBlocked[tracker] ?? 0  
            trackersBlocked[tracker] = blockCount + 1
        }
    }
    
    public var uniqueTrackersDetected: Int {
        return trackersDetected.count
    }
    
    public var uniqueTrackersBlocked: Int {
        return trackersBlocked.count
    }
    
    public var totalTrackersDetected: Int {
        return trackersDetected.reduce(0) { $0 + $1.value }
    }
    
    public var totalTrackersBlocked: Int {
        return trackersBlocked.reduce(0) { $0 + $1.value }
    }

    private func uniqueMajorTrackerNetworks(trackers: [Tracker: Int]) -> Int {
        return Set(trackers.keys.filter({ majorTrackerNetworkStore.network(forName: $0.networkName ?? "" ) != nil }).flatMap({ $0.networkName })).count
    }

}
