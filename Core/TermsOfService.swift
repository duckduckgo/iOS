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

        enum Match: String, CodingKey {
            case good
            case bad
        }
    }

    struct Lookups {

        static let classificationAsPractices: [Classification: PrivacyPractices.Summary] = [
            .a: .good,
            .b: .mixed,
            .c: .poor,
            .d: .poor,
            .e: .poor
            ]

        static let classificationScores: [Classification: Int] = [
            .a: -1,
            .b: 0,
            .c: 0,
            .d: 1,
            .e: 2
            ]

        static let derivedScoreAsPractices: [Int: PrivacyPractices.Summary] = [
            -1: .good,
            0: .mixed,
            1: .poor
            ]

    }

    public let classification: Classification?
    public let score: Int
    public let goodReasons: [String]
    public let badReasons: [String]

    public var hasReasons: Bool {
        return !goodReasons.isEmpty || !badReasons.isEmpty
    }

    public var hasUnknownPractices: Bool {
        return !hasReasons
    }

    public var derivedScore: Int {
        if let classification = classification {
            return Lookups.classificationScores[classification]!
        }

        return normalizeScore()
    }

    public var summary: PrivacyPractices.Summary {
        guard !hasUnknownPractices else { return .unknown }

        var practices: PrivacyPractices.Summary?
        if let classification = classification {
            practices = Lookups.classificationAsPractices[classification]
        } else if !goodReasons.isEmpty && !badReasons.isEmpty {
            return .mixed
        } else {
            practices = Lookups.derivedScoreAsPractices[normalizeScore()]!
        }

        if let practices = practices {
            return practices
        }

        return .unknown
    }

    private func normalizeScore() -> Int {
        // extensions JS uses Math.sign(score)
        if score < 0 { return -1 }
        if score > 0 { return 1 }
        return 0
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
