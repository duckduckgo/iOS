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
    
    public struct Practice {
        
        let score: Int
        let summary: Summary
        
    }
    
    struct Constants {
        static let unknown = Practice(score: 0, summary: .unknown)
    }

    private let tld: TLD
    private let practices: [String: Practice]
    
    public init(termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore(), entityMaping: EntityMapping = EntityMapping()) {
        
        let tld = TLD()
        var practices = [String: Practice]()
        
        termsOfServiceStore.terms.forEach {
            guard let url = URL(string: "http://\($0.key)") else { return }
            if let entity = entityMaping.findEntity(forURL: url) {
                let practice = Practice(score: $0.value.derivedScore, summary: $0.value.summary)
                let existingPractice = practices[entity]
                if existingPractice == nil || existingPractice!.score < practice.score {
                    practices[entity] = practice
                }
            }
            
            if let domain = tld.domain(url.host) {
                practices[domain] = Practice(score: $0.value.derivedScore, summary: $0.value.summary)
            }
        }
        
        self.tld = tld
        self.practices = practices
    }
    
    func findPractice(forEntity entity: String?) -> Practice {
        if let entity = entity, let entityPractice = practices[entity] {
            return entityPractice
        }
        
        if let domain = tld.domain(entity), let domainPractice = practices[domain] {
            return domainPractice
        }
        
        return Constants.unknown
    }
    
}
