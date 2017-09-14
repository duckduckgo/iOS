//
//  MajorTrackerNetworks.swift
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

struct MajorTrackingNetwork {
    
    let domain: String
    let perentageOfPages: Int
    
    static let all = [
        MajorTrackingNetwork(domain: "google.com",    perentageOfPages: 55),
        MajorTrackingNetwork(domain: "amazon.com",    perentageOfPages: 23),
        MajorTrackingNetwork(domain: "facebook.com",  perentageOfPages: 20),
        MajorTrackingNetwork(domain: "comscore.com",  perentageOfPages: 19),
        MajorTrackingNetwork(domain: "twitter.com",   perentageOfPages: 11),
        MajorTrackingNetwork(domain: "criteo.com",    perentageOfPages: 9),
        MajorTrackingNetwork(domain: "quantcast.com", perentageOfPages: 9),
        MajorTrackingNetwork(domain: "adobe.com",     perentageOfPages: 8),
        MajorTrackingNetwork(domain: "newrelic.com",  perentageOfPages: 7),
        MajorTrackingNetwork(domain: "appnexus.com",  perentageOfPages: 7)
    ]
}

extension Tracker {
    
    var fromMajorNetwork: Bool {
        guard let parentDomain = parentDomain else {
            return false
        }
        return !MajorTrackingNetwork.all.filter( {$0.domain == parentDomain } ).isEmpty
    }
}

extension URL {
    
    var majorTrackerNetwork: MajorTrackingNetwork? {
        guard let host = host else { return nil }
        return MajorTrackingNetwork.all.filter( { $0.domain == host } ).first
    }
}
