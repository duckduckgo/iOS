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
import os.log

public class SiteRating {

    struct Constants {
        static let majorNetworkPrevalence = 7.0
    }
    
    public enum EncryptionType {
        case unencrypted, mixed, encrypted, forced
    }

    public var domain: String? {
        return url.host
    }
    
    public var scores: Grade.Scores {
        if let scores = cache.get(url: url), scores.site.score > grade.scores.site.score {
            return scores
        }
        return grade.scores
    }

    public let url: URL
    public let httpsForced: Bool
    public let privacyPractice: PrivacyPractices.Practice
    
    public var hasOnlySecureContent: Bool
    public var finishedLoading = false
    public private (set) var trackersDetected = Set<DetectedTracker>()
    public private (set) var trackersBlocked = Set<DetectedTracker>()
    
    private let grade = Grade()
    private let cache = GradeCache.shared
    private let entity: Entity?
    
    public init(url: URL,
                httpsForced: Bool = false,
                entityMapping: EntityMapping,
                privacyPractices: PrivacyPractices) {

        os_log("new SiteRating(url: %s, httpsForced: %s)", log: lifecycleLog, type: .debug, url.absoluteString, httpsForced)

        if let host = url.host, let entity = entityMapping.findEntity(forHost: host) {
            self.grade.setParentEntity(named: entity.displayName ?? "", withPrevalence: entity.prevalence ?? 0)
            self.entity = entity
        } else {
            entity = nil
        }

        self.url = url
        self.httpsForced = httpsForced
        self.hasOnlySecureContent = url.isHttps()
        self.privacyPractice = privacyPractices.findPractice(forHost: url.host ?? "")
        
        // This will change when there is auto upgrade data.  The default is false, but we don't penalise sites at this time so if the url is https
        //  then we assume auto upgrade is available for the purpose of grade scoring.
        self.grade.httpsAutoUpgrade = url.isHttps()
        self.grade.https = url.isHttps()
        self.grade.privacyScore = privacyPractice.score
        
    }
    
    public var https: Bool {
        return url.isHttps()
    }

    public var encryptionType: EncryptionType {
        if hasOnlySecureContent {
            return httpsForced ? .forced : .encrypted
        } else if https {
            return .mixed
        }

        return .unencrypted
    }

    public var majorTrackerNetworksDetected: Int {
        return trackersDetected.filter({ $0.entity?.prevalence ?? 0 >= Constants.majorNetworkPrevalence }).count
    }

    public var majorTrackerNetworksBlocked: Int {
        return trackersBlocked.filter({ $0.entity?.prevalence ?? 0 >= Constants.majorNetworkPrevalence }).count
    }

    public var trackerNetworksDetected: Int {
        return trackersDetected.filter({ $0.entity?.prevalence ?? 0 < Constants.majorNetworkPrevalence }).count
    }

    public var uniqueTrackerNetworksBlocked: Int {
        return trackersBlocked.filter({ $0.entity?.prevalence ?? 0 < Constants.majorNetworkPrevalence }).count
    }

    public var containsMajorTracker: Bool {
        return majorTrackerNetworksBlocked > 0 || majorTrackerNetworksDetected > 0
    }
    
    public var isMajorTrackerNetwork: Bool {
        return entity?.prevalence ?? 0 >= Constants.majorNetworkPrevalence
    }

    public func trackerDetected(_ tracker: DetectedTracker) {
        let entity = tracker.entity
        if tracker.blocked {
            trackersBlocked.insert(tracker)
            grade.addEntityBlocked(named: entity?.displayName ?? "", withPrevalence: entity?.prevalence ?? 0)
        } else {
            trackersDetected.insert(tracker)
            grade.addEntityNotBlocked(named: entity?.displayName ?? "", withPrevalence: entity?.prevalence ?? 0)
        }
    }

    public var totalTrackersDetected: Int {
        return trackersDetected.count
    }

    public var totalTrackersBlocked: Int {
        return trackersBlocked.count
    }
    
    public func isFor(_ url: URL?) -> Bool {
        return self.url.host == url?.host
    }

}
