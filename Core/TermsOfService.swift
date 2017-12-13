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


public struct TermsOfService {

    struct Lookups {

        static let classificationAsPractices: [Classification: PrivacyPractices] = [
            .a: .good,
            .b: .mixed,
            .c: .poor,
            .d: .poor,
            .e: .poor,
            ]

        static let classificationScores: [Classification: Int] = [
            .a: -1,
            .b: 0,
            .c: 0,
            .d: 1,
            .e: 2,
            ]

        static let derivedScoreAsPractices: [Int: PrivacyPractices] = [
            -1: .good,
            0: .mixed,
            1: .poor,
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
        get {
            return !hasReasons
        }
    }

    public var derivedScore: Int {
        if let classification = classification {
            return Lookups.classificationScores[classification]!
        }

        return normalizeScore()
    }

    public func privacyPractices() -> PrivacyPractices {
        guard !hasUnknownPractices else { return .unknown }

        var practices: PrivacyPractices?
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

    public enum Classification: String {
        case a, b, c, d, e
    }

    public enum PrivacyPractices {

        case poor, mixed, good, unknown

    }

}
