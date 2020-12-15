//
//  UserDefaultsPropertyWrapper.swift
//  Core
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

// Inspired by https://swiftsenpai.com/swift/create-the-perfect-userdefaults-wrapper-using-property-wrapper/

// enums are not supported on iOS 12 due to a bug in JSONEncoder, so just use primitive types or NSCodables

@propertyWrapper
public struct UserDefaultsWrapper<T> {

    public enum Key: String, CaseIterable {

        case layout = "com.duckduckgo.ios.home.layout"
        case favorites = "com.duckduckgo.ios.home.favorites"
        case keyboardOnNewTab = "com.duckduckgo.ios.keyboard.newtab"
        case keyboardOnAppLaunch = "com.duckduckgo.ios.keyboard.applaunch"
        
        case gridViewEnabled = "com.duckduckgo.ios.tabs.grid"
        case gridViewSeen = "com.duckduckgo.ios.tabs.seen"
        
        case preserveLoginsAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains2"
        case preserveLoginsDetectionEnabled = "com.duckduckgo.ios.PreserveLogins.detectionEnabled"
        case preserveLoginsLegacyAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains"

        case daxIsDismissed = "com.duckduckgo.ios.daxOnboardingIsDismissed"
        case daxHomeScreenMessagesSeen = "com.duckduckgo.ios.daxOnboardingHomeScreenMessagesSeen"
        case daxBrowsingAfterSearchShown = "com.duckduckgo.ios.daxOnboardingBrowsingAfterSearchShown"
        case daxBrowsingWithTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithTrackersShown"
        case daxBrowsingWithoutTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithoutTrackersShown"
        case daxBrowsingMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingMajorTrackingSiteShown"
        case daxBrowsingOwnedByMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingOwnedByMajorTrackingSiteShown"

        case notFoundCache = "com.duckduckgo.ios.favicons.notFoundCache"
        case faviconsNeedMigration = "com.duckduckgo.ios.favicons.needsMigration"

        case legacyCovidInfo = "com.duckduckgo.ios.home.covidInfo"
        
        case homeDefaultBrowserMessageDateDismissed = "com.duckduckgo.ios.homeMessage.defaultBrowser.dateDismissed"

        case lastConfigurationRefreshDate = "com.duckduckgo.ios.lastConfigurationRefreshDate"
        
        case doNotSell = "com.duckduckgo.ios.sendDoNotSell"

        case backgroundFetchTaskExpirationCount = "com.duckduckgo.app.bgFetchTaskExpirationCount"
        case backgroundFetchTaskDuration = "com.duckduckgo.app.bgFetchTaskDuration"
        case downloadedHTTPSBloomFilterSpecCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterSpecCount"
        case downloadedHTTPSBloomFilterCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterCount"
        case downloadedHTTPSExcludedDomainsCount = "com.duckduckgo.app.downloadedHTTPSExcludedDomainsCount"
        case downloadedSurrogatesCount = "com.duckduckgo.app.downloadedSurrogatesCount"
        case downloadedTrackerDataSetCount = "com.duckduckgo.app.downloadedTrackerDataSetCount"
        case downloadedTemporaryUnprotectedSitesCount = "com.duckduckgo.app.downloadedTemporaryUnprotectedSitesCount"
    }

    private let key: Key
    private let defaultValue: T
    private let setIfEmpty: Bool

    public init(key: Key, defaultValue: T, setIfEmpty: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.setIfEmpty = setIfEmpty
    }

    public var wrappedValue: T {
        get {
            if let storedValue = UserDefaults.standard.object(forKey: key.rawValue) as? T {
                return storedValue
            }
            
            if setIfEmpty {
                UserDefaults.standard.set(defaultValue, forKey: key.rawValue)
            }
            
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}
