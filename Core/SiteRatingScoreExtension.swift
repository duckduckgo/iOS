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

// Based on
// https://github.com/duckduckgo/chrome-zeroclickinfo/blob/ceb4fc6b2e36451207ef9c887b4e1e6ccff30352/js/site.js#L89

public extension SiteRating {

    func siteScore() -> ( before: Int, after: Int ) {

        // No special pages

        var beforeScore = 1
        var afterScore = 1

        beforeScore += isMajorTrackerScore
        afterScore += isMajorTrackerScore

        if let tos = termsOfService {
            beforeScore += tos.derivedScore
            afterScore += tos.derivedScore
        }

        beforeScore += hasTrackerInMajorNetworkScore

        if !https || !hasOnlySecureContent {
            beforeScore += 1
            afterScore += 1
        }

        beforeScore += ipTrackerScore

        beforeScore += Int(floor(Double(totalTrackersDetected) / 10))

        let cache = SiteRatingCache.shared
        if !cache.add(url: url, score: beforeScore) {
            beforeScore = cache.get(url: url)!
        }

        return ( beforeScore, afterScore )
    }

    func siteGrade() -> ( before: SiteGrade, after: SiteGrade ) {
        let score = siteScore()
        return ( SiteGrade.grade(fromScore: score.before), SiteGrade.grade(fromScore: score.after ))
    }

    private var httpsScore: Int {
        return https ? -1 : 0
    }

    private var hasTrackerInMajorNetworkScore: Int {
        return trackersDetected.keys.first(where: { $0.inMajorNetwork(disconnectMeTrackers, majorTrackerNetworkStore) }) != nil ? 1 : 0
    }

    private var isMajorTrackerScore: Int {
        guard let domain = domain else { return 0 }
        if let network = majorTrackerNetworkStore.network(forName: domain) { return network.score }
        if let network = majorTrackerNetworkStore.network(forDomain: domain) { return network.score }
        return 0
    }

    var isMajorTrackerNetwork: Bool {
        return isMajorTrackerScore > 0
    }
    
    private var ipTrackerScore: Int {
        return containsIpTracker ? 1 : 0
    }
    
    public var termsOfServiceScore: Int {
        guard let termsOfService = termsOfService else {
            return 0
        }
        
        return termsOfService.derivedScore
    }
    
    public var scoreDict: [String : Any] {
        let grade = siteGrade()
        return [
            "score": [
                "domain": domain ?? "unknown",
                "hasHttps": https,
                "isAMajorTrackingNetwork": isMajorTrackerScore,
                "containsMajorTrackingNetwork": containsMajorTracker,
                "totalBlocked": totalTrackersBlocked,
                "hasObscureTracker": containsIpTracker,
                "tosdr": termsOfServiceScore
            ],
            "grade": [
                "before": grade.before.rawValue.uppercased(),
                "after": grade.after.rawValue.uppercased()
            ]
        ]
    }
    
    public var scoreDescription: String {
        let json = try! JSONSerialization.data(withJSONObject: scoreDict, options: .prettyPrinted)
        return String(data: json, encoding: .utf8)!
    }

    public func networkNameAndCategory(forDomain domain: String) -> ( networkName: String?, category: String? ) {
        let lowercasedDomain = domain.lowercased()
        if let tracker = disconnectMeTrackers.first(where: { lowercasedDomain == $0.key || lowercasedDomain.hasSuffix(".\($0.key)") } )?.value {
            return ( tracker.networkName, tracker.category?.rawValue )
        }
        
        if let majorNetwork = majorTrackerNetworkStore.network(forDomain: lowercasedDomain) {
            return ( majorNetwork.name, nil )
        }
        
        return ( nil, nil )
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

fileprivate extension DetectedTracker {

    func inMajorNetwork(_ disconnectMeTrackers: [String: DisconnectMeTracker], _ majorTrackerNetworkStore: MajorTrackerNetworkStore) -> Bool {
        guard let domain = domain else { return false }
        guard let networkName = disconnectMeTrackers.first(where: { domain.hasSuffix($0.key) })?.value.networkName else { return false }
        return majorTrackerNetworkStore.network(forName: networkName) != nil
    }

}


