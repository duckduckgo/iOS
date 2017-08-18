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
    
    public init(configuration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()) {
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
    
    public var hasData: Bool {
        if let trackers = configuration.trackers {
            return !trackers.isEmpty
        }
        return false
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
    
    public func policy(forUrl url: URL, document documentUrl: URL) -> (tracker: Tracker?, block: Bool) {
        guard let tracker = thirdPartyTracker(forUrl: url, document: documentUrl) else {
            return (nil, false)
        }
        
        if !configuration.enabled {
            return (tracker, false)
        }
        
        guard let host = documentUrl.host  else { return (tracker, false) }
        if configuration.whitelisted(domain: host) {
            return (tracker, false)
        }
        
        Logger.log(text: "ContentBlocker BLOCKED \(url.absoluteString)")
        return (tracker, true)
    }
    
    /**
     Checks if a url for a specific document is a tracker
     - parameter url: the url to check
     - parameter documentUrl: the document requesting the url
     - returns: tracker if the item matches a third party url in the trackers list otherwise nil
     */
    private func thirdPartyTracker(forUrl url: URL, document documentUrl: URL) -> Tracker? {
        guard let trackers = configuration.trackers else { return nil }
        for tracker in trackers {
            if url.absoluteString.contains(tracker.url) && documentUrl.host != url.host {
                Logger.log(text: "ContentBlocker DETECTED tracker \(url.absoluteString)")
                return tracker
            }
        }
        Logger.log(text: "ContentBlocker did NOT detect \(url.absoluteString) as a tracker")
        return nil
    }
    
}
