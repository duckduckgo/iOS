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

}

public struct MajorTrackerNetwork {

    let name: String
    let perentageOfPages: Int

    var score: Int {
        return Int(ceil(Double(perentageOfPages) / 10.0))
    }

}

public class EmbeddedMajorTrackerNetworkStore: MajorTrackerNetworkStore {

    private let networks = [
        MajorTrackerNetwork(name: "google",     perentageOfPages: 84),
        MajorTrackerNetwork(name: "facebook",   perentageOfPages: 36),
        MajorTrackerNetwork(name: "twitter",    perentageOfPages: 16),
        MajorTrackerNetwork(name: "amazon",     perentageOfPages: 14),
        MajorTrackerNetwork(name: "appnexus",   perentageOfPages: 10),
        MajorTrackerNetwork(name: "oracle",     perentageOfPages: 10),
        MajorTrackerNetwork(name: "mediamath",  perentageOfPages: 9),
        MajorTrackerNetwork(name: "yahoo",      perentageOfPages: 9),
        MajorTrackerNetwork(name: "maxcdn",     perentageOfPages: 7),
        MajorTrackerNetwork(name: "automattic", perentageOfPages: 7),
        ]

    public init() { }

    public func network(forName name: String) -> MajorTrackerNetwork? {
        let lowercased = name.lowercased()
        return networks.filter( { lowercased.hasSuffix($0.name) } ).first
    }

}
