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
                               resourceType: String,
                               potentiallyBlocked: Bool) -> DetectedTracker? {
        
        guard let tracker = tds.findTracker(forUrl: trackerUrlString) else {
            return nil
        }

        let blocked: Bool

        // Check for unprotected domains
        if let pageDomain = URL(string: pageUrlString),
           let pageHost = pageDomain.host,
           unprotectedSites.contains(pageHost) || tempList.contains(pageHost) {
            blocked = false
        } else {
            // Check for custom rules
            let rule = tracker.hasRule(for: trackerUrlString, type: resourceType, pageUrlString: pageUrlString)
            switch rule {
            case .none:
                if tracker.defaultAction == .block {
                    blocked = potentiallyBlocked
                } else /* if tracker.defaultAction == .ignore */ {
                    blocked = false
                }
            case .allowRequest:
                blocked = false
            case .blockRequest:
                blocked = potentiallyBlocked
            }
        }
        
        // Get entity
        guard let entity = tds.findEntity(byName: tracker.owner?.name ?? "") else {
            return nil
        }
        
        // Check if current page is not affilated with the tracker
        if let pageUrl = URL(string: pageUrlString),
           let pageHost = pageUrl.host,
           let pageEntity = tds.findEntity(forHost: pageHost),
           pageEntity.displayName == entity.displayName {
            return nil
        }

        return DetectedTracker(url: trackerUrlString, knownTracker: tracker, entity: entity, blocked: blocked)
    }

    enum RuleAction {
        case none
        case allowRequest
        case blockRequest
    }

    static func isMatching(_ option: KnownTracker.Rule.Matching, host: String, resourceType: String) -> Bool {

        var matching = true

        if let requiredDomains = option.domains {
            matching = requiredDomains.contains(where: { domain in
                guard domain != host else { return true }
                return  host.hasSuffix(".\(domain)")
            })
        }

        if let requiredTypes = option.types {
             matching = matching && requiredTypes.contains(resourceType)
        }

        return matching
    }
}

fileprivate extension KnownTracker.Rule.Matching {

}
    
fileprivate extension KnownTracker {

    func hasRule(for trackerUrlString: String,
                 type: String,
                 pageUrlString: String) -> TrackerResolver.RuleAction {

        let range = NSRange(location: 0, length: trackerUrlString.utf16.count)
        let host = URL(string: pageUrlString)?.host

        for rule in rules ?? [] {
            guard let pattern = rule.rule,
                  let host = host,
                  let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            if regex.firstMatch(in: trackerUrlString, options: [], range: range) != nil {

                if rule.action == .ignore {
                    return .allowRequest
                }

                if let options = rule.options, !TrackerResolver.isMatching(options, host: host, resourceType: type) {
                    return .allowRequest
                }

                if let exceptions = rule.exceptions, TrackerResolver.isMatching(exceptions, host: host, resourceType: type) {
                    return .allowRequest
                }

                return .blockRequest
            }
        }

        return .none
    }

    func hasExemption(ofType actionType: KnownTracker.ActionType,
                      for trackerUrlString: String,
                      pageUrlString: String) -> Bool {
        let range = NSRange(location: 0, length: trackerUrlString.utf16.count)

        for rule in rules ?? [] where rule.action == actionType {
            guard let pattern = rule.rule,
                  let host = URL(string: pageUrlString)?.host,
                  rule.exceptions?.domains?.contains(host) ?? false == true,
                  let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            if regex.firstMatch(in: trackerUrlString, options: [], range: range) != nil {
                return true
            }
        }

        return false
    }

}
