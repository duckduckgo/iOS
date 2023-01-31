//
//  AppTrackerDataParser.swift
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

class TrackerDataParser {
    
    var blocklist: AppTrackerList?
    
    init() {
        loadTrackers(filename: "blocklist")
    }
    
    func loadTrackers(filename: String) {
        guard let data = try? Data(contentsOf: Bundle.main.url(forResource: filename, withExtension: "json")!) else {
            return
        }
        
        do {
            blocklist = try JSONDecoder().decode(AppTrackerList.self, from: data)
        } catch {
            print("[ERROR] Error decoding blocklist: \(error)")
        }
    }
    
    func shouldBlock(domain: String) -> Bool {
        guard domain.contains(".") else {
            return false
        }
        
        // walk down domain hit testing the blocklist
        var check = domain
        while check.contains(".") {
            // return true if part of domain in list and action is block
            if let tracker = blocklist?.trackers[check] {
                return tracker.defaultRule == "block"
            }
            
            let parts = domain.split(separator: ".").dropFirst()
            check = parts.joined(separator: ".")
        }
        
        return false
    }
    
    /// The tunnel proxy needs a flat domain list to match
    /// Take the tracker dictionary and return a flat array
    func flatDomainList() -> [String] {
        guard let blocklist = blocklist else {
            return []
        }
        
        var domainList: [String] = []
        for (domain, obj) in blocklist.trackers {
            if obj.defaultRule == "block" {
                domainList.append(domain)
            }
        }
        
        return domainList
    }
    
    func trackerOwner(forDomain domain: String) -> String {
        var check = domain
        while check.contains(".") {
            // return true if part of domain in list and action is block
            if let tracker = blocklist?.trackers[check] {
                return tracker.owner.displayName
            }
            
            let parts = domain.split(separator: ".").dropFirst()
            check = parts.joined(separator: ".")
        }
        
        return "Unknown Owner"
    }
}
