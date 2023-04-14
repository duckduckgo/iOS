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
        static let blocklistHash = "a8402a2a06f17d79e8b359d051fd398dd304e20cd6632c28f5247b35e487dd75"
    }
    
    var blocklist: AppTrackerList?
    
    init() {
        loadTrackers()
    }
    
    var blocklistUrl: URL {
        return Bundle.main.url(forResource: "blocklist", withExtension: "json")!
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
        for (domain, obj) in blocklist.trackers where obj.defaultRule == "block" {
            domainList.append(domain)
        }
        
        return domainList
    }
    
    func trackerOwner(forDomain domain: String) -> AppTrackerOwner? {
        var check = domain

        while check.contains(".") {
            // return true if part of domain in list and action is block
            if let tracker = blocklist?.trackers[check] {
                return tracker.owner
            }
            
            let parts = domain.split(separator: ".").dropFirst()
            check = parts.joined(separator: ".")
        }
        
        return nil
    }
}
