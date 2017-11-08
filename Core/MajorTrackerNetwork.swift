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

public protocol MajorTrackerNetworkStore {

    func network(forDomain domain: String) -> MajorTrackerNetwork?

}

public struct MajorTrackerNetwork {

    let domain: String
    let perentageOfPages: Int

}

public class EmbeddedMajorTrackerNetworkStore: MajorTrackerNetworkStore {

    private let networks = [
        MajorTrackerNetwork(domain: "google.com",     perentageOfPages: 84),
        MajorTrackerNetwork(domain: "facebook.com",   perentageOfPages: 36),
        MajorTrackerNetwork(domain: "twitter.com",    perentageOfPages: 16),
        MajorTrackerNetwork(domain: "amazon.com",     perentageOfPages: 14),
        MajorTrackerNetwork(domain: "appnexus.com",   perentageOfPages: 10),
        MajorTrackerNetwork(domain: "oracle.com",     perentageOfPages: 10),
        MajorTrackerNetwork(domain: "mediamath.com",  perentageOfPages: 9),
        MajorTrackerNetwork(domain: "yahoo.com",      perentageOfPages: 9),
        MajorTrackerNetwork(domain: "maxcdn.com",     perentageOfPages: 7),
        MajorTrackerNetwork(domain: "automattic.com", perentageOfPages: 7),
        ]

    public init() { }

    public func network(forDomain domain: String) -> MajorTrackerNetwork? {
        return networks.filter( { domain.hasSuffix($0.domain) } ).first
    }

}
