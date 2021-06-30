//
//  TrackerResolver.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit

class TrackerResolver {
    
    let tds: TrackerData
    let unprotectedSites: [String]
    let tempList: [String]
    
    public init(tds: TrackerData, unprotectedSites: [String], tempList: [String]) {
        self.tds = tds
        self.unprotectedSites = unprotectedSites
        self.tempList = tempList
    }
    
    
    public func trackerFromUrl(_ trackerUrlString: String,
                               pageUrlString: String,
                               potentiallyBlocked: Bool) -> DetectedTracker? {
        return trackerFromUrl(trackerUrlString, pageUrlString: pageUrlString, potentiallyBlocked: potentiallyBlocked)
    }
    
    public func trackerFromUrl(_ trackerUrlString: String,
                               pageUrlString: String,
                               resourceType: String?,
                               potentiallyBlocked: Bool) -> DetectedTracker? {
        
        guard let knownTracker = tds.findTracker(forUrl: trackerUrlString) else {
            return nil
        }

        let blocked: Bool

        if knownTracker.hasExemption(for: trackerUrlString, pageUrlString: pageUrlString) {
            blocked = false
        } else if let pageDomain = URL(string: pageUrlString),
                  let pageHost = pageDomain.host {
            if unprotectedSites.contains(pageHost) || tempList.contains(pageHost) {
                blocked = false
            } else {
                blocked = potentiallyBlocked
            }
        } else {
            blocked = potentiallyBlocked
        }

        if let entity = tds.findEntity(byName: knownTracker.owner?.name ?? "") {
            return DetectedTracker(url: trackerUrlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
        }
        
        return nil
    }
}
    
fileprivate extension KnownTracker {

    func hasExemption(for trackerUrlString: String, pageUrlString: String) -> Bool {
        let range = NSRange(location: 0, length: trackerUrlString.utf16.count)

        for rule in rules ?? [] where rule.action == .ignore {
            guard let pattern = rule.rule,
                  let host = URL(string: pageUrlString)?.host,
                  rule.exceptions?.domains?.contains(host) ?? false == false,
                  let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            if regex.firstMatch(in: trackerUrlString, options: [], range: range) != nil {
                return true
            }
        }

        return false
    }

}
