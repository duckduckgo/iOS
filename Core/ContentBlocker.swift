//
//  ContentBlocker.swift
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

public class ContentBlocker {

    private var configuration: ContentBlockerConfigurationStore
    private let trackers: [Tracker]
    private(set) var trackersDetected = [Tracker: Int]()
    private(set) var trackersBlocked = [Tracker: Int]()
    
    public init(configuration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults(),
         trackers: [Tracker]) {
        self.trackers = trackers
        self.configuration = configuration
    }
    
    public var enabled: Bool {
        get {
            return configuration.enabled
        }
        set(newValue) {
            configuration.enabled = newValue
        }
    }
    
    public func enabled(forDomain domain: String) -> Bool {
        return !configuration.whitelisted(domain: domain)
    }
    
    public func whitelist(_ on: Bool, domain: String) {
        if on {
            configuration.addToWhitelist(domain: domain)
        } else {
            configuration.removeFromWhitelist(domain: domain)
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

    public func resetMonitoring() {
        trackersDetected = [Tracker: Int]()
        trackersBlocked = [Tracker: Int]()
    }
    
    public func block(url: URL, forDocument documentUrl: URL) -> Bool {
        guard let tracker = thirdPartyTracker(forUrl: url, document: documentUrl) else {
            return false
        }
        
        if !configuration.enabled {
            return false
        }
        
        guard let host = documentUrl.host  else { return false }
        if configuration.whitelisted(domain: host) {
            return false
        }
        
        Logger.log(text: "ContentBlocker BLOCKED \(url.absoluteString)")
        trackerBlocked(tracker)
        return true
    }
    
    private func trackerBlocked(_ tracker: Tracker) {
        let previousCount = trackersBlocked[tracker] ?? 0
        trackersBlocked[tracker] = previousCount + 1
    }
    
    /**
     Checks if a url for a specific document is a tracker
     - parameter url: the url to check
     - parameter documentUrl: the document requesting the url
     - returns: tracker if the item matches a third party url in the trackers list otherwise nil
     */
    private func thirdPartyTracker(forUrl url: URL, document documentUrl: URL) -> Tracker? {
        for tracker in trackers {
            if url.absoluteString.contains(tracker.url) && documentUrl.host != url.host {
                Logger.log(text: "ContentBlocker DETECTED tracker \(url.absoluteString)")
                trackerDetected(tracker)
                return tracker
            }
        }
        Logger.log(text: "ContentBlocker did NOT detect \(url.absoluteString) as a tracker")
        return nil
    }
    
    private func trackerDetected(_ tracker: Tracker) {
        let previousCount = trackersDetected[tracker] ?? 0
        trackersDetected[tracker] = previousCount + 1
    }
}
