//
//  PrivacyPractices.swift
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
import Common

/// The main interface for privacy practices.  Currently uses TOSDR as its data source.
public class PrivacyPractices {
    
    public enum Summary {
        case poor, mixed, good, unknown
    }
    
    public struct Practice {
        
        public let score: Int
        public let summary: Summary
        public let goodReasons: [String]
        public let badReasons: [String]
        
    }
    
    struct Constants {
        static let unknown = Practice(score: 2, summary: .unknown, goodReasons: [], badReasons: [])
    }

    private let tld: TLD
    private let entityScores: [String: Int]
    private let siteScores: [String: Int]
    private let termsOfServiceStore: TermsOfServiceStore
    private let entityMapping: EntityMapping
    
    public init(tld: TLD, termsOfServiceStore: TermsOfServiceStore, entityMapping: EntityMapping) {
        var entityScores = [String: Int]()
        var siteScores = [String: Int]()
        
        termsOfServiceStore.terms.forEach {
            let derivedScore = $0.value.derivedScore

            if let entity = entityMapping.findEntity(forHost: $0.key, in: ContentBlocking.shared.trackerDataManager.trackerData) {
                if entityScores[entity.displayName ?? ""] == nil || entityScores[entity.displayName ?? ""]! < derivedScore {
                    entityScores[entity.displayName ?? ""] = derivedScore
                }
            }
            
            if let site = tld.domain($0.key) {
                siteScores[site] = derivedScore
            }
        }
        
        self.tld = tld
        self.entityScores = entityScores
        self.siteScores = siteScores
        self.termsOfServiceStore = termsOfServiceStore
        self.entityMapping = entityMapping
    }
    
    func findPractice(forHost host: String) -> Practice {
        guard let domain = tld.domain(host) else { return Constants.unknown }
        guard let term = termsOfServiceStore.terms[domain] else { return Constants.unknown }
        let entityScore = entityScores[entityMapping.findEntity(forHost: domain,
                                                                in: ContentBlocking.shared.trackerDataManager.trackerData)?.displayName ?? ""]
        return Practice(score: entityScore ?? term.derivedScore,
                        summary: term.summary,
                        goodReasons: term.goodReasons,
                        badReasons: term.badReasons)
    }
    
}
