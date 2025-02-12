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
        case didCrashDuringCrashHandlersSetUp = "com.duckduckgo.ios.didCrashDuringCrashHandlersSetUp"

        case gridViewEnabled = "com.duckduckgo.ios.tabs.grid"
        case gridViewSeen = "com.duckduckgo.ios.tabs.seen"

        case fireproofingAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains2"
        case fireproofingDetectionEnabled = "com.duckduckgo.ios.PreserveLogins.detectionEnabled"
        case fireproofingLegacyAllowedDomains = "com.duckduckgo.ios.PreserveLogins.userDecision.allowedDomains"

        case daxIsDismissed = "com.duckduckgo.ios.daxOnboardingIsDismissed"
        case daxHomeScreenMessagesSeen = "com.duckduckgo.ios.daxOnboardingHomeScreenMessagesSeen"
        case daxBrowsingAfterSearchShown = "com.duckduckgo.ios.daxOnboardingBrowsingAfterSearchShown"
        case daxBrowsingWithTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithTrackersShown"
        case daxBrowsingWithoutTrackersShown = "com.duckduckgo.ios.daxOnboardingBrowsingWithoutTrackersShown"
        case daxBrowsingMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingMajorTrackingSiteShown"
        case daxBrowsingOwnedByMajorTrackingSiteShown = "com.duckduckgo.ios.daxOnboardingBrowsingOwnedByMajorTrackingSiteShown"
        case daxFireButtonEducationShownOrExpired = "com.duckduckgo.ios.daxfireButtonEducationShownOrExpired"
        case daxFireMessageExperimentShown = "com.duckduckgo.ios.fireMessageShown"
        case fireButtonPulseDateShown = "com.duckduckgo.ios.fireButtonPulseDateShown"
        case privacyButtonPulseShown = "com.duckduckgo.ios.privacyButtonPulseShown"
        case daxBrowsingFinalDialogShown = "com.duckduckgo.ios.daxOnboardingFinalDialogSeen"
        case daxLastVisitedOnboardingWebsite = "com.duckduckgo.ios.daxOnboardingLastVisitedWebsite"
        case daxLastShownContextualOnboardingDialogType = "com.duckduckgo.ios.daxLastShownContextualOnboardingDialogType"

        case notFoundCache = "com.duckduckgo.ios.favicons.notFoundCache"
        case faviconTabsCacheNeedsCleanup = "com.duckduckgo.ios.favicons.tabsCacheNeedsCleanup"

        case legacyCovidInfo = "com.duckduckgo.ios.home.covidInfo"

        case lastConfigurationRefreshDate = "com.duckduckgo.ios.lastConfigurationRefreshDate"
        case lastConfigurationUpdateDate = "com.duckduckgo.ios.lastConfigurationUpdateDate"
        case lastRemoteMessagingRefreshDate = "com.duckduckgo.ios.lastRemoteMessagingRefreshDate"

        case doNotSell = "com.duckduckgo.ios.sendDoNotSell"

        case backgroundFetchTaskDuration = "com.duckduckgo.app.bgFetchTaskDuration"
        case downloadedHTTPSBloomFilterSpecCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterSpecCount"
        case downloadedHTTPSBloomFilterCount = "com.duckduckgo.app.downloadedHTTPSBloomFilterCount"
        case downloadedHTTPSExcludedDomainsCount = "com.duckduckgo.app.downloadedHTTPSExcludedDomainsCount"
        case downloadedSurrogatesCount = "com.duckduckgo.app.downloadedSurrogatesCount"
        case downloadedTrackerDataSetCount = "com.duckduckgo.app.downloadedTrackerDataSetCount"
        case downloadedPrivacyConfigurationCount = "com.duckduckgo.app.downloadedPrivacyConfigurationCount"

        // Text size is the legacy name and this key is still in use
        case textZoom = "com.duckduckgo.ios.textSize"

        case emailWaitlistShouldReceiveNotifications = "com.duckduckgo.ios.showWaitlistNotification"
        case unseenDownloadsAvailable = "com.duckduckgo.app.unseenDownloadsAvailable"

        case lastCompiledRules = "com.duckduckgo.app.lastCompiledRules"

        case autofillSaveModalRejectionCount = "com.duckduckgo.ios.autofillSaveModalRejectionCount"
        case autofillSaveModalDisablePromptShown = "com.duckduckgo.ios.autofillSaveModalDisablePromptShown"
        case autofillFirstTimeUser = "com.duckduckgo.ios.autofillFirstTimeUser"
        case autofillCredentialsSavePromptShowAtLeastOnce = "com.duckduckgo.ios.autofillCredentialsSavePromptShowAtLeastOnce"
        case autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary =
                "com.duckduckgo.ios.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary"
        case autofillImportViaSyncStart = "com.duckduckgo.ios.autofillImportViaSyncStart"
        case autofillSearchDauDate = "com.duckduckgo.app.autofill.SearchDauDate"
        case autofillFillDate = "com.duckduckgo.app.autofill.FillDate"
        case autofillOnboardedUser = "com.duckduckgo.app.autofill.OnboardedUser"
        case autofillSurveysCompleted = "com.duckduckgo.app.autofill.SurveysCompleted"
        case autofillExtensionEnabled = "com.duckduckgo.app.autofill.ExtensionEnabled"
        case autofillVaultMigrated = "com.duckduckgo.app.autofill.VaultMigrated"

        case syncPromoBookmarksDismissed = "com.duckduckgo.app.sync.PromoBookmarksDismissed"
        case syncPromoPasswordsDismissed = "com.duckduckgo.app.sync.PromoPasswordsDismissed"

        // .v2 suffix added to fix https://app.asana.com/0/547792610048271/1206524375402369/f
        case featureFlaggingDidVerifyInternalUser = "com.duckduckgo.app.featureFlaggingDidVerifyInternalUser.v2"

        case voiceSearchEnabled = "com.duckduckgo.app.voiceSearchEnabled"

        case autoconsentEnabled = "com.duckduckgo.ios.autoconsentEnabled"

        case shouldScheduleRulesCompilationOnAppLaunch = "com.duckduckgo.ios.shouldScheduleRulesCompilationOnAppLaunch"

        case defaultBrowserUsageLastSeen = "com.duckduckgo.ios.default-browser-usage-last-seen"

        case syncEnvironment = "com.duckduckgo.ios.sync-environment"
        case syncBookmarksPaused = "com.duckduckgo.ios.sync-bookmarksPaused"
        case syncCredentialsPaused = "com.duckduckgo.ios.sync-credentialsPaused"
        case syncIsPaused = "sync.paused"
        case syncBookmarksPausedErrorDisplayed = "com.duckduckgo.ios.sync-bookmarksPausedErrorDisplayed"
        case syncCredentialsPausedErrorDisplayed = "com.duckduckgo.ios.sync-credentialsPausedErrorDisplayed"
        case syncInvalidLoginPausedErrorDisplayed = "sync.invalid-login-paused-error-displayed"
        case syncAutomaticallyFetchFavicons = "com.duckduckgo.ios.sync-automatically-fetch-favicons"
        case syncIsFaviconsFetcherEnabled = "com.duckduckgo.ios.sync-is-favicons-fetcher-enabled"
        case syncIsEligibleForFaviconsFetcherOnboarding = "com.duckduckgo.ios.sync-is-eligible-for-favicons-fetcher-onboarding"
        case syncDidPresentFaviconsFetcherOnboarding = "com.duckduckgo.ios.sync-did-present-favicons-fetcher-onboarding"
        case syncDidMigrateToImprovedListsHandling = "com.duckduckgo.ios.sync-did-migrate-to-improved-lists-handling"
        case syncDidShowSyncPausedByFeatureFlagAlert = "com.duckduckgo.ios.sync-did-show-sync-paused-by-feature-flag-alert"
        case syncLastErrorNotificationTime = "sync.last-error-notification-time"
        case syncLastSuccesfullTime = "sync.last-time-success"
        case syncLastNonActionableErrorCount = "sync.non-actionable-error-count"
        case syncCurrentAllPausedError = "sync.current-all-paused-error"
        case syncCurrentBookmarksPausedError = "sync.current-bookmarks-paused-error"
        case syncCurrentCredentialsPausedError = "sync.current-credentials-paused-error"

        case networkProtectionDebugOptionAlwaysOnDisabled = "com.duckduckgo.network-protection.always-on.disabled"
        case networkProtectionWaitlistTermsAndConditionsAccepted = "com.duckduckgo.ios.vpn.terms-and-conditions-accepted"

        case addressBarPosition = "com.duckduckgo.ios.addressbarposition"
        case showFullURLAddress = "com.duckduckgo.ios.showfullurladdress"

        case bookmarksLastGoodVersion = "com.duckduckgo.ios.bookmarksLastGoodVersion"
        case bookmarksMigrationVersion = "com.duckduckgo.ios.bookmarksMigrationVersion"

        case privacyConfigCustomURL = "com.duckduckgo.ios.privacyConfigCustomURL"

        case privacyProEnvironment = "com.duckduckgo.ios.privacyPro.environment"

        case appleAdAttributionReportCompleted = "com.duckduckgo.ios.appleAdAttributionReport.completed"

        case refreshTimestamps = "com.duckduckgo.ios.pageRefreshMonitor.refreshTimestamps"
        case lastBrokenSiteToastShownDate = "com.duckduckgo.ios.userBehavior.lastBrokenSiteToastShownDate"
        case toastDismissStreakCounter = "com.duckduckgo.ios.userBehavior.toastDismissStreakCounter"

        case pixelExperimentInstalled = "com.duckduckgo.ios.pixel.experiment.installed"
        case pixelExperimentCohort = "com.duckduckgo.ios.pixel.experiment.cohort"
        case pixelExperimentEnrollmentDate = "com.duckduckgo.ios.pixel.experiment.enrollment.date"

        case historyMessageDisplayCount = "com.duckduckgo.ios.historyMessage.displayCount"
        case historyMessageDismissed = "com.duckduckgo.ios.historyMessage.dismissed"
        
        case duckPlayerMode = "com.duckduckgo.ios.duckPlayerMode"
        case duckPlayerAskModeOverlayHidden = "com.duckduckgo.ios.duckPlayerAskModeOverlayHidden"
        case userInteractedWithDuckPlayer = "com.duckduckgo.ios.userInteractedWithDuckPlayer"
        case duckPlayerOpenInNewTab = "com.duckduckgo.ios.duckPlayerOpenInNewTab"
        case duckPlayerNativeUI = "com.duckduckgo.ios.duckPlayerNativeUI"
        case duckPlayerAutoplay = "com.duckduckgo.ios.duckPlayerAutoplay"

        case vpnRedditWorkaroundInstalled = "com.duckduckgo.ios.vpn.workaroundInstalled"

        case newTabPageSectionsSettings = "com.duckduckgo.ios.newTabPage.sections.settings"
        case newTabPageShortcutsSettings = "com.duckduckgo.ios.newTabPage.shortcuts.settings"
        case newTabPageIntroMessageEnabled = "com.duckduckgo.ios.newTabPage.introMessageEnabled"
        case newTabPageIntroMessageSeenCount = "com.duckduckgo.ios.newTabPage.introMessageSeenCount"

        // Debug keys
        case debugNewTabPageSectionsEnabledKey = "com.duckduckgo.ios.debug.newTabPageSectionsEnabled"
        case debugOnboardingHighlightsEnabledKey = "com.duckduckgo.ios.debug.onboardingHighlightsEnabled"
        case debugWebViewStateRestorationEnabledKey = "com.duckduckgo.ios.debug.webViewStateRestorationEnabled"

        // Domain specific text zoom
        case domainTextZoomStorage = "com.duckduckgo.ios.domainTextZoomStorage"

        // TipKit
        case resetTipKitOnNextLaunch = "com.duckduckgo.ios.tipKit.resetOnNextLaunch"

        // Malicious Site Protection
        case maliciousSiteProtectionEnabled = "com.duckduckgo.ios.maliciousSiteProtection.enabled"
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
