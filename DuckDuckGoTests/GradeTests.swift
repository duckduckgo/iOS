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
    
    func test() throws {
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

class Grade {
    
    struct Score: Decodable, Equatable {
        
        let grade: String
        let httpsScore: Int
        let privacyScore: Int
        let score: Int
        let trackerScore: Int
        
    }
    
    struct Scores {
        
        let site: Score
        let enhanced: Score
        
    }
    
    struct Constants {
        
        static let unknownPrivacyScore = 2
        static let maxPrivacyScore = 10
      
    }
    
    var https = false
    var httpsAutoUpgrade = false
    var parentEntity: String?
    var privacyScore: Int?
    
    var scores: Scores {
        if calculatedScores == nil {
            calculatedScores = calculate()
        }
        return calculatedScores!
    }

    private var calculatedScores: Scores?
    private var trackersBlocked = [String: Double?]()
    private var trackersNotBlocked = [String: Double?]()

    func setParentEntity(named entity: String?, withPrevalence prevalence: Double?) {
        guard let entity = entity else { return }
        addEntityNotBlocked(named: entity, withPrevalence: prevalence)
    }
    
    func addEntityBlocked(named entity: String, withPrevalence prevalence: Double?) {
        calculatedScores = nil
        trackersBlocked[entity] = prevalence
    }
    
    func addEntityNotBlocked(named entity: String, withPrevalence prevalence: Double?) {
        calculatedScores = nil
        trackersNotBlocked[entity] = prevalence
    }
    
    private func calculate() -> Scores {
        
        // HTTPS
        var siteHttpsScore = 0
        var enhancedHttpsScore = 0

        if httpsAutoUpgrade {
            siteHttpsScore = 0
            enhancedHttpsScore = 0
        } else if https {
            siteHttpsScore = 3
            enhancedHttpsScore = 0
        } else {
            siteHttpsScore = 10
            enhancedHttpsScore = 10
        }
        
        // PRIVACY
        let privacyScore = min(self.privacyScore ?? Constants.unknownPrivacyScore, Constants.maxPrivacyScore)
        
        // TRACKERS
        let enhancedTrackerScore = trackerScore(from: trackersNotBlocked)
        let siteTrackerScore = trackerScore(from: trackersBlocked) + enhancedTrackerScore

        // TOTALS
        let siteTotalScore = siteHttpsScore + siteTrackerScore + privacyScore
        let enhancedTotalScore = enhancedHttpsScore + enhancedTrackerScore + privacyScore
        
        // GRADES
        let siteGrade = grade(from: siteTotalScore)
        let enhancedGrade = grade(from: enhancedTotalScore)
        
        let site = Score(grade: siteGrade,
                         httpsScore: siteHttpsScore,
                         privacyScore: privacyScore,
                         score: siteTotalScore,
                         trackerScore: siteTrackerScore)
        
        let enhanced = Score(grade: enhancedGrade,
                             httpsScore: enhancedHttpsScore,
                             privacyScore: privacyScore,
                             score: enhancedTotalScore,
                             trackerScore: enhancedTrackerScore)
        
        return Scores(site: site, enhanced: enhanced)
    }
    
    private func trackerScore(from trackers: [String: Double?]) -> Int {
        return trackers.reduce(0, { $0 + score(from: $1.value) })
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func score(from prevalence: Double?) -> Int {
        guard let prevalence = prevalence, prevalence > 0 else { return 0 }
        switch prevalence {
        case 0 ..< 0.1: return 1
        case 0.1 ..< 1: return 2
        case 1 ..< 5: return 3
        case 5 ..< 10: return 4
        case 10 ..< 15: return 5
        case 15 ..< 20: return 6
        case 20 ..< 30: return 7
        case 30 ..< 45: return 8
        case 45 ..< 66: return 9
        default: return 10
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func grade(from score: Int) -> String {
        switch score {
        case Int.min ..< 2: return "A"
        case 2 ..< 4: return "B+"
        case 4 ..< 10: return "B"
        case 10 ..< 14: return "C+"
        case 14 ..< 20: return "C"
        case 20 ..< 30: return "D"
        default: return "D-"
        }
    }
    
}
