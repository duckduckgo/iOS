//
//  TrackerDataQueryExtension.swift
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

extension TrackerData {
    
    public func findEntity(byName name: String) -> Entity? {
        return entities[name]
    }
    
    public func findEntity(forHost host: String) -> Entity? {
        for host in variations(of: host) {
            if let entityName = domains[host] {
                return entities[entityName]
            }
        }
        return nil
    }

    private func variations(of host: String) -> [String] {
        var parts = host.components(separatedBy: ".")
        var domains = [String]()
        while parts.count > 1 {
            let domain = parts.joined(separator: ".")
            domains.append(domain)
            parts.removeFirst()
        }
        return domains
    }
    
    public func findTracker(forUrl url: String) -> KnownTracker? {
        guard let host = URL(string: url)?.host else { return nil }
        for host in variations(of: host) {
            if let tracker = trackers[host] {
                return tracker
            } else if let cname = cnames?[host] {
                var tracker = findTracker(byCname: cname)
                tracker = tracker?.copy(withNewDomain: cname)
                return tracker
            }
        }
        return nil
    }
}
