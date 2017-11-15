//
//  NetworkLeaderboard.swift
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
import CoreData
import Core

class NetworkLeaderboard {

    lazy var coreData = DDGPersistenceContainer(name: "NetworkLeaderboard")

    func reset() {

    }

    func percentOfSitesWithNetwork(named: String? = nil) -> Int {
        return 0
    }

    func networksDetected() -> [String] {
        return []
    }

    func visited(domain: String) {
    }

    func network(named network: String, detectedWhileVisitingDomain domain: String) {
    }

}

class InMemoryNetworkLeaderboard {

    var leaderboard = [String: Set<String>]()

    func reset() {
        leaderboard = [String: Set<String>]()
    }

    func percentOfSitesWithNetwork(named: String? = nil) -> Int {
        guard leaderboard.count > 0 else { return 0 }
        let sitesWithNetwork = leaderboard.filter( {  named == nil ? $0.value.count > 0 : $0.value.contains(named!) })
        let percent = Float(sitesWithNetwork.count) / Float(leaderboard.count)
        return Int(percent * 100)
    }

    func networksDetected() -> [String] {
        return Array(leaderboard.reduce(Set<String>(), { (set, element) -> Set<String> in
            return set.union(element.value)
        }))
    }

    func visited(domain: String) {
        guard leaderboard[domain] == nil else { return }
        leaderboard[domain] = Set<String>()
    }

    func network(named network: String, detectedWhileVisitingDomain domain: String) {
        var set: Set<String>!
        if let detected = leaderboard[domain] {
            set = detected
        } else {
            set = Set<String>()
        }
        set.insert(network)
        leaderboard[domain] = set
    }

}
