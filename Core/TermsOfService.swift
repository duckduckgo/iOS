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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.classification = try? container.decode(Classification.self, forKey: .classification)
        self.score = try container.decode(Int.self, forKey: .score)
        let matchContainer = try container.nestedContainer(keyedBy: CodingKeys.Match.self, forKey: .match)
        self.goodReasons = try matchContainer.decodeIfPresent([String].self, forKey: .good) ?? []
        self.badReasons = try matchContainer.decodeIfPresent([String].self, forKey: .bad) ?? []
    }

    public init(classification: Classification?, score: Int, goodReasons: [String], badReasons: [String]) {
        self.classification = classification
        self.score = score
        self.goodReasons = goodReasons
        self.badReasons = badReasons
    }

    private enum CodingKeys: String, CodingKey {
        case classification = "class"
        case score
        case match
        // swiftlint:disable nesting
        enum Match: String, CodingKey {
            case good
            case bad
        }
        // swiftlint:enable nesting
    }

    public let classification: Classification?
    public let score: Int
    public let goodReasons: [String]
    public let badReasons: [String]

    public var hasGoodReasons: Bool {
        return !goodReasons.isEmpty
    }

    public var hasBadReasons: Bool {
        return !badReasons.isEmpty
    }

    // see https://github.com/duckduckgo/duckduckgo-privacy-extension/blob/e42533/shared/js/background/privacy-practices.es6.js#L65
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
    
    // see https://github.com/duckduckgo/duckduckgo-privacy-extension/blob/e42533/shared/js/background/privacy-practices.es6.js#L20
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

    public enum Classification: String, Decodable {
        case a, b, c, d, e

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let lowercaseString = try container.decode(String.self).lowercased()
            guard let classification = Classification(rawValue: lowercaseString) else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Classification string didn't match")
                throw DecodingError.typeMismatch(Classification.self, context)
            }
            self = classification
        }
    }

}
