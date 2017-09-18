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

    let classification: Classification
    
    init(classification: Classification?, goodTerms: [String], badTerms: [String]) {
        self.classification = classification ?? Classification.forCounts(good: goodTerms.count, bad: badTerms.count)
    }
    
    enum Classification: String {
        case a, b, c, d, e
        
        static func forCounts(good goodCount: Int, bad badCount: Int) -> Classification {
            let count = badCount - goodCount
            switch count {
            case Int.min ... 0: return .a
            case 1: return .b
            case 2: return .c
            case 3: return .d
            default: return .e
            }
        }
    }
}
