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
        case faviconSizeNeedsMigration = "com.duckduckgo.ios.favicons.sizeNeedsMigration"
        case faviconTabsCacheNeedsCleanup = "com.duckduckgo.ios.favicons.tabsCacheNeedsCleanup"

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
        
        case autoconsentPromptSeen = "com.duckduckgo.ios.autoconsentPromptSeen"
        case autoconsentEnabled = "com.duckduckgo.ios.autoconsentEnabled"

        case shouldScheduleRulesCompilationOnAppLaunch = "com.duckduckgo.ios.shouldScheduleRulesCompilationOnAppLaunch"

        case lastAppTrackingProtectionHistoryFetchTimestamp = "com.duckduckgo.ios.appTrackingProtection.lastTrackerHistoryFetchTimestamp"
        case appTPUsed = "com.duckduckgo.ios.appTrackingProtection.appTPUsed"

        case defaultBrowserUsageLastSeen = "com.duckduckgo.ios.default-browser-usage-last-seen"

        case syncEnvironment = "com.duckduckgo.ios.sync-environment"
        case syncBookmarksPaused = "com.duckduckgo.ios.sync-bookmarksPaused"
        case syncCredentialsPaused = "com.duckduckgo.ios.sync-credentialsPaused"
        case syncBookmarksPausedErrorDisplayed = "com.duckduckgo.ios.sync-bookmarksPausedErrorDisplayed"
        case syncCredentialsPausedErrorDisplayed = "com.duckduckgo.ios.sync-credentialsPausedErrorDisplayed"
        case syncAutomaticallyFetchFavicons = "com.duckduckgo.ios.sync-automatically-fetch-favicons"
        case syncIsFaviconsFetcherEnabled = "com.duckduckgo.ios.sync-is-favicons-fetcher-enabled"
        case syncIsEligibleForFaviconsFetcherOnboarding = "com.duckduckgo.ios.sync-is-eligible-for-favicons-fetcher-onboarding"
        case syncDidPresentFaviconsFetcherOnboarding = "com.duckduckgo.ios.sync-did-present-favicons-fetcher-onboarding"
        case syncDidMigrateToImprovedListsHandling = "com.duckduckgo.ios.sync-did-migrate-to-improved-lists-handling"

        case networkProtectionDebugOptionAlwaysOnDisabled = "com.duckduckgo.network-protection.always-on.disabled"
        case networkProtectionWaitlistTermsAndConditionsAccepted = "com.duckduckgo.ios.vpn.terms-and-conditions-accepted"

        case addressBarPosition = "com.duckduckgo.ios.addressbarposition"
        case showFullSiteAddress = "com.duckduckgo.ios.showfullsiteaddress"
    }

    private let key: Key
    private let defaultValue: T
    private let setIfEmpty: Bool
    private let container: UserDefaults

    public init(key: Key, defaultValue: T, setIfEmpty: Bool = false, container: UserDefaults = .app) {
        self.key = key
        self.defaultValue = defaultValue
        self.setIfEmpty = setIfEmpty
        self.container = container
    }

    public var wrappedValue: T {
        get {
            if let storedValue = container.object(forKey: key.rawValue) as? T {
                return storedValue
            }
            
            if setIfEmpty {
                container.set(defaultValue, forKey: key.rawValue)
            }
            
            return defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key.rawValue)
            } else {
                container.setValue(newValue, forKey: key.rawValue)
            }
        }
    }
}

private protocol AnyOptional {
    
    var isNil: Bool { get }
    
}

extension Optional: AnyOptional {
    
    var isNil: Bool { self == nil }
    
}
