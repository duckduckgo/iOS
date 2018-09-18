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

    func testWhenInitWithNoClassTerribleScoreAndGoodAndBadReasonsThenPracticesAreMixed() {
        let testee = TermsOfService(classification: nil, score: 100, goodReasons: [ "goodReason" ], badReasons: [ "badReason" ])
        XCTAssertEqual(testee.privacyPractices(), .mixed)
    }

    func testWhenInitWithNoClassExcellentScoreAndGoodAndBadReasonsThenPracticesAreMixed() {
        let testee = TermsOfService(classification: nil, score: -100, goodReasons: [ "goodReason" ], badReasons: [ "badReason" ])
        XCTAssertEqual(testee.privacyPractices(), .mixed)
    }

    func testWhenInitWithAClassificationButNoTermsPracticesAreUnknown() {
        let testee = TermsOfService(classification: .a, score: 10, goodReasons: [], badReasons: [])
        XCTAssertEqual(testee.privacyPractices(), .unknown)
    }

    func testWhenInitWithNoClassificationPrivacyPracticesAreUnknown() {
        let testee = TermsOfService(classification: nil, score: 10, goodReasons: [], badReasons: [])
        XCTAssertEqual(testee.privacyPractices(), .unknown)
    }

    func testWhenInitWithNoClassificationAndScoreAppropriatePrivacyPracticesAreReturned() {
        let scores: [Int: PrivacyPractices.Summary] = [
            -100: .good,
               0: .mixed,
             100: .poor
            ]

        for params in scores {
            let testee = TermsOfService(classification: nil, score: params.key, goodReasons: [ "something" ], badReasons: [])
            XCTAssertEqual(params.value, testee.privacyPractices())
        }

    }

    func testWhenInitWithClassificationAndBadReasonsAppropriatePrivacyPracticsReturned() {
        let classificationScores: [TermsOfService.Classification: PrivacyPractices.Summary] = [
            .a: .good,
            .b: .mixed,
            .c: .poor,
            .d: .poor,
            .e: .poor
            ]

        for params in classificationScores {
            let testee = TermsOfService(classification: params.key, score: 10, goodReasons: [], badReasons: [ "something" ])
            XCTAssertEqual(params.value, testee.privacyPractices())
        }

    }

    func testWhenInitWithClassificationAppropriatePrivacyPracticsReturned() {
        let classificationScores: [TermsOfService.Classification: PrivacyPractices.Summary] = [
            .a: .good,
            .b: .mixed,
            .c: .poor,
            .d: .poor,
            .e: .poor
        ]

        for params in classificationScores {
            let testee = TermsOfService(classification: params.key, score: 10, goodReasons: [ "something" ], badReasons: [])
            XCTAssertEqual(params.value, testee.privacyPractices())
        }

    }

    func testWhenNoClassAndScoreIsZeroDerivedScoreIsZero() {
        let testee = TermsOfService(classification: nil, score: 0, goodReasons: [], badReasons: [])
        XCTAssertEqual(0, testee.derivedScore)
    }

    func testWhenNoClassAndScoreIsPositiveDerivedScoreIsPlusOne() {
        let testee = TermsOfService(classification: nil, score: 1, goodReasons: [], badReasons: [])
        XCTAssertEqual(1, testee.derivedScore)
    }

    func testWhenNoClassAndScoreIsNegativeDerivedScoreIsMinusOne() {
        let testee = TermsOfService(classification: nil, score: -1, goodReasons: [], badReasons: [])
        XCTAssertEqual(-1, testee.derivedScore)
    }

    func testWhenInitWithClassificationAppropriateScoreReturned() {

        let classificationScores: [TermsOfService.Classification: Int] = [
            .a: -1,
            .b: 0,
            .c: 0,
            .d: 1,
            .e: 2
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
