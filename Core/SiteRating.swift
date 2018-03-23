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
    
    public enum EncryptionType {
        case unencrypted, mixed, encrypted, forced
    }
    
    public var domain: String? {
        return url.host
    }
    
    public let url: URL
    public let protectionId: String
    public let httpsForced: Bool
    
    public var hasOnlySecureContent: Bool
    public var finishedLoading = false
    public private (set) var trackersDetected = [DetectedTracker: Int]()
    public private (set) var trackersBlocked = [DetectedTracker: Int]()

    private let termsOfServiceStore: TermsOfServiceStore
    let disconnectMeTrackers: [String: DisconnectMeTracker]
    let majorTrackerNetworkStore: MajorTrackerNetworkStore
    
    public init(url: URL, httpsForced: Bool = false, disconnectMeTrackers: [String: DisconnectMeTracker] = DisconnectMeStore().trackers, termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore(), majorTrackerNetworkStore: MajorTrackerNetworkStore = EmbeddedMajorTrackerNetworkStore(), protectionId: String = UUID.init().uuidString) {
        
        Logger.log(text: "new SiteRating(url: \(url), protectionId: \(protectionId))")
        
        self.protectionId = protectionId
        self.url = url
        self.httpsForced = httpsForced
        self.disconnectMeTrackers = disconnectMeTrackers
        self.termsOfServiceStore = termsOfServiceStore
        self.majorTrackerNetworkStore = majorTrackerNetworkStore
        self.hasOnlySecureContent = url.isHttps()
    }
    
    public var https: Bool {
        return url.isHttps()
    }

    public var encryptionType: EncryptionType {
        if hasOnlySecureContent {
            return httpsForced ? .forced : .encrypted
        } else if https {
            return .mixed
        }
        
        return .unencrypted
    }
    
    public var uniqueMajorTrackerNetworksDetected: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersDetected)
    }

    public var uniqueMajorTrackerNetworksBlocked: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersBlocked)
    }

    public var uniqueTrackerNetworksDetected: Int {
        return uniqueTrackerNetworks(trackers: trackersDetected)
    }

    public var uniqueTrackerNetworksBlocked: Int {
        return uniqueTrackerNetworks(trackers: trackersBlocked)
    }

    public var containsMajorTracker: Bool {
        return trackersDetected.contains(where: { majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "") != nil })
    }

    public var containsIpTracker: Bool {
        return trackersDetected.contains(where: { $0.key.isIpTracker } )
    }
    
    public var termsOfService: TermsOfService? {
        guard let domain = self.domain else { return nil }
        if let tos = termsOfServiceStore.terms.first( where: { domain.hasSuffix($0.0) } )?.value {
            return tos
        }

        // if not TOS found for this site use the parent's (e.g. google.co.uk should use google.com)
        let storeDomain = associatedDomain(for: domain) ?? domain
        return termsOfServiceStore.terms.first( where: { storeDomain.hasSuffix($0.0) } )?.value
    }

    public func trackerDetected(_ tracker: DetectedTracker) {
        let detectedCount = trackersDetected[tracker] ?? 0
        trackersDetected[tracker] = detectedCount + 1
        
        if tracker.blocked {
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

    public var majorNetworkTrackersDetected: [DetectedTracker: Int] {
        return trackersDetected.filter({ majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "" ) != nil })
    }

    public var majorNetworkTrackersBlocked: [DetectedTracker: Int] {
        return trackersBlocked.filter({ majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "" ) != nil })
    }

    public func associatedDomain(for domain: String) -> String? {
        let tracker = disconnectMeTrackers.first( where: { domain.hasSuffix($0.value.url) })?.value
        return tracker?.parentUrl?.host
    }

    private func uniqueMajorTrackerNetworks(trackers: [DetectedTracker: Int]) -> Int {
        return Set(trackers.keys.filter({ majorTrackerNetworkStore.network(forName: $0.networkName ?? "" ) != nil }).flatMap({ $0.networkName })).count
    }

    private func uniqueTrackerNetworks(trackers: [DetectedTracker: Int]) -> Int {
        return Set(trackers.keys.flatMap({ $0.networkName ?? $0.domain })).count
    }

}
