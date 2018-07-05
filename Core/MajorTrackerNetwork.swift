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

    public let name: String
    public let domain: String
    public let percentageOfPages: Int

    public var score: Int {
        return Int(ceil(Double(percentageOfPages) / 10.0))
    }

}

public class InMemoryMajorNetworkStore: MajorTrackerNetworkStore {

    let networks: [MajorTrackerNetwork]

    init(networks: [MajorTrackerNetwork]) {
        self.networks = networks
    }

    public func network(forDomain domain: String) -> MajorTrackerNetwork? {
        let lowercased = domain.lowercased()
        return networks.first(where: { lowercased == $0.domain || lowercased.hasSuffix(".\($0.domain)") })
    }

    public func network(forName name: String) -> MajorTrackerNetwork? {
        let lowercased = name.lowercased()
        return networks.first(where: { lowercased == $0.name.lowercased() })
    }

}

public class EmbeddedMajorTrackerNetworkStore: InMemoryMajorNetworkStore {

    private static let networks = [
        MajorTrackerNetwork(name: "google", domain: "google.com", percentageOfPages: 84),
        MajorTrackerNetwork(name: "facebook", domain: "facebook.com", percentageOfPages: 36),
        MajorTrackerNetwork(name: "twitter", domain: "twitter.com", percentageOfPages: 16),
        MajorTrackerNetwork(name: "amazon.com", domain: "amazon.com", percentageOfPages: 14),
        MajorTrackerNetwork(name: "appnexus", domain: "appnexus.com", percentageOfPages: 10),
        MajorTrackerNetwork(name: "oracle", domain: "oracle.com", percentageOfPages: 10),
        MajorTrackerNetwork(name: "mediamath", domain: "mediamath.com", percentageOfPages: 9),
        MajorTrackerNetwork(name: "yahoo!", domain: "yahoo.com", percentageOfPages: 9),
        MajorTrackerNetwork(name: "stackpath", domain: "stackpath.com", percentageOfPages: 7),
        MajorTrackerNetwork(name: "automattic", domain: "automattic.com", percentageOfPages: 7)
        ]

    public init() {
        super.init(networks: EmbeddedMajorTrackerNetworkStore.networks)
    }

}
