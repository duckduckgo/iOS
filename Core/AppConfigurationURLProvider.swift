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

struct AppConfigurationURLProvider: ConfigurationURLProviding {

    func url(for configuration: Configuration) -> URL {
        let appURLs = AppURLs()
        
        switch configuration {
        case .bloomFilterSpec: return appURLs.bloomFilterSpec
        case .bloomFilterBinary: return appURLs.bloomFilter
        case .bloomFilterExcludedDomains: return appURLs.bloomFilterExcludedDomains
        case .privacyConfiguration: return appURLs.privacyConfig
        case .trackerDataSet: return appURLs.trackerDataSet
        case .surrogates: return appURLs.surrogates
        case .FBConfig: fatalError("This feature is not supported on iOS")
        }
    }

}
