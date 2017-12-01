//
//  TermsOfServiceTests.swift
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


import XCTest
@testable import Core

class TermsOfServiceTests: XCTestCase {

    func testWhenNoClassAndScoreIsPositiveScoreDerivedScoreIsPlusOne() {
        let testee = TermsOfService(classification: nil, score: 1, goodReasons: [], badReasons: [])
        XCTAssertEqual(1, testee.derivedScore)
    }

    func testWhenNoClassAndScoreIsNegativeScoreDerivedScoreIsMinusOne() {
        let testee = TermsOfService(classification: nil, score: -1, goodReasons: [], badReasons: [])
        XCTAssertEqual(-1, testee.derivedScore)
    }

    func testWhenInitWithClassificationAppropriateScoreReturned() {

        let classificationScores: [TermsOfService.Classification: Int] = [
            .a : -1,
            .b : 0,
            .c : 0,
            .d : 1,
            .e : 2
        ]

        for params in classificationScores {
            let testee = TermsOfService(classification: params.key, score: 10, goodReasons: [], badReasons: [])
            XCTAssertEqual(params.value, testee.derivedScore)
        }

    }
    
    func testWhenInitWithoutClassificationthenClassificationIsNil() {
        let testee = TermsOfService(classification: nil, score: 10, goodReasons: [], badReasons: [])
        XCTAssertEqual(1, testee.derivedScore)
    }
}
