//
//  Grade.swift
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

public class Grade {

    public enum Grading: String, Decodable {
        
        case a = "A"
        case bPlus = "B+"
        case b = "B"
        case cPlus = "C+"
        case c = "C"
        case d = "D"
        case dMinus = "D-"
        
    }
    
    public struct Score: Decodable, Equatable {
        
        public let grade: Grading
        public let httpsScore: Int
        public let privacyScore: Int
        public let score: Int
        public let trackerScore: Int
        
    }
    
    public struct Scores {
        
        public let site: Score
        public let enhanced: Score
        
    }
    
    struct Constants {
        
        static let unknownPrivacyScore = 2
        static let maxPrivacyScore = 10
        
    }
    
    public var scores: Scores {
        if calculatedScores == nil {
            calculatedScores = calculate()
        }
        return calculatedScores!
    }
    
    var https = false {
        didSet {
            calculatedScores = nil
        }
    }
    var httpsAutoUpgrade = false {
        didSet {
            calculatedScores = nil
        }
    }
    var parentEntity: String? {
        didSet {
            calculatedScores = nil
        }
    }
    var privacyScore: Int? {
        didSet {
            calculatedScores = nil
        }
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
    
    private func grade(from score: Int) -> Grading {
        switch score {
        case Int.min ..< 2: return .a
        case 2 ..< 4: return .bPlus
        case 4 ..< 10: return .b
        case 10 ..< 14: return .cPlus
        case 14 ..< 20: return .c
        case 20 ..< 30: return .d
        default: return .dMinus
        }
    }
    
}
