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

import XCTest

struct GradeTestCase: Decodable {
    
    struct Result: Decodable {
        
        let grade: String
        let httpsScore: Int
        let privacyScore: Int
        let score: Int
        let trackerScore: Int
        
    }
    
    struct Expected: Decodable {
        
        let enhanced: Result
        let site: Result
        
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
        let privacyScore: Int?

        let trackers: [Tracker]
    }
    
    let expected: Expected
    let input: Input
    let url: String
    
}

class GradeTests: XCTestCase {
    
    func test() throws {
        let testCases = try loadTestCases()
        
        var index = 0
        for testCase in testCases {
            assertTestCase(testCase, atIndex: index)
            index += 1
        }
        
    }
    
    private func assertTestCase(_ testCase: GradeTestCase, atIndex index: Int) {
        let grade = Grade()
        
        grade.https = testCase.input.https
        grade.httpsAutoUpgrade = testCase.input.httpsAutoUpgrade
        grade.parentEntity = testCase.input.parentEntity
        grade.privacyScore = testCase.input.privacyScore
        
        for tracker in testCase.input.trackers {
         
            let entity = determineEntity(for: tracker)
            grade.addEntity(entity, parentEntity: tracker.parentEntity, andPrevalence: tracker.prevalence)
            
        }
        
    }
    
    private func loadTestCases() throws -> [GradeTestCase] {
        let url = Bundle(for: type(of: self)).url(forResource: "grade-cases", withExtension: "json")
        let data = try Data(contentsOf: url!)
        return try JSONDecoder().decode([GradeTestCase].self, from: data)
    }
    
}

class Grade {
    
    var https = false
    var httpsAutoUpgrade = false
    var parentEntity: String?
    var privacyScore: Int?
    
}
