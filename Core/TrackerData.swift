//
//  TrackerData.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

public struct TrackerData: Codable {

    public typealias EntityName = String
    public typealias TrackerDomain = String

    public struct TrackerRules {
        
        let tracker: KnownTracker
        
    }
    
    public let trackers: [TrackerDomain: KnownTracker]
    public let entities: [EntityName: Entity]
    public let domains: [TrackerDomain: EntityName]
    
    public init(trackers: [String: KnownTracker], entities: [String: Entity], domains: [String: String]) {
        self.trackers = trackers
        self.entities = entities
        self.domains = domains
    }

    func relatedDomains(for owner: KnownTracker.Owner?) -> [String]? {
        return entities[owner?.name ?? ""]?.domains
    }
    
}

public struct KnownTracker: Codable, Equatable {

    public static func == (lhs: KnownTracker, rhs: KnownTracker) -> Bool {
        return lhs.domain == rhs.domain
    }

    public struct Owner: Codable {
        
        public let name: String?
        public let displayName: String?
    
    }
    
    public struct Rule: Codable, Hashable, Equatable {
        
        // swiftlint:disable nesting
        public struct Matching: Codable, Hashable {

            public let domains: [String]?
            public let types: [String]?

        }
        // swiftlint:enable nesting

        public let rule: String?
        public let surrogate: String?
        public let action: ActionType?
        public let options: Matching?
        public let exceptions: Matching?
        
    }
    
    public enum ActionType: String, Codable {
        case block
        case ignore
    }
    
    enum CodingKeys: String, CodingKey {
        case domain
        case owner
        case categories
        case rules
        case prevalence
        case defaultAction = "default"
        case subdomains
    }

    public let domain: String?
    public let defaultAction: ActionType?
    public let owner: Owner?
    public let prevalence: Double?
    public let subdomains: [String]?
    public let categories: [String]?
    public let rules: [Rule]?

}

extension KnownTracker {

    static let displayCategories = [
        "Analytics", "Advertising", "Social Network"
    ]

    public var category: String? {
        return categories?.first(where: { Self.displayCategories.contains($0) })
    }
    
}

public struct Entity: Codable, Hashable {
    
    public let displayName: String?
    public let domains: [String]?
    public let prevalence: Double?
    
}
