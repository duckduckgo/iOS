//
//  SiteRatingScoreExtension.swift
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

public extension SiteRating {
    
    public var siteScore: Int {
        var score = 1
        score += httpsScore
        score += isMajorTrackerScore
        score += trackerCountScore
        score += containsMajorTrackerScore
        score += ipTrackerScore
        score += termsOfServiceScore
        
        let cache =  SiteRatingCache.shared
        if cache.add(url:url, score: score) {
            return score
        }
        return cache.get(url: url)!
    }
    
    private var httpsScore: Int {
        return https ? -1 : 0
    }
    
    private var trackerCountScore: Int {
        let baseScore = Double(totalTrackersDetected) / 10.0
        return Int(ceil(baseScore))
    }
    
    private var containsMajorTrackerScore: Int {
        return containsMajorTracker ? 1 : 0
    }
    
    private var isMajorTrackerScore: Int {
        guard let network = majorTrackingNetwork else { return 0 }
        let baseScore = Double(network.perentageOfPages) / 10.0
        return Int(ceil(baseScore))
    }
    
    private var ipTrackerScore: Int {
        return contrainsIpTracker ? 1 : 0
    }
    
    private var termsOfServiceScore: Int {
        guard let termsOfService = termsOfService else {
            return 0
        }
        
        guard let classification = termsOfService.classification else {
            let score = termsOfService.score
            if score == 0 {
                return 0
            }
            return score > 0 ? 1 : -1
        }
        
        switch classification {
            case TermsOfService.Classification.a: return -1
            case TermsOfService.Classification.b: return 0
            case TermsOfService.Classification.c: return 0
            case TermsOfService.Classification.d: return 1
            case TermsOfService.Classification.e: return 2
        }
    }
    
    public var siteGrade: SiteGrade {
        return SiteGrade.grade(fromScore: siteScore)
    }
    
    public var scoreDict: [String : Any] {
        return [
            "score":  [
                "domain": domain,
                "hasHttps": https,
                "isAMajorTrackingNetwork": isMajorTrackerScore,
                "containsMajorTrackingNetwork": containsMajorTracker,
                "totalBlocked": totalTrackersBlocked,
                "hasObscureTracker": contrainsIpTracker,
                "tosdr": termsOfServiceScore
            ],
            "grade": siteGrade.rawValue.uppercased()
        ]
    }
    
    public var scoreDescription: String {
        let json = try! JSONSerialization.data(withJSONObject: scoreDict, options: .prettyPrinted)
        return String(data: json, encoding: .utf8)!
    }
}

public class SiteRatingCache {
    
    public static let shared = SiteRatingCache()
    
    private var cachedScores = [String: Int]()
    
    /**
     Adds a score to the cache. Only replaces a preexisting score if
     the new score is higher
     - returns: true if the cache was updated, otherwise false
     */
    func add(url: URL, score: Int) -> Bool {
        return compareAndSet(url: url, score: score)
    }
    
    private func compareAndSet(url: URL, score current: Int) -> Bool {
        let key = cacheKey(forUrl: url)
        if let previous = cachedScores[key], previous > current {
            return false
        }
        cachedScores[key] = current
        return true
    }
    
    func get(url: URL) -> Int? {
        let key = cacheKey(forUrl: url)
        return cachedScores[key]
    }
    
    func reset() {
        cachedScores =  [String: Int]()
    }
    
    private func cacheKey(forUrl url: URL) -> String {
        guard let domain = url.host else {
            return url.absoluteString
        }
        let scheme = url.scheme ?? URL.URLProtocol.http.rawValue
        return "\(scheme)_\(domain)"
    }
}
