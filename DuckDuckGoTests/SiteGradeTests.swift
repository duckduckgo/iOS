//
//  SiteGradeTests.swift
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

class SiteGradeTests: XCTestCase {

    func testWhenScoreIsZeroThenGradeIsA() {
        XCTAssertEqual(SiteGrade.a, SiteGrade.grade(fromScore: 0))
    }

    func testWhenScoreIsLessThanZeroThenGradeIsA() {
        XCTAssertEqual(SiteGrade.a, SiteGrade.grade(fromScore: -100))
    }
    
    func testWhenScoreIsOneThenGradeIsB() {
        XCTAssertEqual(SiteGrade.b, SiteGrade.grade(fromScore: 1))
    }
    
    func testWhenScoreIsTwoThenGradeIsC() {
        XCTAssertEqual(SiteGrade.c, SiteGrade.grade(fromScore: 2))
    }
    
    func testWhenScoreIsThreeThenGradeIsD() {
        XCTAssertEqual(SiteGrade.d, SiteGrade.grade(fromScore: 3))
    }
    
    func testWhenScoreIsFourThenGradeIsD() {
        XCTAssertEqual(SiteGrade.d, SiteGrade.grade(fromScore: 4))
    }
    

    func testWhenScoreIsGreaterThan4ThenGradeIsD() {
        XCTAssertEqual(SiteGrade.d, SiteGrade.grade(fromScore: 100))
    }

}
