//
//  PrivacyConfigurationData.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import UIKit

// swiftlint:disable nesting
public struct PrivacyConfigurationData {

    public typealias FeatureName = String

    enum CodingKeys: String {
        case features
        case unprotectedTemporary
        case trackerAllowlist
    }

    public let features: [FeatureName: PrivacyFeature]
    public let trackerAllowlist: TrackerAllowlist
    public let unprotectedTemporary: [ExceptionEntry]

    public init(json: [String: Any]) {

        if let tempListData = json[CodingKeys.unprotectedTemporary.rawValue] as? [[String: String]] {
            unprotectedTemporary = tempListData.compactMap({ ExceptionEntry(json: $0) })
        } else {
            unprotectedTemporary = []
        }

        if var featuresData = json[CodingKeys.features.rawValue] as? [String: Any] {
            var features = [FeatureName: PrivacyFeature]()

            if let allowlistEntry = featuresData[CodingKeys.trackerAllowlist.rawValue] as? [String: Any] {
                if let allowlist = TrackerAllowlist(json: allowlistEntry) {
                    self.trackerAllowlist = allowlist
                } else {
                    self.trackerAllowlist = TrackerAllowlist(entries: [], state: "disabled")
                }
                featuresData.removeValue(forKey: CodingKeys.trackerAllowlist.rawValue)
            } else {
                self.trackerAllowlist = TrackerAllowlist(entries: [], state: "disabled")
            }

            for featureEntry in featuresData {

                guard let featureData = featureEntry.value as? [String: Any],
                      let feature = PrivacyFeature(json: featureData) else { continue }
                features[featureEntry.key] = feature
            }
            self.features = features
        } else {
            self.features = [:]
            self.trackerAllowlist = TrackerAllowlist(entries: [], state: "disabled")
        }
    }

    public init(features: [FeatureName: PrivacyFeature], unprotectedTemporary: [ExceptionEntry], trackerAllowlist: [TrackerAllowlist.Entry]) {
        self.features = features
        self.unprotectedTemporary = unprotectedTemporary
        self.trackerAllowlist = TrackerAllowlist(entries: trackerAllowlist, state: "enabled")
    }

    public class PrivacyFeature {
        public typealias FeatureState = String
        public typealias ExceptionList = [ExceptionEntry]
        public typealias FeatureSettings = [String: Any]

        enum CodingKeys: String {
            case state
            case exceptions
            case settings
        }

        public let state: FeatureState
        public let exceptions: ExceptionList
        public let settings: FeatureSettings

        public init?(json: [String: Any]) {
            guard let state = json[CodingKeys.state.rawValue] as? String else { return nil }
            self.state = state

            if let exceptionsData = json[CodingKeys.exceptions.rawValue] as? [[String: String]] {
                self.exceptions = exceptionsData.compactMap({ ExceptionEntry(json: $0) })
            } else {
                self.exceptions = []
            }

            self.settings = (json[CodingKeys.settings.rawValue] as? [String: Any]) ?? [:]
        }

        public init(state: String, exceptions: [ExceptionEntry], settings: [String: Any] = [:]) {
            self.state = state
            self.exceptions = exceptions
            self.settings = settings
        }
    }

    public class TrackerAllowlist: PrivacyFeature {

        public struct Entry {
            let rule: String
            let domains: [String]
        }

        let entries: [Entry]

        public override init?(json: [String: Any]) {
            let settings = (json[PrivacyFeature.CodingKeys.settings.rawValue] as? [String: Any]) ?? [:]

            var entries = [Entry]()
            if let trackers = settings["allowlistedTrackers"] as? [String: [String: [Any]]] {
                for (_, tracker) in trackers {
                    if let rules = tracker["rules"] as? [ [String: Any] ] {
                        entries.append(contentsOf: rules.compactMap { ruleDict -> Entry? in
                            guard let rule = ruleDict["rule"] as? String, let domains = ruleDict["domains"] as? [String] else { return nil }

                            return Entry(rule: rule, domains: domains)
                        })
                    }
                }
            }

            self.entries = entries

            super.init(json: json)
        }

        public init(entries: [Entry], state: String) {
            self.entries = entries

            super.init(state: state, exceptions: [])
        }
    }

    public struct ExceptionEntry {
        public typealias ExcludedDomain = String
        public typealias ExclusionReason = String

        enum CodingKeys: String {
            case domain
            case reason
        }

        public let domain: ExcludedDomain
        public let reason: ExclusionReason?

        public init?(json: [String: String]) {
            guard let domain = json[CodingKeys.domain.rawValue] else { return nil }
            self.init(domain: domain, reason: json[CodingKeys.reason.rawValue])
        }

        public init(domain: String, reason: String?) {
            self.domain = domain
            self.reason = reason
        }
    }
}
// swiftlint:enable nesting
