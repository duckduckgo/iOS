//
//  TrackerInfo.swift
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import TrackerRadarKit

public struct TrackerInfo: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case trackersDetected
        case trackersBlocked
        case installedSurrogates
    }
    
    // TODO: required temporarily for serialising the TrackerInfo into old format
    public var tds: TrackerData!
    
    private(set) var trackersDetected = Set<DetectedRequest>()
    private(set) var trackersBlocked = Set<DetectedRequest>()
    private(set) var installedSurrogates = Set<String>()

    public init() { }
    
    public mutating func add(detectedTracker: DetectedRequest) {
        if detectedTracker.isBlocked {
            trackersBlocked.insert(detectedTracker)
        } else {
            trackersDetected.insert(detectedTracker)
        }
    }

    public mutating func add(installedSurrogateHost: String) {
        installedSurrogates.insert(installedSurrogateHost)
    }

    var isEmpty: Bool {
        return trackersDetected.count == 0 &&
            trackersBlocked.count == 0 &&
            installedSurrogates.count == 0
    }

    // We need to adapt new DetectionRequest to old Privacy Dashboard API, code below should be removed once we finalize updated Dashboard
    public func encode(to encoder: Encoder) throws {
            
        let transformedDetectedRequests = trackersDetected.map { DetectedRequestAdapter.init(request: $0, tds: tds) }
        let transformedBlockedRequests = trackersBlocked.map { DetectedRequestAdapter.init(request: $0, tds: tds) }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(transformedBlockedRequests, forKey: .trackersBlocked)
        try container.encode(transformedDetectedRequests, forKey: .trackersDetected)
        try container.encode(installedSurrogates, forKey: .installedSurrogates)
    }

    final class DetectedRequestAdapter: Encodable {
        
        let url: String
        let pageUrl: String
        
        let blocked: Bool
        let knownTracker: KnownTracker?
        let entity: Entity?
        
        init(request: DetectedRequest, tds: TrackerData) {
            url = request.url
            pageUrl = request.pageUrl
            blocked = request.isBlocked
            
            if let tracker = tds.findTracker(forUrl: request.url),
               let entityName = tracker.owner?.name,
               let trackerEntity = tds.findEntity(byName: entityName) {
                knownTracker = tracker
                entity = trackerEntity
            } else {
                knownTracker = nil
                entity = nil
            }
        }
    }
}
