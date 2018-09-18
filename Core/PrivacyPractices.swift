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
    
    private let termsOfServiceStore: TermsOfServiceStore
    
    public init(termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore()) {
        self.termsOfServiceStore = termsOfServiceStore
    }
    
    func score(forEntity entity: String?) -> (score: Int, summary: Summary) {
        guard let entity = entity else { return (0, .unknown) }
        guard let terms = termsOfServiceStore.terms[entity] else { return (0, .unknown) }
        return (terms.score, terms.summary)
    }
    
}
