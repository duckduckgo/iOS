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

/// The main interface for privacy practices.  Currently uses TOSDR as its data source.
public class PrivacyPractices {
    
    public enum Summary {
        case poor, mixed, good, unknown
    }
    
    public struct EntityScore {
        
        let score: Int
        let summary: Summary
        
    }
    
    struct Constants {
        static let unknown = EntityScore(score: 0, summary: .unknown)
    }

    private let tld: TLD
    private let terms: [String: TermsOfService]
    
    public init(termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore(), entityMaping: EntityMapping = EntityMapping()) {
        
        let tld = TLD()
        var terms = [String: TermsOfService]()
        
        termsOfServiceStore.terms.forEach {
            guard let url = URL(string: "http://\($0.key)") else { return }
            if let entity = entityMaping.findEntity(forURL: url) {
                terms[entity] = $0.value
            }
            
            if let domain = tld.domain(url.host) {
                terms[domain] = $0.value
            }
        }
        
        self.tld = tld
        self.terms = terms
    }
    
    func score(forEntity entity: String?) -> EntityScore {
        guard let entity = entity else { return Constants.unknown }
        if let term = terms[entity] {
            return EntityScore(score: term.score, summary: term.summary)
        }
        guard let domain = tld.domain(entity) else { return Constants.unknown }
        guard let term = terms[domain] else { return Constants.unknown }
        return EntityScore(score: term.score, summary: term.summary)
    }
    
}
