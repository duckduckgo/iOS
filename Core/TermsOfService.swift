//
//  TermsOfService.swift
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

public struct TermsOfService: Decodable {
    
    static let classificationSummaries: [TermsOfService.Classification: PrivacyPractices.Summary] = [
        .a: .good,
        .b: .mixed,
        .c: .poor,
        .d: .poor
    ]
    
    enum Classification: String, Decodable {
        
        case a = "A", b = "B", c = "C", d = "D"
        
    }
    
    struct Reasons: Decodable {
        
        let good: [String]?
        let bad: [String]?
        
    }
    
    let classification: Classification?
    let score: Int
    let reasons: Reasons
    
    enum CodingKeys: String, CodingKey {
        case score
        case reasons = "match"
        case classification = "class"
    }
    
    // see https://github.com/duckduckgo/duckduckgo-privacy-extension/blob/e425338a7b11dc112f1ee4b3de48102e2eceee5c/shared/js/background/privacy-practices.es6.js#L65
    var summary: PrivacyPractices.Summary {
        
        if let classification = classification {
            return TermsOfService.classificationSummaries[classification]!
        }
        
        if hasGoodReasons && hasBadReasons {
            return .mixed
        }
        
        if score < 0 {
            return .good
        } else if score == 0 && (hasGoodReasons || hasBadReasons) {
            return .mixed
        } else if score > 0 {
            return .poor
        }
        
        return .unknown
    }
    
    // see https://github.com/duckduckgo/duckduckgo-privacy-extension/blob/e425338a7b11dc112f1ee4b3de48102e2eceee5c/shared/js/background/privacy-practices.es6.js#L20
    var derivedScore: Int {
        
        var derived = 5
        
        // asign a score value to the classes/scores provided in the JSON file
        if classification == .a {
            derived = 0
        } else if classification == .b {
            derived = 1
        } else if classification == .d || score > 150 {
            derived = 10
        } else if classification == .c || score > 100 {
            derived = 7
        }
        
        return derived
    }
    
    var hasBadReasons: Bool {
        return !(reasons.bad?.isEmpty ?? true)
    }

    var hasGoodReasons: Bool {
        return !(reasons.good?.isEmpty ?? true)
    }

}
