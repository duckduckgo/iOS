//
//  TrackerDetector.swift
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

public class TrackerDetector {
    
    private var configuration: ContentBlockerConfigurationStore
    private var disconnectTrackers: [Tracker]

    public init(configuration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults(), disconnectTrackers: [Tracker]) {
        self.configuration = configuration
        self.disconnectTrackers = disconnectTrackers
    }
        
    public func policy(forUrl url: URL, document documentUrl: URL) -> (tracker: Tracker?, block: Bool) {
        
        if isFirstParty(url, of: documentUrl) {
            Logger.log(text: "TrackerDetector found first party url \(url.absoluteString)")
            return (nil, false)
        }
        
        guard let tracker = tracker(forUrl: url) else {
            Logger.log(text: "TrackerDetector did NOT detect \(url.absoluteString) as tracker")
            return (nil, false)
        }
        
        if !configuration.enabled {
            return (tracker, false)
        }
        
        Logger.log(text: "TrackerDetector DID detect \(url.absoluteString) as tracker")
        return (tracker, true)
    }
    
    private func tracker(forUrl url: URL) -> Tracker? {

        guard let urlHost = url.host else {
            return nil
        }

        let banned = disconnectTrackers.filter(byCategory: Tracker.Category.banned)
        for tracker in banned {
            
            guard let trackerUrl = URL(string: URL.appendScheme(path: tracker.url)),
                  let trackerHost = trackerUrl.host else {
                    continue
            }

            if isFirstParty(url, of: trackerUrl), urlHost.contains(trackerHost) {
                return tracker
            }
        }
        
        return nil
    }
    
    private func isFirstParty(_ childUrl: URL, of parentUrl: URL) -> Bool {
        return childUrl.baseDomain == parentUrl.baseDomain
    }

}


