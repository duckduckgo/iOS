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

    private static let classificationScores: [Classification: Int] = [
        .a: -1,
        .b: 0,
        .c: 0,
        .d: 1,
        .e: 2
    ]

    public let classification: Classification?
    public let score: Int
    public let goodReasons: [String]
    public let badReasons: [String]

    public var derivedScore: Int {
        if let classification = classification {
            return TermsOfService.classificationScores[classification]!
        }

        if score < 0 { return -1 }
        if score > 0 { return 1 }
        return 0
    }

    public enum Classification: String {
        case a, b, c, d, e
    }
}
