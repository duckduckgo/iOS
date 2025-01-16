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

    private let trackerDataUrlProvider: TrackerDataURLProviding

    /// Default initializer using shared dependencies.
    init (privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
          featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.trackerDataUrlProvider = TrackerDataURLOverrider(privacyConfigurationManager: privacyConfigurationManager, featureFlagger: featureFlagger)
    }

    /// Initializer for injecting a custom TrackerDataURLProvider.
    internal init (trackerDataUrlProvider: TrackerDataURLProviding) {
        self.trackerDataUrlProvider = trackerDataUrlProvider
    }

    func url(for configuration: Configuration) -> URL {
        switch configuration {
        case .bloomFilterSpec: return URL.bloomFilterSpec
        case .bloomFilterBinary: return URL.bloomFilter
        case .bloomFilterExcludedDomains: return URL.bloomFilterExcludedDomains
        case .privacyConfiguration: return URL.privacyConfig
        case .trackerDataSet: return trackerDataUrlProvider.trackerDataURL ?? URL.trackerDataSet
        case .surrogates: return URL.surrogates
        case .remoteMessagingConfig: return RemoteMessagingClient.Constants.endpoint
        }
    }
}
