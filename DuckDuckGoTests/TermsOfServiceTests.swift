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
    
    func testDerivedScores() {
        let testCases: [(expected: Int, term: TermsOfService)] = [
            (0, TermsOfService(classification: .a, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (1, TermsOfService(classification: .b, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (5, TermsOfService(classification: nil, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (7, TermsOfService(classification: .c, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (7, TermsOfService(classification: nil, score: 101, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (10, TermsOfService(classification: .d, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (10, TermsOfService(classification: nil, score: 151, reasons: TermsOfService.Reasons(good: nil, bad: nil)))
        ]

        var index = 0
        for test in testCases {
            if test.expected != test.term.derivedScore {
                XCTFail("test \(index) failed, expected \(test.expected) was \(test.term.derivedScore) for \(test.term)")
            }
            index += 1
        }
    }
   
    func testSummaries() {
        let testCases: [(expected: PrivacyPractices.Summary, term: TermsOfService)] = [
            // score and reasons are ignored
            (.good, TermsOfService(classification: .a, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.mixed, TermsOfService(classification: .b, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: .c, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: .d, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))),

            (.good, TermsOfService(classification: .a, score: 1, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.mixed, TermsOfService(classification: .b, score: -1, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: .c, score: 0, reasons: TermsOfService.Reasons(good: ["reason"], bad: nil))),
            (.poor, TermsOfService(classification: .d, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: ["reason"]))),

            // class and score are ignored
            (.mixed, TermsOfService(classification: nil, score: 0, reasons: TermsOfService.Reasons(good: ["reason"], bad: ["reason"]))),
            
            // class and reasons are ignored
            (.good, TermsOfService(classification: nil, score: -1, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.good, TermsOfService(classification: nil, score: -10, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.good, TermsOfService(classification: nil, score: -100, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.good, TermsOfService(classification: nil, score: -1000, reasons: TermsOfService.Reasons(good: nil, bad: nil))),

            // class is ignored, must be at least one reason of either kind
            (.mixed, TermsOfService(classification: nil, score: 0, reasons: TermsOfService.Reasons(good: ["reason"], bad: nil))),
            (.mixed, TermsOfService(classification: nil, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: ["reason"]))),

            // class and reasons are ignored
            (.poor, TermsOfService(classification: nil, score: 1, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: nil, score: 10, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: nil, score: 100, reasons: TermsOfService.Reasons(good: nil, bad: nil))),
            (.poor, TermsOfService(classification: nil, score: 1000, reasons: TermsOfService.Reasons(good: nil, bad: nil)))
        ]

        var index = 0
        for test in testCases {
            if test.expected != test.term.summary {
                XCTFail("test \(index) failed, expected \(test.expected) was \(test.term.summary) for \(test.term)")
            }
            index += 1
        }
    }
    
}
