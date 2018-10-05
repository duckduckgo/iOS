//
//  GradeTests.swift
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
import XCTest
@testable import Core

struct GradeTestCase: Decodable {
    
    struct Expected: Decodable {
        
        let enhanced: Grade.Score
        let site: Grade.Score
        
    }
    
    struct Tracker: Decodable {
        
        let blocked: Bool
        let parentEntity: String
        let prevalence: Double?
        
    }
    
    struct Input: Decodable {
        
        let https: Bool
        let httpsAutoUpgrade: Bool
        let parentEntity: String?
        let parentTrackerPrevalence: Double?
        let privacyScore: Int?

        let trackers: [Tracker]
    }
    
    let expected: Expected
    let input: Input
    let url: String
    
}

class GradeTests: XCTestCase {
    
    func testWhenPropertyChangesThenScoreIsRecalculated() throws {
        
        let grade = Grade()
        grade.https = true
        
        XCTAssertEqual(.b, grade.scores.site.grade)
        XCTAssertEqual(3, grade.scores.site.httpsScore)
        XCTAssertEqual(2, grade.scores.site.privacyScore)
        XCTAssertEqual(5, grade.scores.site.score)
        XCTAssertEqual(0, grade.scores.site.trackerScore)
        
        grade.httpsAutoUpgrade = true

        XCTAssertEqual(.bPlus, grade.scores.site.grade)
        XCTAssertEqual(0, grade.scores.site.httpsScore)
        XCTAssertEqual(2, grade.scores.site.privacyScore)
        XCTAssertEqual(2, grade.scores.site.score)
        XCTAssertEqual(0, grade.scores.site.trackerScore)

        grade.setParentEntity(named: "Google", withPrevalence: 83.0)

        XCTAssertEqual(.cPlus, grade.scores.site.grade)
        XCTAssertEqual(0, grade.scores.site.httpsScore)
        XCTAssertEqual(2, grade.scores.site.privacyScore)
        XCTAssertEqual(12, grade.scores.site.score)
        XCTAssertEqual(10, grade.scores.site.trackerScore)

        grade.privacyScore = 100

        XCTAssertEqual(.d, grade.scores.site.grade)
        XCTAssertEqual(0, grade.scores.site.httpsScore)
        XCTAssertEqual(10, grade.scores.site.privacyScore)
        XCTAssertEqual(20, grade.scores.site.score)
        XCTAssertEqual(10, grade.scores.site.trackerScore)

    }

    func testDefaultValues() throws {
        
        let grade = Grade()
        XCTAssertEqual(.cPlus, grade.scores.site.grade)
        XCTAssertEqual(10, grade.scores.site.httpsScore)
        XCTAssertEqual(2, grade.scores.site.privacyScore)
        XCTAssertEqual(12, grade.scores.site.score)
        XCTAssertEqual(0, grade.scores.site.trackerScore)
        
    }
    
    func testPredefinedTestCases() throws {
        let testCases = try loadTestCases()
        
        var index = 0
        for testCase in testCases {
            guard assertTestCase(testCase, atIndex: index) else { return }
            index += 1
        }
        
    }
    
    private func assertTestCase(_ testCase: GradeTestCase, atIndex index: Int) -> Bool {
        let grade = Grade()
        
        grade.https = testCase.input.https
        grade.httpsAutoUpgrade = testCase.input.httpsAutoUpgrade
        grade.privacyScore = testCase.input.privacyScore
        grade.setParentEntity(named: testCase.input.parentEntity, withPrevalence: testCase.input.parentTrackerPrevalence)
        
        for tracker in testCase.input.trackers {
            
            if tracker.blocked {
                grade.addEntityBlocked(named: tracker.parentEntity, withPrevalence: tracker.prevalence)
            } else {
                grade.addEntityNotBlocked(named: tracker.parentEntity, withPrevalence: tracker.prevalence)
            }
            
        }
        
        let gradeData = grade.scores
        
        if testCase.expected.site != gradeData.site {
            XCTFail("expected site \(testCase.expected.site) was \(gradeData.site) for \(testCase.url)")
            return false
        }
        
        if testCase.expected.enhanced != gradeData.enhanced {
            XCTFail("expected enhanced \(testCase.expected.enhanced) was \(gradeData.enhanced) for \(testCase.url)")
            return false
        }

        return true
    }
    
    private func loadTestCases() throws -> [GradeTestCase] {
        let url = Bundle(for: type(of: self)).url(forResource: "grade-cases", withExtension: "json")
        let data = try Data(contentsOf: url!)
        return try JSONDecoder().decode([GradeTestCase].self, from: data)
    }
    
}
