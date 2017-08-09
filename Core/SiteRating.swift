//
//  SiteRating.swift
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

public struct SiteRating {
    
    public var https = false
    public var trackers = [Tracker: Int]()

    public init() {}
    
    public var siteScore: Int {
        var score = 1
        score += httpsScore
        score += trackerCountScore
        score += majorTrackerNetworkScore
        return score
    }
    
    private var httpsScore: Int {
        return https ? -1 : 0
    }
    
    private var trackerCountScore: Int {
        let baseScore = Double(trackersCount) / 10.0
        return Int(ceil(baseScore))
    }
    
    public var trackersCount: Int {
        return trackers.reduce(0) { $0 + $1.value }
    }
    
    private var majorTrackerNetworkScore: Int {
        return containsMajorTracker ? 1 : 0
    }
    
    private var containsMajorTracker: Bool {
        return trackers.contains(where: { $0.key.fromMajorNetwork() } )
    }

    public var siteGrade: SiteGrade {
        return SiteGrade.grade(fromScore: siteScore)
    }
}
