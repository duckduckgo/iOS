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

    func network(forName name: String) -> MajorTrackerNetwork?
    func network(forDomain domain: String) -> MajorTrackerNetwork?

}

public struct MajorTrackerNetwork {

    let name: String
    let domain: String
    let perentageOfPages: Int

    var score: Int {
        return Int(ceil(Double(perentageOfPages) / 10.0))
    }

}

public class InMemoryMajorNetworkStore: MajorTrackerNetworkStore {

    let networks: [MajorTrackerNetwork]

    init(networks: [MajorTrackerNetwork]) {
        self.networks = networks
    }

    public func network(forDomain domain: String) -> MajorTrackerNetwork? {
        let lowercased = domain.lowercased()
        return networks.first(where: { lowercased.hasSuffix($0.domain) })
    }

    public func network(forName name: String) -> MajorTrackerNetwork? {
        let lowercased = name.lowercased()
        return networks.first(where: { lowercased == $0.name.lowercased() })
    }

}

public class EmbeddedMajorTrackerNetworkStore: InMemoryMajorNetworkStore {

    private static let networks = [
        MajorTrackerNetwork(name: "google",     domain: "google.com",       perentageOfPages: 84),
        MajorTrackerNetwork(name: "facebook",   domain: "facebook.com",     perentageOfPages: 36),
        MajorTrackerNetwork(name: "twitter",    domain: "twitter.com",      perentageOfPages: 16),
        MajorTrackerNetwork(name: "amazon.com", domain: "amazon.com",       perentageOfPages: 14),
        MajorTrackerNetwork(name: "appnexus",   domain: "appnexus.com",     perentageOfPages: 10),
        MajorTrackerNetwork(name: "oracle",     domain: "oracle.com",       perentageOfPages: 10),
        MajorTrackerNetwork(name: "mediamath",  domain: "mediamath.com",    perentageOfPages: 9),
        MajorTrackerNetwork(name: "yahoo!",     domain: "yahoo.com",        perentageOfPages: 9),
        MajorTrackerNetwork(name: "stackpath",  domain: "stackpath.com",    perentageOfPages: 7),
        MajorTrackerNetwork(name: "automattic", domain: "automattic.com",   perentageOfPages: 7),
        ]

    public init() {
        super.init(networks: EmbeddedMajorTrackerNetworkStore.networks)
    }

}
