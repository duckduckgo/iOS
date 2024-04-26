//
//  PixelEvent.swift
//  DuckDuckGo
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
import BrowserServicesKit
import Bookmarks
import Configuration
import DDGSync
import NetworkProtection

extension Pixel {
    
    // swiftlint:disable:next type_body_length
    public enum Event {
        
        case appLaunch
        case refreshPressed
        case pullToRefresh

        case deviceOrientationLandscape

        case keyboardGoWhileOnNTP
        case keyboardGoWhileOnWebsite
        case keyboardGoWhileOnSERP

        case forgetAllPressedBrowsing
        case forgetAllPressedTabSwitching
        case forgetAllExecuted
        case forgetAllDataCleared
        
        case privacyDashboardOpened
        
        case dashboardProtectionAllowlistAdd
        case dashboardProtectionAllowlistRemove
        
        case privacyDashboardReportBrokenSite
        
        case tabSwitcherNewLayoutSeen
        case tabSwitcherListEnabled
        case tabSwitcherGridEnabled
        case tabSwitcherNewTab
        case tabSwitcherSwitchTabs
        case tabSwitcherClickCloseTab
        case tabSwitcherSwipeCloseTab
        case tabSwitchLongPressNewTab

        case settingsDoNotSellShown
        case settingsDoNotSellOn
        case settingsDoNotSellOff
        
        case settingsAutoconsentShown
        case settingsAutoconsentOn
        case settingsAutoconsentOff
        
        case browsingMenuOpened
        case browsingMenuNewTab
        case browsingMenuAddToBookmarks
        case browsingMenuEditBookmark
        case browsingMenuAddToFavorites
        case browsingMenuRemoveFromFavorites
        case browsingMenuAddToFavoritesAddFavoriteFlow
        case browsingMenuToggleBrowsingMode
        case browsingMenuShare
        case browsingMenuCopy
        case browsingMenuPrint
        case browsingMenuFindInPage
        case browsingMenuDisableProtection
        case browsingMenuEnableProtection
        case browsingMenuReportBrokenSite
        case browsingMenuFireproof
        case browsingMenuAutofill
        
        case addressBarShare
        case addressBarSettings
        case addressBarCancelPressedOnNTP
        case addressBarCancelPressedOnWebsite
        case addressBarCancelPressedOnSERP
        case addressBarClickOnNTP
        case addressBarClickOnWebsite
        case addressBarClickOnSERP
        case addressBarClearPressedOnNTP
        case addressBarClearPressedOnWebsite
        case addressBarClearPressedOnSERP
        case addressBarGestureDismiss

        case shareSheetResultSuccess
        case shareSheetResultFail
        case shareSheetActivityCopy
        case shareSheetActivityAddBookmark
        case shareSheetActivityAddFavorite
        case shareSheetActivityFindInPage
        case shareSheetActivityPrint
        case shareSheetActivityAddToReadingList
        case shareSheetActivityOther
        
        case tabBarBackPressed
        case tabBarForwardPressed
        case bookmarksButtonPressed
        case tabBarBookmarksLongPressed
        case tabBarTabSwitcherPressed
        
        case homeScreenShown
        case homeScreenEditFavorite
        case homeScreenDeleteFavorite

        case favoriteLaunchedNTP
        case favoriteLaunchedWebsite
        case favoriteLaunchedWidget

        case autocompleteClickPhrase
        case autocompleteClickWebsite
        case autocompleteClickBookmark
        case autocompleteClickFavorite
        case autocompleteClickHistory

        case feedbackPositive
        case feedbackNegativePrefix(category: String)
        
        case brokenSiteReport
        
        case daxDialogsSerp
        case daxDialogsWithoutTrackers
        case daxDialogsWithoutTrackersFollowUp
        case daxDialogsWithTrackers
        case daxDialogsSiteIsMajor
        case daxDialogsSiteOwnedByMajor
        case daxDialogsHidden
        case daxDialogsFireEducationShown
        case daxDialogsFireEducationConfirmed
        case daxDialogsFireEducationCancelled
        
        case widgetsOnboardingCTAPressed
        case widgetsOnboardingDeclineOptionPressed
        case widgetsOnboardingMovedToBackground
        
        case emailEnabled
        case emailDisabled
        case emailUserPressedUseAddress
        case emailUserPressedUseAlias
        case emailUserCreatedAlias
        case emailTooltipDismissed
        
        case voiceSearchDone
        case openVoiceSearch
        case voiceSearchCancelled

        case bookmarkLaunchList
        case bookmarkLaunchScored
        case bookmarkAddFavoriteFromBookmark
        case bookmarkRemoveFavoriteFromBookmark
        case bookmarkAddFavoriteBySwipe
        case bookmarkDeletedFromBookmark

        case bookmarkImportSuccess
        case bookmarkImportFailure
        case bookmarkImportFailureParsingDL
        case bookmarkImportFailureParsingBody
        case bookmarkImportFailureTransformingSafari
        case bookmarkImportFailureSaving
        case bookmarkImportFailureUnknown
        case bookmarkExportSuccess
        case bookmarkExportFailure

        case textSizeSettingsChanged
        
        case downloadStarted
        case downloadStartedDueToUnhandledMIMEType
        case downloadTriedToPresentPreviewWithoutTab
        case downloadsListOpened
        
        case downloadsListOngoingDownloadCancelled
        case downloadsListCompleteDownloadDeleted
        case downloadsListAllCompleteDownloadsDeleted
        case downloadsListDeleteUndo
        case downloadsListSharePressed
        
        case downloadsSharingPredownloadedLocalFile
        
        case downloadAttemptToOpenBLOBviaJS
        
        case jsAlertShown
        
        case featureFlaggingInternalUserAuthenticated
        
        case autofillLoginsSaveLoginModalDisplayed
        case autofillLoginsSaveLoginModalConfirmed
        case autofillLoginsSaveLoginModalDismissed
        case autofillLoginsSaveLoginModalExcludeSiteConfirmed
        
        case autofillLoginsSavePasswordModalDisplayed
        case autofillLoginsSavePasswordModalConfirmed
        case autofillLoginsSavePasswordModalDismissed
        
        case autofillLoginsUpdatePasswordModalDisplayed
        case autofillLoginsUpdatePasswordModalConfirmed
        case autofillLoginsUpdatePasswordModalDismissed
        
        case autofillLoginsUpdateUsernameModalDisplayed
        case autofillLoginsUpdateUsernameModalConfirmed
        case autofillLoginsUpdateUsernameModalDismissed
        
        case autofillLoginsFillLoginInlineManualDisplayed
        case autofillLoginsFillLoginInlineManualConfirmed
        case autofillLoginsFillLoginInlineManualDismissed
        
        case autofillLoginsFillLoginInlineAutopromptDisplayed
        case autofillLoginsFillLoginInlineAutopromptConfirmed
        
        case autofillLoginsFillLoginInlineAuthenticationDeviceDisplayed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled
        case autofillLoginsAutopromptDismissed
        
        case autofillLoginsFillLoginInlineDisablePromptShown
        case autofillLoginsFillLoginInlineDisablePromptAutofillKept
        case autofillLoginsFillLoginInlineDisablePromptAutofillDisabled
        
        case autofillSettingsOpened
        case autofillLoginsSettingsEnabled
        case autofillLoginsSettingsDisabled
        case autofillLoginsSettingsResetExcludedDisplayed
        case autofillLoginsSettingsResetExcludedConfirmed
        case autofillLoginsSettingsResetExcludedDismissed
        
        case autofillLoginsPasswordGenerationPromptDisplayed
        case autofillLoginsPasswordGenerationPromptConfirmed
        case autofillLoginsPasswordGenerationPromptDismissed

        case autofillLoginsLaunchWidgetHome
        case autofillLoginsLaunchWidgetLock
        case autofillLoginsLaunchAppShortcut

        case autofillJSPixelFired(_ pixel: AutofillUserScript.JSPixel)
        
        case secureVaultError
        
        case secureVaultInitFailedError
        case secureVaultFailedToOpenDatabaseError
        
        // Replacing secureVaultIsEnabledCheckedWhenEnabledAndBackgrounded with data protection check
        case secureVaultIsEnabledCheckedWhenEnabledAndDataProtected
        
        // MARK: Ad Click Attribution pixels
        
        case adClickAttributionDetected
        case adClickAttributionActive
        case adClickAttributionPageLoads
        
        // MARK: SERP pixels
        
        case serpRequerySame
        case serpRequeryNew
        
        // MARK: AppTP
        case appTPBreakageReport
        
        case appTPFailedToCreateProxyServer
        case appTPFailedToSetTunnelNetworkSettings
        case appTPFailedToAccessPreferences
        case appTPFailedToAccessPreferencesDuringSetup
        case appTPFailedToStartTunnel
        
        case appTPVPNDisconnect
        case appTPVPNMemoryWarning
        case appTPVPNMemoryCritical
        
        case appTPBlocklistParseFailed
        case appTPActiveUser
        
        case appTPDBLocationFailed
        case appTPDBStoreLoadFailure
        case appTPDBPersistentStoreLoadFailure
        case appTPDBHistoryFailure
        case appTPDBHistoryFetchFailure
        case appTPDBFeedbackTrackerFetchFailed
        case appTPDBTrackerStoreFailure
        case appTPCouldNotLoadDatabase
        
        // MARK: Network Protection
        
        case networkProtectionActiveUser
        case networkProtectionNewUser

        case networkProtectionControllerStartAttempt
        case networkProtectionControllerStartSuccess
        case networkProtectionControllerStartFailure

        case networkProtectionTunnelStartAttempt
        case networkProtectionTunnelStartSuccess
        case networkProtectionTunnelStartFailure

        case networkProtectionTunnelUpdateAttempt
        case networkProtectionTunnelUpdateSuccess
        case networkProtectionTunnelUpdateFailure

        case networkProtectionEnableAttemptConnecting
        case networkProtectionEnableAttemptSuccess
        case networkProtectionEnableAttemptFailure
        
        case networkProtectionTunnelFailureDetected
        case networkProtectionTunnelFailureRecovered
        
        case networkProtectionLatency(quality: NetworkProtectionLatencyMonitor.ConnectionQuality)
        case networkProtectionLatencyError
        
        case networkProtectionEnabledOnSearch
        
        case networkProtectionBreakageReport

        case networkProtectionRekeyAttempt
        case networkProtectionRekeyFailure
        case networkProtectionRekeyCompleted
        
        case networkProtectionTunnelConfigurationNoServerRegistrationInfo
        case networkProtectionTunnelConfigurationCouldNotSelectClosestServer
        case networkProtectionTunnelConfigurationCouldNotGetPeerPublicKey
        case networkProtectionTunnelConfigurationCouldNotGetPeerHostName
        case networkProtectionTunnelConfigurationCouldNotGetInterfaceAddressRange
        
        case networkProtectionClientFailedToFetchServerList
        case networkProtectionClientFailedToParseServerListResponse
        case networkProtectionClientFailedToEncodeRegisterKeyRequest
        case networkProtectionClientFailedToFetchRegisteredServers
        case networkProtectionClientFailedToParseRegisteredServersResponse
        case networkProtectionClientFailedToFetchLocations
        case networkProtectionClientFailedToParseLocationsResponse
        case networkProtectionClientFailedToEncodeRedeemRequest
        case networkProtectionClientInvalidInviteCode
        case networkProtectionClientFailedToRedeemInviteCode
        case networkProtectionClientFailedToParseRedeemResponse
        case networkProtectionClientInvalidAuthToken
        
        case networkProtectionKeychainErrorFailedToCastKeychainValueToData
        case networkProtectionKeychainReadError
        case networkProtectionKeychainWriteError
        case networkProtectionKeychainUpdateError
        case networkProtectionKeychainDeleteError
        
        case networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor
        case networkProtectionWireguardErrorInvalidState
        case networkProtectionWireguardErrorFailedDNSResolution
        case networkProtectionWireguardErrorCannotSetNetworkSettings
        case networkProtectionWireguardErrorCannotStartWireguardBackend
        
        case networkProtectionFailedToLoadFromPreferences
        case networkProtectionFailedToSaveToPreferences
        case networkProtectionActivationRequestFailed
        case networkProtectionFailedToStartTunnel
        
        case networkProtectionDisconnected
        
        case networkProtectionNoAuthTokenFoundError
        
        case networkProtectionMemoryWarning
        case networkProtectionMemoryCritical
        
        case networkProtectionUnhandledError
        
        case networkProtectionGeoswitchingOpened
        case networkProtectionGeoswitchingSetNearest
        case networkProtectionGeoswitchingSetCustom
        case networkProtectionGeoswitchingNoLocations

        case networkProtectionFailureRecoveryStarted
        case networkProtectionFailureRecoveryFailed
        case networkProtectionFailureRecoveryCompletedHealthy
        case networkProtectionFailureRecoveryCompletedUnhealthy

        // MARK: remote messaging pixels
        
        case remoteMessageShown
        case remoteMessageShownUnique
        case remoteMessageDismissed
        case remoteMessageActionClicked
        case remoteMessagePrimaryActionClicked
        case remoteMessageSecondaryActionClicked
        case remoteMessageSheet
        
        // MARK: debug pixels
        case dbCrashDetected
        
        case dbMigrationError
        case dbRemovalError
        case dbDestroyError
        case dbDestroyFileError
        case dbContainerInitializationError
        case dbInitializationError
        case dbSaveExcludedHTTPSDomainsError
        case dbSaveBloomFilterError
        case dbRemoteMessagingSaveConfigError
        case dbRemoteMessagingInvalidateConfigError
        case dbRemoteMessagingSaveMessageError
        case dbRemoteMessagingUpdateMessageShownError
        case dbRemoteMessagingUpdateMessageStatusError
        case dbRemoteMessagingDeleteScheduledMessageError
        case dbLocalAuthenticationError
        
        case configurationFetchInfo
        
        case trackerDataParseFailed
        case trackerDataReloadFailed
        case trackerDataCouldNotBeLoaded
        case fileStoreWriteFailed
        case privacyConfigurationReloadFailed
        case privacyConfigurationParseFailed
        case privacyConfigurationCouldNotBeLoaded
        
        case contentBlockingCompilationFailed(listType: CompileRulesListType,
                                              component: ContentBlockerDebugEvents.Component)
        
        case contentBlockingCompilationTime
        
        case ampBlockingRulesCompilationFailed
        
        case webKitDidTerminate
        case webKitTerminationDidReloadCurrentTab
        case webKitDidTerminateDuringWarmup

        case webKitWarmupUnexpectedDidFinish
        case webKitWarmupUnexpectedDidTerminate

        case backgroundTaskSubmissionFailed
        
        case blankOverlayNotDismissed
        
        case cookieDeletionTimedOut
        case cookieDeletionLeftovers
        
        case cachedTabPreviewsExceedsTabCount
        case cachedTabPreviewRemovalError
        
        case missingDownloadedFile
        case unhandledDownload
        
        case compilationResult(result: CompileRulesResult, waitTime: CompileRulesWaitTime, appState: AppState)
        
        case emailAutofillKeychainError
        
        case adAttributionGlobalAttributedRulesDoNotExist
        case adAttributionCompilationFailedForAttributedRulesList
        
        case adAttributionLogicUnexpectedStateOnInheritedAttribution
        case adAttributionLogicUnexpectedStateOnRulesCompiled
        case adAttributionLogicUnexpectedStateOnRulesCompilationFailed
        case adAttributionDetectionHeuristicsDidNotMatchDomain
        case adAttributionDetectionInvalidDomainInParameter
        case adAttributionLogicRequestingAttributionTimedOut
        case adAttributionLogicWrongVendorOnSuccessfulCompilation
        case adAttributionLogicWrongVendorOnFailedCompilation
        
        case debugBookmarkOrphanFolderNew
        case debugBookmarkTopLevelMissingNew
        
        case debugFavoriteOrphanFolderNew
        case debugFavoriteTopLevelMissingNew
        
        case debugCouldNotFixBookmarkFolder
        case debugCouldNotFixFavoriteFolder
        
        case debugMissingTopFolderFixHasFavorites
        case debugMissingTopFolderFixHasBookmarks
        
        case debugCantSaveBookmarkFix
        
        case debugCannotClearObservationsDatabase
        case debugWebsiteDataStoresNotClearedMultiple
        case debugWebsiteDataStoresNotClearedOne
        case debugCookieCleanupError
        
        case debugBookmarksMigratedMoreThanOnce
        
        // Return user measurement
        case debugReturnUserAddATB
        case debugReturnUserUpdateATB
        
        // Errors from Bookmarks Module
        case bookmarkFolderExpected
        case bookmarksListIndexNotMatchingBookmark
        case bookmarksListMissingFolder
        case editorNewParentMissing
        case favoritesListIndexNotMatchingBookmark
        case fetchingRootItemFailed(BookmarksModelError.ModelType)
        case indexOutOfRange(BookmarksModelError.ModelType)
        case saveFailed(BookmarksModelError.ModelType)
        case missingParent(BookmarksModelError.ObjectType)
        
        case bookmarksCouldNotLoadDatabase
        case bookmarksCouldNotPrepareDatabase
        case bookmarksMigrationAlreadyPerformed
        case bookmarksMigrationFailed
        case bookmarksMigrationCouldNotPrepareDatabase
        case bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration
        case bookmarksMigrationCouldNotRemoveOldStore
        case bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders
        
        case syncSignupDirect
        case syncSignupConnect
        case syncLogin
        case syncDaily
        case syncDuckAddressOverride
        case syncSuccessRateDaily
        case syncLocalTimestampResolutionTriggered(Feature)
        case syncFailedToMigrate
        case syncFailedToLoadAccount
        case syncFailedToSetupEngine
        case syncBookmarksCountLimitExceededDaily
        case syncCredentialsCountLimitExceededDaily
        case syncBookmarksRequestSizeLimitExceededDaily
        case syncCredentialsRequestSizeLimitExceededDaily
        
        case syncSentUnauthenticatedRequest
        case syncMetadataCouldNotLoadDatabase
        case syncBookmarksFailed
        case syncCredentialsProviderInitializationFailed
        case syncCredentialsFailed
        case syncSettingsFailed
        case syncSettingsMetadataUpdateFailed
        case syncSignupError
        case syncLoginError
        case syncLogoutError
        case syncUpdateDeviceError
        case syncRemoveDeviceError
        case syncDeleteAccountError
        case syncLoginExistingAccountError

        case syncWrongEnvironment

        case swipeTabsUsed
        case swipeTabsUsedDaily
        case swipeToOpenNewTab

        case bookmarksCleanupFailed
        case bookmarksCleanupAttemptedWhileSyncWasEnabled
        case favoritesCleanupFailed
        case bookmarksFaviconsFetcherStateStoreInitializationFailed
        case bookmarksFaviconsFetcherFailed
        
        case credentialsDatabaseCleanupFailed
        case credentialsCleanupAttemptedWhileSyncWasEnabled
        
        case invalidPayload(Configuration)
        
        case emailIncontextPromptDisplayed
        case emailIncontextPromptConfirmed
        case emailIncontextPromptDismissed
        case emailIncontextPromptDismissedPersistent
        case emailIncontextModalDisplayed
        case emailIncontextModalDismissed
        case emailIncontextModalExitEarly
        case emailIncontextModalExitEarlyContinue
        
        case compilationFailed
        
        case appRatingPromptFetchError

        case protectionToggledOffBreakageReport
        case toggleProtectionsDailyCount
        case toggleReportDoNotSend
        case toggleReportDismiss

        case userBehaviorReloadTwice
        case userBehaviorReloadAndRestart
        case userBehaviorReloadAndFireButton
        case userBehaviorReloadAndOpenSettings
        case userBehaviorReloadAndTogglePrivacyControls
        case userBehaviorFireButtonAndRestart
        case userBehaviorFireButtonAndTogglePrivacyControls

        // MARK: History
        case historyStoreLoadFailed
        case historyRemoveFailed
        case historyReloadFailed
        case historyCleanEntriesFailed
        case historyCleanVisitsFailed
        case historySaveFailed
        case historyInsertVisitFailed
        case historyRemoveVisitsFailed

        // MARK: Privacy pro
        case privacyProSubscriptionActive
        case privacyProOfferScreenImpression
        case privacyProPurchaseAttempt
        case privacyProPurchaseFailure
        case privacyProPurchaseFailureStoreError
        case privacyProPurchaseFailureBackendError
        case privacyProPurchaseFailureAccountNotCreated
        case privacyProPurchaseSuccess
        case privacyProRestorePurchaseOfferPageEntry
        case privacyProRestorePurchaseClick
        case privacyProRestorePurchaseEmailStart
        case privacyProRestorePurchaseStoreStart
        case privacyProRestorePurchaseEmailSuccess
        case privacyProRestorePurchaseStoreSuccess
        case privacyProRestorePurchaseStoreFailureNotFound
        case privacyProRestorePurchaseStoreFailureOther
        case privacyProRestoreAfterPurchaseAttempt
        case privacyProSubscriptionActivated
        case privacyProWelcomeAddDevice
        case privacyProSettingsAddDevice
        case privacyProAddDeviceEnterEmail
        case privacyProWelcomeVPN
        case privacyProWelcomePersonalInformationRemoval
        case privacyProWelcomeIdentityRestoration
        case privacyProSubscriptionSettings
        case privacyProVPNSettings
        case privacyProPersonalInformationRemovalSettings
        case privacyProIdentityRestorationSettings
        case privacyProSubscriptionManagementEmail
        case privacyProSubscriptionManagementPlanBilling
        case privacyProSubscriptionManagementRemoval
        case privacyProFeatureEnabled
        case privacyProVPNAccessRevokedDialogShown
        case privacyProVPNBetaStoppedWhenPrivacyProEnabled
        case privacyProTransactionProgressNotHiddenAfter60s

        // MARK: Pixel Experiment
        case pixelExperimentEnrollment
        case settingsPresented
        case settingsSetAsDefault
        case settingsPrivateSearchOpen
        case settingsPrivateSearchAutocompleteOn
        case settingsPrivateSearchAutocompleteOff
        case settingsVoiceSearchOn
        case settingsVoiceSearchOff
        case settingsPrivateSearchVoiceSearchOn
        case settingsPrivateSearchVoiceSearchOff
        case settingsWebTrackingProtectionOpen
        case settingsGpcOn
        case settingsGpcOff
        case settingsEmailProtectionOpen
        case settingsEmailProtectionLearnMore
        case settingsGeneralOpen
        case settingsAutocompleteOn
        case settingsAutocompleteOff
        case settingsGeneralAutocompleteOn
        case settingsGeneralAutocompleteOff
        case settingsGeneralVoiceSearchOn
        case settingsGeneralVoiceSearchOff
        case settingsSyncOpen
        case settingsAppearanceOpen
        case settingsAddressBarSelectorPressed
        case settingsAddressBarTopSelected
        case settingsAddressBarBottomSelected
        case settingsIconSelectorPressed
        case settingsThemeSelectorPressed
        case settingsAccessibilityOpen
        case settingsAccessiblityTextSize
        case settingsAccessibilityVoiceSearchOn
        case settingsAccessibilityVoiceSearchOff
        case settingsDataClearingOpen
        case settingsFireButtonSelectorPressed
        case settingsDataClearingClearDataOpen
        case settingsAutomaticallyClearDataOpen
        case settingsAutomaticallyClearDataOn
        case settingsAutomaticallyClearDataOff
        case settingsNextStepsAddAppToDock
        case settingsNextStepsAddWidget
        case settingsShowFullSiteAddressEnabled
        case settingsShowFullSiteAddressDisabled

        // Web pixels
        case privacyProOfferMonthlyPriceClick
        case privacyProOfferYearlyPriceClick
        case privacyProAddEmailSuccess
        case privacyProWelcomeFAQClick
    }
    
}

extension Pixel.Event: Equatable {}

extension Pixel.Event {
    
    public var name: String {
        switch self {
        case .appLaunch: return "ml"
        case .refreshPressed: return "m_r"
        case .pullToRefresh: return "m_pull-to-reload"

        case .deviceOrientationLandscape: return "m_device_orientation_landscape"

        case .keyboardGoWhileOnNTP: return "m_keyboard_go_click_ntp"
        case .keyboardGoWhileOnWebsite: return "m_keyboard_go_click_website"
        case .keyboardGoWhileOnSERP: return "m_keyboard_go_click_serp"

        case .forgetAllPressedBrowsing: return "mf_bp"
        case .forgetAllPressedTabSwitching: return "mf_tp"
        case .forgetAllExecuted: return "mf"
        case .forgetAllDataCleared: return "mf_dc"
            
        case .privacyDashboardOpened: return "mp"
            
        case .dashboardProtectionAllowlistAdd: return "mp_wla"
        case .dashboardProtectionAllowlistRemove: return "mp_wlr"
            
        case .privacyDashboardReportBrokenSite: return "mp_rb"
            
        case .tabSwitcherNewLayoutSeen: return "m_ts_n"
        case .tabSwitcherListEnabled: return "m_ts_l"
        case .tabSwitcherGridEnabled: return "m_ts_g"
        case .tabSwitcherNewTab: return "m_tab_manager_new_tab_click"
        case .tabSwitcherSwitchTabs: return "m_tab_manager_switch_tabs"
        case .tabSwitcherClickCloseTab: return "m_tab_manager_close_tab_click"
        case .tabSwitcherSwipeCloseTab: return "m_tab_manager_close_tab_swipe"
        case .tabSwitchLongPressNewTab: return "m_tab_manager_long_press_new_tab"

        case .settingsDoNotSellShown: return "ms_dns"
        case .settingsDoNotSellOn: return "ms_dns_on"
        case .settingsDoNotSellOff: return "ms_dns_off"
            
        case .settingsAutoconsentShown: return "m_settings_autoconsent_shown"
        case .settingsAutoconsentOn: return "m_settings_autoconsent_on"
        case .settingsAutoconsentOff: return "m_settings_autoconsent_off"
            
        case .browsingMenuOpened: return "mb"
        case .browsingMenuNewTab: return "mb_tb"
        case .browsingMenuAddToBookmarks: return "mb_abk"
        case .browsingMenuEditBookmark: return "mb_ebk"
        case .browsingMenuAddToFavorites: return "mb_af"
        case .browsingMenuRemoveFromFavorites: return "mb_df"
        case .browsingMenuAddToFavoritesAddFavoriteFlow: return "mb_aff"
        case .browsingMenuToggleBrowsingMode: return "mb_dm"
        case .browsingMenuCopy: return "mb_cp"
        case .browsingMenuPrint: return "mb_pr"
        case .browsingMenuFindInPage: return "mb_fp"
        case .browsingMenuDisableProtection: return "mb_wla"
        case .browsingMenuEnableProtection: return "mb_wlr"
        case .browsingMenuReportBrokenSite: return "mb_rb"
        case .browsingMenuFireproof: return "mb_f"
        case .browsingMenuAutofill: return "m_nav_autofill_menu_item_pressed"
            
        case .browsingMenuShare: return "m_browsingmenu_share"

        case .addressBarShare: return "m_addressbar_share"
        case .addressBarSettings: return "m_addressbar_settings"
        case .addressBarCancelPressedOnNTP: return "m_addressbar_cancel_ntp"
        case .addressBarCancelPressedOnWebsite: return "m_addressbar_cancel_website"
        case .addressBarCancelPressedOnSERP: return "m_addressbar_cancel_serp"
        case .addressBarClickOnNTP: return "m_addressbar_click_ntp"
        case .addressBarClickOnWebsite: return "m_addressbar_click_website"
        case .addressBarClickOnSERP: return "m_addressbar_click_serp"
        case .addressBarClearPressedOnNTP: return "m_addressbar_focus_clear_entry_ntp"
        case .addressBarClearPressedOnWebsite: return "m_addressbar_focus_clear_entry_website"
        case .addressBarClearPressedOnSERP: return "m_addressbar_focus_clear_entry_serp"
        case .addressBarGestureDismiss: return "m_addressbar_focus_dismiss_gesture"

        case .shareSheetResultSuccess: return "m_sharesheet_result_success"
        case .shareSheetResultFail: return "m_sharesheet_result_fail"
        case .shareSheetActivityCopy: return "m_sharesheet_activity_copy"
        case .shareSheetActivityAddBookmark: return "m_sharesheet_activity_addbookmark"
        case .shareSheetActivityAddFavorite: return "m_sharesheet_activity_addfavorite"
        case .shareSheetActivityFindInPage: return "m_sharesheet_activity_findinpage"
        case .shareSheetActivityPrint: return "m_sharesheet_activity_print"
        case .shareSheetActivityAddToReadingList: return "m_sharesheet_activity_addtoreadinglist"
        case .shareSheetActivityOther: return "m_sharesheet_activity_other"
            
        case .tabBarBackPressed: return "mt_bk"
        case .tabBarForwardPressed: return "mt_fw"
        case .bookmarksButtonPressed: return "mt_bm"
        case .tabBarBookmarksLongPressed: return "mt_bl"
        case .tabBarTabSwitcherPressed: return "mt_tb"

        case .bookmarkLaunchList: return "m_bookmark_launch_list"
        case .bookmarkLaunchScored: return "m_bookmark_launch_scored"
        case .bookmarkAddFavoriteFromBookmark: return "m_add_favorite_from_bookmark"
        case .bookmarkRemoveFavoriteFromBookmark: return "m_remove_favorite_from_bookmark"
        case .bookmarkAddFavoriteBySwipe: return "m_add_favorite_by_swipe"
        case .bookmarkDeletedFromBookmark: return "m_bookmark_deleted_from_bookmark"

        case .homeScreenShown: return "mh"
        case .homeScreenEditFavorite: return "mh_ef"
        case .homeScreenDeleteFavorite: return "mh_df"

        case .favoriteLaunchedNTP: return "m_favorite_launched_ntp"
        case .favoriteLaunchedWebsite: return "m_favorite_launched_website"
        case .favoriteLaunchedWidget: return "m_favorite_launched_widget"

        case .autocompleteClickPhrase: return "m_autocomplete_click_phrase"
        case .autocompleteClickWebsite: return "m_autocomplete_click_website"
        case .autocompleteClickBookmark: return "m_autocomplete_click_bookmark"
        case .autocompleteClickFavorite: return "m_autocomplete_click_favorite"
        case .autocompleteClickHistory: return "m_autocomplete_click_history"

        case .feedbackPositive: return "mfbs_positive_submit"
        case .feedbackNegativePrefix(category: let category): return "mfbs_negative_\(category)"
            
        case .brokenSiteReport: return "epbf"
            
        case .daxDialogsSerp: return "m_dx_s"
        case .daxDialogsWithoutTrackers: return "m_dx_wo"
        case .daxDialogsWithoutTrackersFollowUp: return "m_dx_wof"
        case .daxDialogsWithTrackers: return "m_dx_wt"
        case .daxDialogsSiteIsMajor: return "m_dx_sm"
        case .daxDialogsSiteOwnedByMajor: return "m_dx_so"
        case .daxDialogsHidden: return "m_dx_h"
        case .daxDialogsFireEducationShown: return "m_dx_fe_s"
        case .daxDialogsFireEducationConfirmed: return "m_dx_fe_co"
        case .daxDialogsFireEducationCancelled: return "m_dx_fe_ca"
            
        case .widgetsOnboardingCTAPressed: return "m_o_w_a"
        case .widgetsOnboardingDeclineOptionPressed: return "m_o_w_d"
        case .widgetsOnboardingMovedToBackground: return "m_o_w_b"
            
        case .emailEnabled: return "email_enabled"
        case .emailDisabled: return "email_disabled"
        case .emailUserPressedUseAddress: return "email_filled_main"
        case .emailUserPressedUseAlias: return "email_filled_random"
        case .emailUserCreatedAlias: return "email_generated_button"
        case .emailTooltipDismissed: return "email_tooltip_dismissed"
            
        case .voiceSearchDone: return "m_voice_search_done"
        case .openVoiceSearch: return "m_open_voice_search"
        case .voiceSearchCancelled: return "m_voice_search_cancelled"
            
        case .bookmarkImportSuccess: return "m_bi_s"
        case .bookmarkImportFailure: return "m_bi_e"
        case .bookmarkImportFailureParsingDL: return "m_bi_e_parsing_dl"
        case .bookmarkImportFailureParsingBody: return "m_bi_e_parsing_body"
        case .bookmarkImportFailureTransformingSafari: return "m_bi_e_transforming_safari"
        case .bookmarkImportFailureSaving: return "m_bi_e_saving"
        case .bookmarkImportFailureUnknown: return "m_bi_e_unknown"
        case .bookmarkExportSuccess: return "m_be_a"
        case .bookmarkExportFailure: return "m_be_e"

        case .textSizeSettingsChanged: return "m_text_size_settings_changed"
            
        case .downloadStarted: return "m_download_started"
        case .downloadStartedDueToUnhandledMIMEType: return "m_download_started_due_to_unhandled_mime_type"
        case .downloadTriedToPresentPreviewWithoutTab: return "m_download_tried_to_present_preview_without_tab"
        case .downloadsListOpened: return "m_downloads_list_opened"
            
        case .downloadsListOngoingDownloadCancelled: return "m_downloads_list_ongoing_download_cancelled"
        case .downloadsListCompleteDownloadDeleted: return "m_downloads_list_complete_download_deleted"
        case .downloadsListAllCompleteDownloadsDeleted: return "m_downloads_list_all_complete_downloads_deleted"
        case .downloadsListDeleteUndo: return "m_downloads_list_delete_undo"
        case .downloadsListSharePressed: return "m_downloads_list_share_pressed"
            
        case .downloadsSharingPredownloadedLocalFile: return "m_downloads_sharing_predownloaded_local_file"
            
        case .downloadAttemptToOpenBLOBviaJS: return "m_download_attempt_to_open_blob_js"
            
        case .jsAlertShown: return "m_js_alert_shown"
            
        case .featureFlaggingInternalUserAuthenticated: return "m_internal-user_authenticated"
            
        case .autofillLoginsSaveLoginModalDisplayed: return "m_autofill_logins_save_login_inline_displayed"
        case .autofillLoginsSaveLoginModalConfirmed: return "m_autofill_logins_save_login_inline_confirmed"
        case .autofillLoginsSaveLoginModalDismissed: return "m_autofill_logins_save_login_inline_dismissed"
        case .autofillLoginsSaveLoginModalExcludeSiteConfirmed: return "m_autofill_logins_save_login_exclude_site_confirmed"
            
        case .autofillLoginsSavePasswordModalDisplayed: return "m_autofill_logins_save_password_inline_displayed"
        case .autofillLoginsSavePasswordModalConfirmed: return "m_autofill_logins_save_password_inline_confirmed"
        case .autofillLoginsSavePasswordModalDismissed: return "m_autofill_logins_save_password_inline_dismissed"
            
        case .autofillLoginsUpdatePasswordModalDisplayed: return "m_autofill_logins_update_password_inline_displayed"
        case .autofillLoginsUpdatePasswordModalConfirmed: return "m_autofill_logins_update_password_inline_confirmed"
        case .autofillLoginsUpdatePasswordModalDismissed: return "m_autofill_logins_update_password_inline_dismissed"
            
        case .autofillLoginsUpdateUsernameModalDisplayed: return "m_autofill_logins_update_username_inline_displayed"
        case .autofillLoginsUpdateUsernameModalConfirmed: return "m_autofill_logins_update_username_inline_confirmed"
        case .autofillLoginsUpdateUsernameModalDismissed: return "m_autofill_logins_update_username_inline_dismissed"
            
        case .autofillLoginsFillLoginInlineManualDisplayed: return "m_autofill_logins_fill_login_inline_manual_displayed"
        case .autofillLoginsFillLoginInlineManualConfirmed: return "m_autofill_logins_fill_login_inline_manual_confirmed"
        case .autofillLoginsFillLoginInlineManualDismissed: return "m_autofill_logins_fill_login_inline_manual_dismissed"
            
        case .autofillLoginsFillLoginInlineAutopromptDisplayed: return "m_autofill_logins_fill_login_inline_autoprompt_displayed"
        case .autofillLoginsFillLoginInlineAutopromptConfirmed: return "m_autofill_logins_fill_login_inline_autoprompt_confirmed"
            
        case .autofillLoginsFillLoginInlineAuthenticationDeviceDisplayed:
            return "m_autofill_logins_fill_login_inline_authentication_device-displayed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_authenticated"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_failed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_unavailable"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthCancelled:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_cancelled"
        case .autofillLoginsAutopromptDismissed:
            return "m_autofill_logins_autoprompt_dismissed"
            
        case .autofillLoginsFillLoginInlineDisablePromptShown: return "m_autofill_logins_save_disable-prompt_shown"
        case .autofillLoginsFillLoginInlineDisablePromptAutofillKept: return "m_autofill_logins_save_disable-prompt_autofill-kept"
        case .autofillLoginsFillLoginInlineDisablePromptAutofillDisabled: return "m_autofill_logins_save_disable-prompt_autofill-disabled"
            
        case .autofillSettingsOpened: return "m_autofill_settings_opened"
        case .autofillLoginsSettingsEnabled: return "m_autofill_logins_settings_enabled"
        case .autofillLoginsSettingsDisabled: return "m_autofill_logins_settings_disabled"
        case .autofillLoginsSettingsResetExcludedDisplayed: return "m_autofill_settings_reset_excluded_displayed"
        case .autofillLoginsSettingsResetExcludedConfirmed: return "m_autofill_settings_reset_excluded_confirmed"
        case .autofillLoginsSettingsResetExcludedDismissed: return "m_autofill_settings_reset_excluded_dismissed"
            
        case .autofillLoginsPasswordGenerationPromptDisplayed: return "m_autofill_logins_password_generation_prompt_displayed"
        case .autofillLoginsPasswordGenerationPromptConfirmed: return "m_autofill_logins_password_generation_prompt_confirmed"
        case .autofillLoginsPasswordGenerationPromptDismissed: return "m_autofill_logins_password_generation_prompt_dismissed"

        case .autofillLoginsLaunchWidgetHome: return "m_autofill_logins_launch_widget_home"
        case .autofillLoginsLaunchWidgetLock: return "m_autofill_logins_launch_widget_lock"
        case .autofillLoginsLaunchAppShortcut: return "m_autofill_logins_launch_app_shortcut"

        case .autofillJSPixelFired(let pixel):
            return "m_ios_\(pixel.pixelName)"
            
        case .secureVaultError: return "m_secure_vault_error"
            
        case .secureVaultInitFailedError: return "m_secure-vault_error_init-failed"
        case .secureVaultFailedToOpenDatabaseError: return "m_secure-vault_error_failed-to-open-database"
            
        case .secureVaultIsEnabledCheckedWhenEnabledAndDataProtected: return "m_secure-vault_is-enabled-checked_when-enabled-and-data-protected"
            
            // MARK: Ad Click Attribution pixels
            
        case .adClickAttributionDetected: return "m_ad_click_detected"
        case .adClickAttributionActive: return "m_ad_click_active"
        case .adClickAttributionPageLoads: return "m_pageloads_with_ad_attribution"
            
            // MARK: SERP pixels
            
        case .serpRequerySame: return "rq_0"
        case .serpRequeryNew: return "rq_1"
            
            // MARK: AppTP pixels
            
        case .appTPBreakageReport: return "m_apptp_breakage_report"
        case .appTPFailedToCreateProxyServer: return "m_apptp_failed_to_create_proxy_server"
        case .appTPFailedToSetTunnelNetworkSettings: return "m_apptp_failed_to_set_tunnel_network_settings"
        case .appTPFailedToAccessPreferences: return "m_apptp_failed_to_access_preferences"
        case .appTPFailedToAccessPreferencesDuringSetup: return "m_apptp_failed_to_access_preferences_during_setup"
        case .appTPFailedToStartTunnel: return "m_apptp_failed_to_start_tunnel"
        case .appTPVPNDisconnect: return "m_apptp_vpn_disconnect"
        case .appTPVPNMemoryWarning: return "m_apptp_vpn_memory_warning"
        case .appTPVPNMemoryCritical: return "m_apptp_vpn_memory_critical"
            
        case .appTPBlocklistParseFailed: return "m_apptp_blocklist_parse_failed"
        case .appTPActiveUser: return "m_apptp_active_user"
        case .appTPDBLocationFailed: return "m_apptp_db_location_not_found"
        case .appTPDBStoreLoadFailure: return "m_apptp_db_store_load_failure"
        case .appTPDBPersistentStoreLoadFailure: return "m_apptp_db_persistent_store_load_failure"
        case .appTPDBHistoryFailure: return "m_apptp_db_history_failure"
        case .appTPDBHistoryFetchFailure: return "m_apptp_db_history_fetch_failure"
        case .appTPDBFeedbackTrackerFetchFailed: return "m_apptp_db_feedback_tracker_fetch_failed"
        case .appTPDBTrackerStoreFailure: return "m_apptp_db_tracker_store_failure"
        case .appTPCouldNotLoadDatabase: return "m_apptp_could_not_load_database"
            
            // MARK: Network Protection pixels
            
        case .networkProtectionActiveUser: return "m_netp_daily_active_d"
        case .networkProtectionNewUser: return "m_netp_daily_active_u"
        case .networkProtectionControllerStartAttempt: return "m_netp_controller_start_attempt"
        case .networkProtectionControllerStartSuccess: return "m_netp_controller_start_success"
        case .networkProtectionControllerStartFailure: return "m_netp_controller_start_failure"
        case .networkProtectionTunnelStartAttempt: return "m_netp_tunnel_start_attempt"
        case .networkProtectionTunnelStartSuccess: return "m_netp_tunnel_start_success"
        case .networkProtectionTunnelStartFailure: return "m_netp_tunnel_start_failure"
        case .networkProtectionTunnelUpdateAttempt: return "m_netp_tunnel_update_attempt"
        case .networkProtectionTunnelUpdateSuccess: return "m_netp_tunnel_update_success"
        case .networkProtectionTunnelUpdateFailure: return "m_netp_tunnel_update_failure"
        case .networkProtectionEnableAttemptConnecting: return "m_netp_ev_enable_attempt"
        case .networkProtectionEnableAttemptSuccess: return "m_netp_ev_enable_attempt_success"
        case .networkProtectionEnableAttemptFailure: return "m_netp_ev_enable_attempt_failure"
        case .networkProtectionTunnelFailureDetected: return "m_netp_ev_tunnel_failure"
        case .networkProtectionTunnelFailureRecovered: return "m_netp_ev_tunnel_failure_recovered"
        case .networkProtectionLatency(let quality): return "m_netp_ev_\(quality.rawValue)_latency"
        case .networkProtectionLatencyError: return "m_netp_ev_latency_error_d"
        case .networkProtectionRekeyAttempt: return "m_netp_rekey_attempt"
        case .networkProtectionRekeyCompleted: return "m_netp_rekey_completed"
        case .networkProtectionRekeyFailure: return "m_netp_rekey_failure"
        case .networkProtectionEnabledOnSearch: return "m_netp_ev_enabled_on_search"
        case .networkProtectionBreakageReport: return "m_vpn_breakage_report"
        case .networkProtectionTunnelConfigurationNoServerRegistrationInfo: return "m_netp_tunnel_config_error_no_server_registration_info"
        case .networkProtectionTunnelConfigurationCouldNotSelectClosestServer: return "m_netp_tunnel_config_error_could_not_select_closest_server"
        case .networkProtectionTunnelConfigurationCouldNotGetPeerPublicKey: return "m_netp_tunnel_config_error_could_not_get_peer_public_key"
        case .networkProtectionTunnelConfigurationCouldNotGetPeerHostName: return "m_netp_tunnel_config_error_could_not_get_peer_host_name"
        case .networkProtectionTunnelConfigurationCouldNotGetInterfaceAddressRange:
            return "m_netp_tunnel_config_error_could_not_get_interface_address_range"
        case .networkProtectionClientFailedToFetchServerList: return "m_netp_backend_api_error_failed_to_fetch_server_list"
        case .networkProtectionClientFailedToParseServerListResponse: return "m_netp_backend_api_error_parsing_server_list_response_failed"
        case .networkProtectionClientFailedToEncodeRegisterKeyRequest: return "m_netp_backend_api_error_encoding_register_request_body_failed"
        case .networkProtectionClientFailedToFetchRegisteredServers: return "m_netp_backend_api_error_failed_to_fetch_registered_servers"
        case .networkProtectionClientFailedToParseRegisteredServersResponse:
            return "m_netp_backend_api_error_parsing_device_registration_response_failed"
        case .networkProtectionClientFailedToFetchLocations: return "m_netp_backend_api_error_failed_to_fetch_locations"
        case .networkProtectionClientFailedToParseLocationsResponse:
            return "m_netp_backend_api_error_parsing_locations_response_failed"
        case .networkProtectionClientFailedToEncodeRedeemRequest: return "m_netp_backend_api_error_encoding_redeem_request_body_failed"
        case .networkProtectionClientInvalidInviteCode: return "m_netp_backend_api_error_invalid_invite_code"
        case .networkProtectionClientFailedToRedeemInviteCode: return "m_netp_backend_api_error_failed_to_redeem_invite_code"
        case .networkProtectionClientFailedToParseRedeemResponse: return "m_netp_backend_api_error_parsing_redeem_response_failed"
        case .networkProtectionClientInvalidAuthToken: return "m_netp_backend_api_error_invalid_auth_token"
        case .networkProtectionKeychainErrorFailedToCastKeychainValueToData: return "m_netp_keychain_error_failed_to_cast_keychain_value_to_data"
        case .networkProtectionKeychainReadError: return "m_netp_keychain_error_read_failed"
        case .networkProtectionKeychainWriteError: return "m_netp_keychain_error_write_failed"
        case .networkProtectionKeychainUpdateError: return "m_netp_keychain_error_update_failed"
        case .networkProtectionKeychainDeleteError: return "m_netp_keychain_error_delete_failed"
        case .networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor: return "m_netp_wireguard_error_cannot_locate_tunnel_file_descriptor"
        case .networkProtectionWireguardErrorInvalidState: return "m_netp_wireguard_error_invalid_state"
        case .networkProtectionWireguardErrorFailedDNSResolution: return "m_netp_wireguard_error_failed_dns_resolution"
        case .networkProtectionWireguardErrorCannotSetNetworkSettings: return "m_netp_wireguard_error_cannot_set_network_settings"
        case .networkProtectionWireguardErrorCannotStartWireguardBackend: return "m_netp_wireguard_error_cannot_start_wireguard_backend"
        case .networkProtectionFailedToLoadFromPreferences: return "m_netp_network_extension_error_failed_to_load_from_preferences"
        case .networkProtectionFailedToSaveToPreferences: return "m_netp_network_extension_error_failed_to_save_to_preferences"
        case .networkProtectionActivationRequestFailed: return "m_netp_network_extension_error_activation_request_failed"
        case .networkProtectionFailedToStartTunnel: return "m_netp_failed_to_start_tunnel"
        case .networkProtectionDisconnected: return "m_netp_vpn_disconnect"
        case .networkProtectionNoAuthTokenFoundError: return "m_netp_no_auth_token_found_error"
        case .networkProtectionMemoryWarning: return "m_netp_vpn_memory_warning"
        case .networkProtectionMemoryCritical: return "m_netp_vpn_memory_critical"
        case .networkProtectionUnhandledError: return "m_netp_unhandled_error"
            
        case .networkProtectionGeoswitchingOpened: return "m_netp_imp_geoswitching"
        case .networkProtectionGeoswitchingSetNearest: return "m_netp_ev_geoswitching_set_nearest"
        case .networkProtectionGeoswitchingSetCustom: return "m_netp_ev_geoswitching_set_custom"
        case .networkProtectionGeoswitchingNoLocations: return "m_netp_ev_geoswitching_no_locations"
            
            // MARK: remote messaging pixels
            
        case .remoteMessageShown: return "m_remote_message_shown"
        case .remoteMessageShownUnique: return "m_remote_message_shown_unique"
        case .remoteMessageDismissed: return "m_remote_message_dismissed"
        case .remoteMessageActionClicked: return "m_remote_message_action_clicked"
        case .remoteMessagePrimaryActionClicked: return "m_remote_message_primary_action_clicked"
        case .remoteMessageSecondaryActionClicked: return "m_remote_message_secondary_action_clicked"
        case .remoteMessageSheet: return "m_remote_message_sheet"
            
            // MARK: debug pixels
            
        case .dbCrashDetected: return "m_d_crash"
        case .dbMigrationError: return "m_d_dbme"
        case .dbRemovalError: return "m_d_dbre"
        case .dbDestroyError: return "m_d_dbde"
        case .dbDestroyFileError: return "m_d_dbdf"
        case .dbContainerInitializationError: return "m_d_database_container_error"
        case .dbInitializationError: return "m_d_dbie"
        case .dbSaveExcludedHTTPSDomainsError: return "m_d_dbsw"
        case .dbSaveBloomFilterError: return "m_d_dbsb"
        case .dbRemoteMessagingSaveConfigError: return "m_d_db_rm_save_config"
        case .dbRemoteMessagingInvalidateConfigError: return "m_d_db_rm_invalidate_config"
        case .dbRemoteMessagingSaveMessageError: return "m_d_db_rm_save_message"
        case .dbRemoteMessagingUpdateMessageShownError: return "m_d_db_rm_update_message_shown"
        case .dbRemoteMessagingUpdateMessageStatusError: return "m_d_db_rm_update_message_status"
        case .dbRemoteMessagingDeleteScheduledMessageError: return "m_d_db_rm_delete_scheduled_message"
        case .dbLocalAuthenticationError: return "m_d_local_auth_error"
            
        case .debugBookmarksMigratedMoreThanOnce: return "m_debug_bookmarks_migrated-more-than-once"
            
        case .configurationFetchInfo: return "m_d_cfgfetch"
            
        case .trackerDataParseFailed: return "m_d_tds_p"
        case .trackerDataReloadFailed: return "m_d_tds_r"
        case .trackerDataCouldNotBeLoaded: return "m_d_tds_l"
        case .fileStoreWriteFailed: return "m_d_fswf"
        case .privacyConfigurationReloadFailed: return "m_d_pc_r"
        case .privacyConfigurationParseFailed: return "m_d_pc_p"
        case .privacyConfigurationCouldNotBeLoaded: return "m_d_pc_l"
            
        case .contentBlockingCompilationFailed(let listType, let component):
            return "m_d_content_blocking_\(listType)_\(component)_compilation_failed"
            
        case .contentBlockingCompilationTime: return "m_content_blocking_compilation_time"
            
        case .ampBlockingRulesCompilationFailed: return "m_debug_amp_rules_compilation_failed"
            
        case .webKitDidTerminate: return "m_d_wkt"
        case .webKitDidTerminateDuringWarmup: return "m_d_webkit-terminated-during-warmup"
        case .webKitTerminationDidReloadCurrentTab: return "m_d_wktct"

        case .webKitWarmupUnexpectedDidFinish: return "m_d_webkit-warmup-unexpected-did-finish"
        case .webKitWarmupUnexpectedDidTerminate: return "m_d_webkit-warmup-unexpected-did-terminate"

        case .backgroundTaskSubmissionFailed: return "m_bt_rf"
            
        case .blankOverlayNotDismissed: return "m_d_ovs"
            
        case .cookieDeletionTimedOut: return "m_debug_cookie-clearing-timeout"
        case .cookieDeletionLeftovers: return "m_cookie_deletion_leftovers"
            
        case .cachedTabPreviewsExceedsTabCount: return "m_d_tpetc"
        case .cachedTabPreviewRemovalError: return "m_d_tpre"
            
        case .missingDownloadedFile: return "m_d_missing_downloaded_file"
        case .unhandledDownload: return "m_d_unhandled_download"
            
        case .compilationResult(result: let result, waitTime: let waitTime, appState: let appState):
            return "m_compilation_result_\(result)_time_\(waitTime)_state_\(appState)"
            
        case .emailAutofillKeychainError: return "m_email_autofill_keychain_error"
            
        case .debugBookmarkOrphanFolderNew: return "m_d_bookmark_orphan_folder_new"
        case .debugBookmarkTopLevelMissingNew: return "m_d_bookmark_top_level_missing_new"
        case .debugCouldNotFixBookmarkFolder: return "m_d_cannot_fix_bookmark_folder"
        case .debugMissingTopFolderFixHasBookmarks: return "m_d_missing_top_folder_has_bookmarks"
            
        case .debugFavoriteOrphanFolderNew: return "m_d_favorite_orphan_folder_new"
        case .debugFavoriteTopLevelMissingNew: return "m_d_favorite_top_level_missing_new"
        case .debugCouldNotFixFavoriteFolder: return "m_d_cannot_fix_favorite_folder"
        case .debugMissingTopFolderFixHasFavorites: return "m_d_missing_top_folder_has_favorites"
            
        case .debugCantSaveBookmarkFix: return "m_d_cant_save_bookmark_fix"
            
        case .debugCannotClearObservationsDatabase: return "m_d_cannot_clear_observations_database"
        case .debugWebsiteDataStoresNotClearedMultiple: return "m_d_wkwebsitedatastoresnotcleared_multiple"
        case .debugWebsiteDataStoresNotClearedOne: return "m_d_wkwebsitedatastoresnotcleared_one"
        case .debugCookieCleanupError: return "m_d_cookie-cleanup-error"
            
            // MARK: Ad Attribution
            
        case .adAttributionGlobalAttributedRulesDoNotExist: return "m_attribution_global_attributed_rules_do_not_exist"
        case .adAttributionCompilationFailedForAttributedRulesList: return "m_attribution_compilation_failed_for_attributed_rules_list"
            
        case .adAttributionLogicUnexpectedStateOnInheritedAttribution: return "m_attribution_unexpected_state_on_inherited_attribution_2"
        case .adAttributionLogicUnexpectedStateOnRulesCompiled: return "m_attribution_unexpected_state_on_rules_compiled"
        case .adAttributionLogicUnexpectedStateOnRulesCompilationFailed: return "m_attribution_unexpected_state_on_rules_compilation_failed"
        case .adAttributionDetectionInvalidDomainInParameter: return "m_attribution_invalid_domain_in_parameter"
        case .adAttributionDetectionHeuristicsDidNotMatchDomain: return "m_attribution_heuristics_did_not_match_domain"
        case .adAttributionLogicRequestingAttributionTimedOut: return "m_attribution_logic_requesting_attribution_timed_out"
        case .adAttributionLogicWrongVendorOnSuccessfulCompilation: return "m_attribution_logic_wrong_vendor_on_successful_compilation"
        case .adAttributionLogicWrongVendorOnFailedCompilation: return "m_attribution_logic_wrong_vendor_on_failed_compilation"
            
        case .bookmarkFolderExpected: return "m_d_bookmark_folder_expected"
        case .bookmarksListIndexNotMatchingBookmark: return "m_d_bookmarks_list_index_not_matching_bookmark"
        case .bookmarksListMissingFolder: return "m_d_bookmarks_list_missing_folder"
        case .editorNewParentMissing: return "m_d_bookmarks_editor_new_parent_missing"
        case .favoritesListIndexNotMatchingBookmark: return "m_d_favorites_list_index_not_matching_bookmark"
        case .fetchingRootItemFailed(let modelType): return "m_d_bookmarks_fetching_root_item_failed_\(modelType.rawValue)"
        case .indexOutOfRange(let modelType): return "m_d_bookmarks_index_out_of_range_\(modelType.rawValue)"
        case .saveFailed(let modelType): return "m_d_bookmarks_view_model_save_failed_\(modelType.rawValue)"
        case .missingParent(let objectType): return "m_d_bookmark_model_missing_parent_\(objectType.rawValue)"
            
        case .bookmarksCouldNotLoadDatabase: return "m_d_bookmarks_could_not_load_database"
        case .bookmarksCouldNotPrepareDatabase: return "m_d_bookmarks_could_not_prepare_database"
        case .bookmarksMigrationAlreadyPerformed: return "m_d_bookmarks_migration_already_performed"
        case .bookmarksMigrationFailed: return "m_d_bookmarks_migration_failed"
        case .bookmarksMigrationCouldNotPrepareDatabase: return "m_d_bookmarks_migration_could_not_prepare_database"
        case .bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration:
            return "m_d_bookmarks_migration_could_not_prepare_database_on_failed_migration"
        case .bookmarksMigrationCouldNotRemoveOldStore: return "m_d_bookmarks_migration_could_not_remove_old_store"
        case .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders: return "m_d_bookmarks_migration_could_not_prepare_multiple_favorite_folders"
            
        case .syncSignupDirect: return "m_sync_signup_direct"
        case .syncSignupConnect: return "m_sync_signup_connect"
        case .syncLogin: return "m_sync_login"
        case .syncDaily: return "m_sync_daily"
        case .syncDuckAddressOverride: return "m_sync_duck_address_override"
        case .syncSuccessRateDaily: return "m_sync_success_rate_daily"
        case .syncLocalTimestampResolutionTriggered(let feature): return "m_sync_\(feature.name)_local_timestamp_resolution_triggered"
        case .syncFailedToMigrate: return "m_d_sync_failed_to_migrate"
        case .syncFailedToLoadAccount: return "m_d_sync_failed_to_load_account"
        case .syncFailedToSetupEngine: return "m_d_sync_failed_to_setup_engine"
        case .syncBookmarksCountLimitExceededDaily: return "m_d_sync_bookmarks_count_limit_exceeded_daily"
        case .syncCredentialsCountLimitExceededDaily: return "m_d_sync_credentials_count_limit_exceeded_daily"
        case .syncBookmarksRequestSizeLimitExceededDaily: return "m_d_sync_bookmarks_request_size_limit_exceeded_daily"
        case .syncCredentialsRequestSizeLimitExceededDaily: return "m_d_sync_credentials_request_size_limit_exceeded_daily"
            
        case .syncSentUnauthenticatedRequest: return "m_d_sync_sent_unauthenticated_request"
        case .syncMetadataCouldNotLoadDatabase: return "m_d_sync_metadata_could_not_load_database"
        case .syncBookmarksFailed: return "m_d_sync_bookmarks_failed"
        case .syncCredentialsProviderInitializationFailed: return "m_d_sync_credentials_provider_initialization_failed"
        case .syncCredentialsFailed: return "m_d_sync_credentials_failed"
        case .syncSettingsFailed: return "m_d_sync_settings_failed"
        case .syncSettingsMetadataUpdateFailed: return "m_d_sync_settings_metadata_update_failed"
        case .syncSignupError: return "m_d_sync_signup_error"
        case .syncLoginError: return "m_d_sync_login_error"
        case .syncLogoutError: return "m_d_sync_logout_error"
        case .syncUpdateDeviceError: return "m_d_sync_update_device_error"
        case .syncRemoveDeviceError: return "m_d_sync_remove_device_error"
        case .syncDeleteAccountError: return "m_d_sync_delete_account_error"
        case .syncLoginExistingAccountError: return "m_d_sync_login_existing_account_error"

        case .syncWrongEnvironment: return "m_d_sync_wrong_environment_u"

        case .swipeTabsUsed: return "m_swipe-tabs-used"
        case .swipeTabsUsedDaily: return "m_swipe-tabs-used-daily"
        case .swipeToOpenNewTab: return "m_addressbar_swipe_new_tab"

        case .bookmarksCleanupFailed: return "m_d_bookmarks_cleanup_failed"
        case .bookmarksCleanupAttemptedWhileSyncWasEnabled: return "m_d_bookmarks_cleanup_attempted_while_sync_was_enabled"
        case .favoritesCleanupFailed: return "m_d_favorites_cleanup_failed"
        case .bookmarksFaviconsFetcherStateStoreInitializationFailed: return "m_d_bookmarks_favicons_fetcher_state_store_initialization_failed"
        case .bookmarksFaviconsFetcherFailed: return "m_d_bookmarks_favicons_fetcher_failed"
            
        case .credentialsDatabaseCleanupFailed: return "m_d_credentials_database_cleanup_failed_2"
        case .credentialsCleanupAttemptedWhileSyncWasEnabled: return "m_d_credentials_cleanup_attempted_while_sync_was_enabled"
            
        case .invalidPayload(let configuration): return "m_d_\(configuration.rawValue)_invalid_payload".lowercased()
            
            // MARK: - InContext Email Protection
        case .emailIncontextPromptDisplayed: return "m_email_incontext_prompt_displayed"
        case .emailIncontextPromptConfirmed: return "m_email_incontext_prompt_confirmed"
        case .emailIncontextPromptDismissed: return "m_email_incontext_prompt_dismissed"
        case .emailIncontextPromptDismissedPersistent: return "m_email_incontext_prompt_dismissed_persisted"
        case .emailIncontextModalDisplayed: return "m_email_incontext_modal_displayed"
        case .emailIncontextModalDismissed: return "m_email_incontext_modal_dismissed"
        case .emailIncontextModalExitEarly: return "m_email_incontext_modal_exit_early"
        case .emailIncontextModalExitEarlyContinue: return "m_email_incontext_modal_exit_early_continue"
            
        case .compilationFailed: return "m_d_compilation_failed"
            // MARK: - Return user measurement
        case .debugReturnUserAddATB: return "m_debug_return_user_add_atb"
        case .debugReturnUserUpdateATB: return "m_debug_return_user_update_atb"
            
        // MARK: - Toggle reports
        case .protectionToggledOffBreakageReport: return "m_protection-toggled-off-breakage-report"
        case .toggleProtectionsDailyCount: return "m_toggle-protections-daily-count"
        case .toggleReportDoNotSend: return "m_toggle-report-do-not-send"
        case .toggleReportDismiss: return "m_toggle-report-dismiss"

        case .appRatingPromptFetchError: return "m_d_app_rating_prompt_fetch_error"

            // MARK: - User behavior
        case .userBehaviorReloadTwice: return "m_reload-twice"
        case .userBehaviorReloadAndRestart: return "m_reload-and-restart"
        case .userBehaviorReloadAndFireButton: return "m_reload-and-fire-button"
        case .userBehaviorReloadAndOpenSettings: return "m_reload-and-open-settings"
        case .userBehaviorReloadAndTogglePrivacyControls: return "m_reload-and-toggle-privacy-controls"
        case .userBehaviorFireButtonAndRestart: return "m_fire-button-and-restart"
        case .userBehaviorFireButtonAndTogglePrivacyControls: return "m_fire-button-and-toggle-privacy-controls"

        // MARK: - History debug
        case .historyStoreLoadFailed: return "m_debug_history-store-load-failed"
        case .historyRemoveFailed: return "m_debug_history-remove-failed"
        case .historyReloadFailed: return "m_debug_history-reload-failed"
        case .historyCleanEntriesFailed: return "m_debug_history-clean-entries-failed"
        case .historyCleanVisitsFailed: return "m_debug_history-clean-visits-failed"
        case .historySaveFailed: return "m_debug_history-save-failed"
        case .historyInsertVisitFailed: return "m_debug_history-insert-visit-failed"
        case .historyRemoveVisitsFailed: return "m_debug_history-remove-visits-failed"

        // MARK: Privacy pro
        case .privacyProSubscriptionActive: return "m_privacy-pro_app_subscription_active"
        case .privacyProOfferScreenImpression: return "m_privacy-pro_offer_screen_impression"
        case .privacyProPurchaseAttempt: return "m_privacy-pro_terms-conditions_subscribe_click"
        case .privacyProPurchaseFailure: return "m_privacy-pro_app_subscription-purchase_failure_other"
        case .privacyProPurchaseFailureStoreError: return "m_privacy-pro_app_subscription-purchase_failure_store"
        case .privacyProPurchaseFailureAccountNotCreated: return "m_privacy-pro_app_subscription-purchase_failure_backend"
        case .privacyProPurchaseFailureBackendError: return "m_privacy-pro_app_subscription-purchase_failure_account-creation"
        case .privacyProPurchaseSuccess: return "m_privacy-pro_app_subscription-purchase_success"
        case .privacyProRestorePurchaseOfferPageEntry: return "m_privacy-pro_offer_restore-purchase_click"
        case .privacyProRestorePurchaseClick: return "m_privacy-pro_app-settings_restore-purchase_click"
        case .privacyProRestorePurchaseEmailStart: return "m_privacy-pro_activate-subscription_enter-email_click"
        case .privacyProRestorePurchaseStoreStart: return "m_privacy-pro_activate-subscription_restore-purchase_click"
        case .privacyProRestorePurchaseEmailSuccess: return "m_privacy-pro_app_subscription-restore-using-email_success"
        case .privacyProRestorePurchaseStoreSuccess: return "m_privacy-pro_app_subscription-restore-using-store_success"
        case .privacyProRestorePurchaseStoreFailureNotFound: return "m_privacy-pro_app_subscription-restore-using-store_failure_not-found"
        case .privacyProRestorePurchaseStoreFailureOther: return "m_privacy-pro_app_subscription-restore-using-store_failure_other"
        case .privacyProRestoreAfterPurchaseAttempt: return "m_privacy-pro_app_subscription-restore-after-purchase-attempt_success"
        case .privacyProSubscriptionActivated: return "m_privacy-pro_app_subscription_activated_u"
        case .privacyProWelcomeAddDevice: return "m_privacy-pro_welcome_add-device_click_u"
        case .privacyProSettingsAddDevice: return "m_privacy-pro_settings_add-device_click"
        case .privacyProAddDeviceEnterEmail: return "m_privacy-pro_add-device_enter-email_click"
        case .privacyProWelcomeVPN: return "m_privacy-pro_welcome_vpn_click_u"
        case .privacyProWelcomePersonalInformationRemoval: return "m_privacy-pro_welcome_personal-information-removal_click_u"
        case .privacyProWelcomeIdentityRestoration: return "m_privacy-pro_welcome_identity-theft-restoration_click_u"
        case .privacyProSubscriptionSettings: return "m_privacy-pro_settings_screen_impression"
        case .privacyProVPNSettings: return "m_privacy-pro_app-settings_vpn_click"
        case .privacyProPersonalInformationRemovalSettings: return "m_privacy-pro_app-settings_personal-information-removal_click"
        case .privacyProIdentityRestorationSettings: return "m_privacy-pro_app-settings_identity-theft-restoration_click"
        case .privacyProSubscriptionManagementEmail: return "m_privacy-pro_manage-email_edit_click"
        case .privacyProSubscriptionManagementPlanBilling: return "m_privacy-pro_settings_change-plan-or-billing_click"
        case .privacyProSubscriptionManagementRemoval: return "m_privacy-pro_settings_remove-from-device_click"
        case .privacyProTransactionProgressNotHiddenAfter60s: return "m_privacy-pro_progress_not_hidden_after_60s"

        // MARK: Pixel Experiment
        case .pixelExperimentEnrollment: return "pixel_experiment_enrollment"
        case .settingsPresented: return "m_settings_presented"
        case .settingsSetAsDefault: return "m_settings_set_as_default"
        case .settingsPrivateSearchOpen: return "m_settings_private_search_open"
        case .settingsPrivateSearchAutocompleteOn: return "m_settings_private_search_autocomplete_on"
        case .settingsPrivateSearchAutocompleteOff: return "m_settings_private_search_autocomplete_off"
        case .settingsVoiceSearchOn: return "m_settings_voice_search_on"
        case .settingsVoiceSearchOff: return "m_settings_voice_search_off"
        case .settingsPrivateSearchVoiceSearchOn: return "m_settings_private_search_voice_search_on"
        case .settingsPrivateSearchVoiceSearchOff: return "m_settings_private_search_voice_search_off"
        case .settingsWebTrackingProtectionOpen: return "m_settings_web_tracking_protection_open"
        case .settingsGpcOn: return "m_settings_gpc_on"
        case .settingsGpcOff: return "m_settings_gpc_off"
        case .settingsEmailProtectionOpen: return "m_settings_email_protection_open"
        case .settingsEmailProtectionLearnMore: return "m_settings_email_protection_learn_more"
        case .settingsGeneralOpen: return "m_settings_general_open"
        case .settingsAutocompleteOn: return "m_settings_autocomplete_on"
        case .settingsAutocompleteOff: return "m_settings_autocomplete_off"
        case .settingsGeneralAutocompleteOn: return "m_settings_general_autocomplete_on"
        case .settingsGeneralAutocompleteOff: return "m_settings_general_autocomplete_off"
        case .settingsGeneralVoiceSearchOn: return "m_settings_general_voice_search_on"
        case .settingsGeneralVoiceSearchOff: return "m_settings_general_voice_search_off"
        case .settingsSyncOpen: return "m_settings_sync_open"
        case .settingsAppearanceOpen: return "m_settings_appearance_open"
        case .settingsAddressBarSelectorPressed: return "m_settings_address_bar_selector_pressed"
        case .settingsAddressBarTopSelected: return "m_settings_address_bar_top_selected"
        case .settingsAddressBarBottomSelected: return "m_settings_address_bar_bottom_selected"
        case .settingsIconSelectorPressed: return "m_settings_icon_selector_pressed"
        case .settingsThemeSelectorPressed: return "m_settings_theme_selector_pressed"
        case .settingsAccessibilityOpen: return "m_settings_accessibility_open"
        case .settingsAccessiblityTextSize: return "m_settings_accessiblity_text_size"
        case .settingsAccessibilityVoiceSearchOn: return "m_settings_accessibility_voice_search_on"
        case .settingsAccessibilityVoiceSearchOff: return "m_settings_accessibility_voice_search_off"
        case .settingsDataClearingOpen: return "m_settings_data_clearing_open"
        case .settingsFireButtonSelectorPressed: return "m_settings_fire_button_selector_pressed"
        case .settingsDataClearingClearDataOpen: return "m_settings_data_clearing_clear_data_open"
        case .settingsAutomaticallyClearDataOpen: return "m_settings_data_clearing_clear_data_open"
        case .settingsAutomaticallyClearDataOn: return "m_settings_automatically_clear_data_on"
        case .settingsAutomaticallyClearDataOff: return "m_settings_automatically_clear_data_off"
        case .settingsNextStepsAddAppToDock: return "m_settings_next_steps_add_app_to_dock"
        case .settingsNextStepsAddWidget: return "m_settings_next_steps_add_widget"
        case .settingsShowFullSiteAddressEnabled: return "m_settings_show_full_url_on"
        case .settingsShowFullSiteAddressDisabled: return "m_settings_show_full_url_off"

        // Launch
        case .privacyProFeatureEnabled: return "m_privacy-pro_feature_enabled"
        case .privacyProVPNAccessRevokedDialogShown: return "m_privacy-pro_vpn-access-revoked-dialog_shown"
        case .privacyProVPNBetaStoppedWhenPrivacyProEnabled: return "m_privacy-pro_vpn-beta-stopped-when-privacy-pro-enabled"

        // Web
        case .privacyProOfferMonthlyPriceClick: return "m_privacy-pro_offer_monthly-price_click"
        case .privacyProOfferYearlyPriceClick: return "m_privacy-pro_offer_yearly-price_click"
        case .privacyProAddEmailSuccess: return "m_privacy-pro_app_add-email_success_u"
        case .privacyProWelcomeFAQClick: return "m_privacy-pro_welcome_faq_click_u"
        case .networkProtectionFailureRecoveryStarted: return "m_netp_ev_failure_recovery_started"
        case .networkProtectionFailureRecoveryFailed: return "m_netp_ev_failure_recovery_failed"
        case .networkProtectionFailureRecoveryCompletedHealthy: return "m_netp_ev_failure_recovery_completed_server_healthy"
        case .networkProtectionFailureRecoveryCompletedUnhealthy: return "m_netp_ev_failure_recovery_completed_server_unhealthy"
        }
    }
}

// swiftlint:disable file_length
extension Pixel.Event {
    
    public enum CompileRulesWaitTime: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case noWait = "0"
        case lessThan1s = "1"
        case lessThan5s = "5"
        case lessThan10s = "10"
        case lessThan20s = "20"
        case lessThan40s = "40"
        case more
        
        public init(waitTime: TimeInterval) {
            switch waitTime {
            case 0:
                self = .noWait
            case ...1:
                self = .lessThan1s
            case ...5:
                self = .lessThan5s
            case ...10:
                self = .lessThan10s
            case ...20:
                self = .lessThan20s
            case ...40:
                self = .lessThan40s
            default:
                self = .more
            }
        }
        
    }
    
    public enum CompileRulesResult: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case tabClosed = "tab_closed"
        case appQuit = "app_quit"
        case success
        
    }
    
    public enum AppState: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case onboarding
        case regular
        
    }
    
    public enum CompileRulesListType: String, CustomStringConvertible {
        
        public var description: String { rawValue }
        
        case tds
        case blockingAttribution
        case attributed
        case unknown
        
    }
}
