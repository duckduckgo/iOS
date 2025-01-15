//
//  AppConfigurationURLProvider.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Configuration
import Core
import BrowserServicesKit

struct AppConfigurationURLProvider: ConfigurationURLProviding {

    var privacyConfigurationManager: PrivacyConfigurationManaging
    var featureFlagger: FeatureFlagger

    init (privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
          featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.privacyConfigurationManager = privacyConfigurationManager
        self.featureFlagger = featureFlagger
    }

    func url(for configuration: Configuration) -> URL {
        switch configuration {
        case .bloomFilterSpec: return URL.bloomFilterSpec
        case .bloomFilterBinary: return URL.bloomFilter
        case .bloomFilterExcludedDomains: return URL.bloomFilterExcludedDomains
        case .privacyConfiguration: return URL.privacyConfig
        case .trackerDataSet: return trackerDataURL()
        case .surrogates: return URL.surrogates
        case .remoteMessagingConfig: return RemoteMessagingClient.Constants.endpoint
        }
    }

    private func trackerDataURL() -> URL {
        for experimentType in TdsExperimentType.allCases {
            if let cohort = featureFlagger.getCohortIfEnabled(for: experimentType.experiment) as? TdsNextExperimentFlag.Cohort,
               let url = trackerDataURL(for: experimentType.subfeature, cohort: cohort) {
                return url
            }
        }
        return URL.trackerDataSet
    }

    private func trackerDataURL(for subfeature: any PrivacySubfeature, cohort: TdsNextExperimentFlag.Cohort) -> URL? {
        guard let settings = privacyConfigurationManager.privacyConfig.settings(for: subfeature),
              let jsonData = settings.data(using: .utf8) else { return nil }
        do {
            if let settingsDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: String],
               let urlString = cohort == .control ? settingsDict["controlUrl"] : settingsDict["treatmentUrl"] {
                return URL(string: URL.staticBase + "/trackerblocking/" + urlString)!
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }
        return nil
    }

}

public enum TdsExperimentType: Int, CaseIterable {
    case baseline
    case feb25
    case mar25
    case apr25
    case may25
    case jun25
    case jul25
    case aug25
    case sep25
    case oct25
    case nov25
    case dec25

    var experiment: any FeatureFlagExperimentDescribing {
        TdsNextExperimentFlag(subfeature: self.subfeature)
    }

    var subfeature: any PrivacySubfeature {
        switch self {
        case .baseline:
            ContentBlockingSubfeature.tdsNextExperimentBaseline
        case .feb25:
            ContentBlockingSubfeature.tdsNextExperimentFeb25
        case .mar25:
            ContentBlockingSubfeature.tdsNextExperimentMar25
        case .apr25:
            ContentBlockingSubfeature.tdsNextExperimentApr25
        case .may25:
            ContentBlockingSubfeature.tdsNextExperimentMay25
        case .jun25:
            ContentBlockingSubfeature.tdsNextExperimentJun25
        case .jul25:
            ContentBlockingSubfeature.tdsNextExperimentJul25
        case .aug25:
            ContentBlockingSubfeature.tdsNextExperimentAug25
        case .sep25:
            ContentBlockingSubfeature.tdsNextExperimentSep25
        case .oct25:
            ContentBlockingSubfeature.tdsNextExperimentOct25
        case .nov25:
            ContentBlockingSubfeature.tdsNextExperimentNov25
        case .dec25:
            ContentBlockingSubfeature.tdsNextExperimentDec25
        }
    }

}

public struct TdsNextExperimentFlag: FeatureFlagExperimentDescribing {
    public var rawValue: String
    public var source: FeatureFlagSource

    init(subfeature: any PrivacySubfeature) {
        self.source = .remoteReleasable(.subfeature(subfeature))
        self.rawValue = subfeature.rawValue
    }

    public typealias CohortType = Cohort

    public enum Cohort: String, FlagCohort {
        case control
        case treatment
    }
}
