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
import Core

class TrackerDataParser {
    
    struct Constants {
        static let blocklistHash = "890ea65fb8e28d13c05bdf70c45a48874f79abc4d77ed02fe686a38dbc37bdaa"
    }
    
    var blocklist: AppTrackerList?
    
    init() {
        loadTrackers()
    }
    
    var blocklistUrl: URL {
        return Bundle.main.url(forResource: "ios_blocklist_075", withExtension: "json")!
    }
    
    func loadTrackers() {
        guard let data = try? Data(contentsOf: blocklistUrl) else {
            return
        }
        
        do {
            blocklist = try JSONDecoder().decode(AppTrackerList.self, from: data)
        } catch {
            print("[ERROR] Error decoding blocklist: \(error)")
            Pixel.fire(pixel: .appTPBlocklistParseFailed)
        }
    }
    
    func shouldBlock(domain: String) -> Bool {
        guard let tracker = trackerFor(domain: domain) else {
            return false
        }
    
        return tracker.defaultRule == "block"
    }
    
    func trackerFor(domain: String) -> AppTracker? {
        guard domain.contains(".") else {
            return nil
        }
        
        // walk down domain hit testing the blocklist
        var check = domain
        while check.contains(".") {
            // return true if part of domain in list and action is block
            if let tracker = blocklist?.trackers[check] {
                return tracker
            }
            
            let parts = check.split(separator: ".").dropFirst()
            check = parts.joined(separator: ".")
        }
        
        return nil
    }
    
    /// Given a domain return the tracker domain matched on the blocklist
    /// For example if `tracker.com` is on the blocklist calling this method with `company.tracker.com`
    /// wiill return `tracker.com` or `nil` if the tracker is not found.
    func matchingTracker(forDomain domain: String) -> String? {
        guard domain.contains(".") else {
            return nil
        }
        
        // walk down domain hit testing the blocklist
        var check = domain
        while check.contains(".") {
            // return the domain matched in the blocklist
            if blocklist?.trackers[check] != nil {
                return check
            }
            
            let parts = check.split(separator: ".").dropFirst()
            check = parts.joined(separator: ".")
        }
        
        return nil
    }
    
    /// The tunnel proxy needs a flat domain list to match
    /// Take the tracker dictionary and return a flat array
    func flatDomainList() -> [String] {
        guard let blocklist = blocklist else {
            return []
        }
        
        var domainList: [String] = []
        for (domain, obj) in blocklist.trackers where obj.defaultRule == "block" {
            domainList.append(domain)
        }
        
        return domainList
    }
    
    func trackerOwner(forDomain domain: String) -> AppTrackerOwner? {
        guard let tracker = trackerFor(domain: domain) else {
            return nil
        }
        
        return tracker.owner
    }
}
