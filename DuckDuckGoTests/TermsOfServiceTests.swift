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
    

    func testWhenNoPreClassificationOrTermsThenClassificationIsA() {
        let testee = TermsOfService(classification: nil, goodTerms: [], badTerms: [])
        XCTAssertEqual(TermsOfService.Classification.a, testee.classification)
    }
    
    func testWhenSiteContainsAGoodTermThenClassificationIsA() {
        let testee = TermsOfService(classification: nil, goodTerms: ["goodTerm"], badTerms: [])
        XCTAssertEqual(TermsOfService.Classification.a, testee.classification)
    }
    
    func testWhenSiteContainsABadTermThenClassificationIsB() {
        let testee = TermsOfService(classification: nil, goodTerms: [], badTerms: ["badTerm1"])
        XCTAssertEqual(TermsOfService.Classification.b, testee.classification)
    }
    
    func testWhenSiteContainsTwoMoreBadTermsThanGoodTermsThenClassificationIsC() {
        let testee = TermsOfService(classification: nil, goodTerms: ["goodTerm1"], badTerms: ["badTerm1","badTerm2","badTerm3"])
        XCTAssertEqual(TermsOfService.Classification.c, testee.classification)
    }
    
    func testWhenSiteContainsTwoMoreGoodTermsThanBadTermsThenClassificationIsA() {
        let testee = TermsOfService(classification: nil, goodTerms: ["goodTerm1","goodTerm2","goodTerm3"], badTerms: ["badTerm1"])
        XCTAssertEqual(TermsOfService.Classification.a, testee.classification)
    }
    
    func testWhenSiteContainsEqualGoodAndBadTermsThenClassificationIsA() {
        let testee = TermsOfService(classification: nil, goodTerms: ["goodTerm1","goodTerm2","goodTerm3"], badTerms: ["badTerm1","badTerm2","badTerm3"])
        XCTAssertEqual(TermsOfService.Classification.a, testee.classification)
    }
    
    func testWhenInitialisedWithPreClassificationThenClassificationIsThatValue() {
        let testee = TermsOfService(classification: .a, goodTerms: [], badTerms: ["badTerm1","badTerm2","badTerm3"])
        XCTAssertEqual(TermsOfService.Classification.a, testee.classification)
    }
}
