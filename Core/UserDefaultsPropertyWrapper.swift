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
        case daxFireButtonEducationShownOrExpired = "com.duckduckgo.ios.daxfireButtonEducationShownOrExpired"
        case fireButtonPulseDateShown = "com.duckduckgo.ios.fireButtonPulseDateShown"

        case notFoundCache = "com.duckduckgo.ios.favicons.notFoundCache"
        case faviconsNeedMigration = "com.duckduckgo.ios.favicons.needsMigration"
        case faviconSizeNeedsMigration = "com.duckduckgo.ios.favicons.sizeNeedsMigration"

        case legacyCovidInfo = "com.duckduckgo.ios.home.covidInfo"
        
        case lastConfigurationRefreshDate = "com.duckduckgo.ios.lastConfigurationRefreshDate"
        case lastRemoteMessagingRefreshDate = "com.duckduckgo.ios.lastRemoteMessagingRefreshDate"

        case doNotSell = "com.duckduckgo.ios.sendDoNotSell"

        case backgroundFetchTaskDuration = "com.duckduckgo.app.bgFetchTaskDuration"
        case downloadedHTTPSBloomFilterSpecCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterSpecCount"
        case downloadedHTTPSBloomFilterCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterCount"
        case downloadedHTTPSExcludedDomainsCount = "com.duckduckgo.app.downloadedHTTPSExcludedDomainsCount"
        case downloadedSurrogatesCount = "com.duckduckgo.app.downloadedSurrogatesCount"
        case downloadedTrackerDataSetCount = "com.duckduckgo.app.downloadedTrackerDataSetCount"
        case downloadedPrivacyConfigurationCount = "com.duckduckgo.app.downloadedPrivacyConfigurationCount"
        case bookmarksMigratedFromUserDefaultsToCD = "com.duckduckgo.app.bookmarksMigratedFromUserDefaultsToCoreData"
        case textSize = "com.duckduckgo.ios.textSize"
        
        case emailWaitlistShouldReceiveNotifications = "com.duckduckgo.ios.showWaitlistNotification"
        case unseenDownloadsAvailable = "com.duckduckgo.app.unseenDownloadsAvailable"
        
        case lastCompiledRules = "com.duckduckgo.app.lastCompiledRules"

        case autofillSaveModalRejectionCount = "com.duckduckgo.ios.autofillSaveModalRejectionCount"
        case autofillSaveModalDisablePromptShown = "com.duckduckgo.ios.autofillSaveModalDisablePromptShown"
        case autofillFirstTimeUser = "com.duckduckgo.ios.autofillFirstTimeUser"
        case autofillCredentialsSavePromptShowAtLeastOnce = "com.duckduckgo.ios.autofillCredentialsSavePromptShowAtLeastOnce"
        case autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary =
                "com.duckduckgo.ios.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary"
        
        case featureFlaggingDidVerifyInternalUser = "com.duckduckgo.app.featureFlaggingDidVerifyInternalUser"
        
        case voiceSearchEnabled = "com.duckduckgo.app.voiceSearchEnabled"
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
            if let storedValue = UserDefaults.app.object(forKey: key.rawValue) as? T {
                return storedValue
            }
            
            if setIfEmpty {
                UserDefaults.app.set(defaultValue, forKey: key.rawValue)
            }
            
            return defaultValue
        }
        set {
            UserDefaults.app.set(newValue, forKey: key.rawValue)
        }
    }
}
