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
    public let domain: String
    private var trackersDetected = [Tracker: Int]()
    private var trackersBlocked = [Tracker: Int]()
    
    public init?(url: URL) {
        guard let domain = url.host else {
            return nil
        }
        self.url = url
        self.domain = domain
    }
    
    public var https: Bool {
        return url.isHttps()
    }
    
    public var containsMajorTracker: Bool {
        return trackersDetected.contains(where: { $0.key.parent != nil && MajorTrackerNetworks.networks.contains($0.key.parent!) })
    }
    
    public func trackerDetected(_ tracker: String, parent: String? = nil, blocked: Bool) {

        let tracker = Tracker(url: tracker, parent: parent)

        let detectedCount = trackersDetected[tracker] ?? 0
        trackersDetected[tracker] = detectedCount + 1
        
        if blocked{
            let blockCount = trackersBlocked[tracker] ?? 0
            trackersBlocked[tracker] = blockCount + 1
        }
    }
    
    public var uniqueItemsDetected: Int {
        return trackersDetected.count
    }
    
    public var uniqueItemsBlocked: Int {
        return trackersBlocked.count
    }
    
    public var totalItemsDetected: Int {
        return trackersDetected.reduce(0) { $0 + $1.value }
    }
    
    public var totalItemsBlocked: Int {
        return trackersBlocked.reduce(0) { $0 + $1.value }
    }

    struct Tracker: Hashable, Equatable {

        var url: String
        var parent: String?

        func isMajorTrackerNetwork() -> Bool {
            guard let network = parent else { return false }
            return MajorTrackerNetworks.networks.contains(network)
        }

        public var hashValue: Int {
            return url.hashValue ^ (parent?.hashValue ?? 0)
        }

        static func == (lhs: Tracker, rhs: Tracker) -> Bool {
            return lhs.url == rhs.url && lhs.parent == rhs.parent
        }

    }

}
