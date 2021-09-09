//
//  ContentBlockerRulesSource.swift
//  DuckDuckGo
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
import TrackerRadarKit

protocol ContentBlockerRulesSource {

    var trackerData: TrackerDataManager.DataSet? { get }
    var embeddedTrackerData: TrackerDataManager.DataSet { get }
    var tempListEtag: String { get }
    var tempList: [String] { get }
    var unprotectedSites: [String] { get }

}

class DefaultContentBlockerRulesSource: ContentBlockerRulesSource {

    var trackerData: TrackerDataManager.DataSet? {
        return TrackerDataManager.shared.fetchedData
    }

    var embeddedTrackerData: TrackerDataManager.DataSet {
        return TrackerDataManager.shared.embeddedData
    }

    var tempListEtag: String {
        return PrivacyConfigurationManager.shared.privacyConfig.identifier
    }

    var tempList: [String] {
        let config = PrivacyConfigurationManager.shared.privacyConfig
        var tempUnprotected = config.tempUnprotectedDomains.filter { !$0.trimWhitespace().isEmpty }
        tempUnprotected.append(contentsOf: config.exceptionsList(forFeature: .contentBlocking))
        return tempUnprotected
    }

    var unprotectedSites: [String] {
        return PrivacyConfigurationManager.shared.privacyConfig.userUnprotectedDomains
    }

}
