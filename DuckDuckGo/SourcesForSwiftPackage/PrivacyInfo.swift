//
//  PrivacyInfo.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit

public final class PrivacyInfo {
    
    private(set) var url: URL
    private(set) var parentEntity: Entity?
    
    @Published public var trackerInfo: TrackerInfo
    @Published private(set) var protectionStatus: ProtectionStatus
    @Published private(set) var serverTrust: ServerTrust?
    @Published public var connectionUpgradedTo: URL?
    
    public init(url: URL, parentEntity: Entity?, protectionStatus: ProtectionStatus, serverTrust: ServerTrust?) {
        self.url = url
        self.parentEntity = parentEntity
        self.protectionStatus = protectionStatus
        self.serverTrust = serverTrust
        trackerInfo = TrackerInfo()
    }
    
    public var https: Bool {
        return url.isHttps
    }
    
    public var domain: String? {
        return url.host
    }

    public var isMajorTrackerNetwork: Bool {
        return parentEntity?.prevalence ?? 0 >= TrackerInfo.Constants.majorNetworkPrevalence
    }
    
    public func isFor(_ url: URL?) -> Bool {
        return self.url.host == url?.host
    }
}
