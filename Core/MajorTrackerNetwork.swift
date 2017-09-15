//
//  MajorTrackerNetwork.swift
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

struct MajorTrackerNetwork {
    
    let domain: String
    let perentageOfPages: Int
    
    static let all = [
        MajorTrackerNetwork(domain: "google.com",    perentageOfPages: 55),
        MajorTrackerNetwork(domain: "amazon.com",    perentageOfPages: 23),
        MajorTrackerNetwork(domain: "facebook.com",  perentageOfPages: 20),
        MajorTrackerNetwork(domain: "comscore.com",  perentageOfPages: 19),
        MajorTrackerNetwork(domain: "twitter.com",   perentageOfPages: 11),
        MajorTrackerNetwork(domain: "criteo.com",    perentageOfPages: 9),
        MajorTrackerNetwork(domain: "quantcast.com", perentageOfPages: 9),
        MajorTrackerNetwork(domain: "adobe.com",     perentageOfPages: 8),
        MajorTrackerNetwork(domain: "newrelic.com",  perentageOfPages: 7),
        MajorTrackerNetwork(domain: "appnexus.com",  perentageOfPages: 7)
    ]
}

extension Tracker {
    
    var fromMajorNetwork: Bool {
        guard let parentDomain = parentDomain else {
            return false
        }
        return !MajorTrackerNetwork.all.filter( {$0.domain == parentDomain } ).isEmpty
    }
}

extension URL {
    
    var majorTrackerNetwork: MajorTrackerNetwork? {
        // TODO after integration check disconnect list for associated url
        guard let host = host else { return nil }
        return MajorTrackerNetwork.all.filter( { host.hasSuffix($0.domain) } ).first
    }
}
