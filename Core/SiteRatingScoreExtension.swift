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

//    func siteScore() -> ( before: Int, after: Int ) {
//
//        var afterScore = 0
//        var beforeScore = 0
//
//        let cache = SiteRatingCache.shared
//        if !cache.add(url: url, score: beforeScore) {
//            beforeScore = cache.get(url: url)!
//        }
//
//        return ( beforeScore, afterScore )
//    }
//
//    func siteGrade() -> ( before: SiteGrade, after: SiteGrade ) {
//        let score = siteScore()
//        return ( SiteGrade.grade(fromScore: score.before), SiteGrade.grade(fromScore: score.after ))
//    }

    private var httpsScore: Int {
        return https ? -1 : 0
    }

//    private var hasTrackerInMajorNetworkScore: Int {
//        return trackersDetected.keys.first(where: { $0.inMajorNetwork(disconnectMeTrackers, majorTrackerNetworkStore) }) != nil ? 1 : 0
//    }

//    private var isMajorTrackerScore: Int {
//        guard let domain = domain else { return 0 }
//        if let network = majorTrackerNetworkStore.network(forName: domain) { return network.score }
//        if let network = majorTrackerNetworkStore.network(forDomain: domain) { return network.score }
//        return 0
//    }

    var isMajorTrackerNetwork: Bool {
        // Get the entity for the currect domain
        // Check entity prevalence
        return false
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

    public var scoreDict: [String: Any] {
//        let grade = siteGrade()
//        return [
//            "score": [
//                "domain": domain ?? "unknown",
//                "hasHttps": https,
//                "isAMajorTrackingNetwork": 0,
//                "containsMajorTrackingNetwork": containsMajorTracker,
//                "totalBlocked": totalTrackersBlocked,
//                "hasObscureTracker": containsIpTracker,
//                "tosdr": termsOfServiceScore
//            ],
//            "grade": [
//                "before": grade.before.rawValue.uppercased(),
//                "after": grade.after.rawValue.uppercased()
//            ]
//        ]
        return [:]
    }

    public var scoreDescription: String {
        guard let json = try? JSONSerialization.data(withJSONObject: scoreDict, options: .prettyPrinted) else {
            return "{}"
        }
        return String(data: json, encoding: .utf8)!
    }

    public func networkNameAndCategory(forDomain domain: String) -> ( networkName: String?, category: String? ) {
        let lowercasedDomain = domain.lowercased()
        if let tracker = disconnectMeTrackers.first(where: { lowercasedDomain == $0.key || lowercasedDomain.hasSuffix(".\($0.key)") })?.value {
            return ( tracker.networkName, tracker.category?.rawValue )
        }

//        if let majorNetwork = majorTrackerNetworkStore.network(forDomain: lowercasedDomain) {
//            return ( majorNetwork.name, nil )
//        }

        return ( nil, nil )
    }

}

public class GradeCache {

    public static let shared = GradeCache()

    private var cachedScores = [String: Grade.Scores]()

    private init() { }
    
    /**
     Adds a score to the cache. Only replaces a preexisting score if
     the new score is higher
     - returns: true if the cache was updated, otherwise false
     */
    func add(url: URL, scores: Grade.Scores) -> Bool {
        return compareAndSet(url: url, scores: scores)
    }

    private func compareAndSet(url: URL, scores current: Grade.Scores) -> Bool {
        let key = cacheKey(forUrl: url)
        if let previous = cachedScores[key], previous.site.score > current.site.score {
            return false
        }
        cachedScores[key] = current
        return true
    }

    func get(url: URL) -> Grade.Scores? {
        let key = cacheKey(forUrl: url)
        return cachedScores[key]
    }

    func reset() {
        cachedScores =  [String: Grade.Scores]()
    }

    private func cacheKey(forUrl url: URL) -> String {
        guard let domain = url.host else {
            return url.absoluteString
        }
        let scheme = url.scheme ?? URL.URLProtocol.http.rawValue
        return "\(scheme)_\(domain)"
    }
}

