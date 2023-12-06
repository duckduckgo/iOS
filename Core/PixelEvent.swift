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

// swiftlint:disable file_length
extension Pixel {

    // swiftlint:disable:next type_body_length
    public enum Event {
        
        case appLaunch
        case refreshPressed
        
        case forgetAllPressedBrowsing
        case forgetAllPressedTabSwitching
        case forgetAllExecuted
        case forgetAllDataCleared
        
        case privacyDashboardOpened
        
        case dashboardProtectionAllowlistAdd
        case dashboardProtectionAllowlistRemove
        
        case privacyDashboardReportBrokenSite
        case privacyDashboardPixelFromJS(rawPixel: String)
        
        case tabSwitcherNewLayoutSeen
        case tabSwitcherListEnabled
        case tabSwitcherGridEnabled
        
        case settingsDoNotSellShown
        case settingsDoNotSellOn
        case settingsDoNotSellOff
        
        case settingsAutoconsentShown
        case settingsAutoconsentOn
        case settingsAutoconsentOff
        
        case browsingMenuOpened
        case browsingMenuRefresh
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
        case browsingMenuSettings
        case browsingMenuFindInPage
        case browsingMenuDisableProtection
        case browsingMenuEnableProtection
        case browsingMenuReportBrokenSite
        case browsingMenuFireproof
        case browsingMenuAutofill
        
        case addressBarShare
        case addressBarSettings

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
        case homeScreenSearchTapped
        case homeScreenFavouriteLaunched
        case homeScreenAddFavorite
        case homeScreenAddFavoriteOK
        case homeScreenAddFavoriteCancel
        case homeScreenEditFavorite
        case homeScreenDeleteFavorite
        
        case autocompleteSelectedLocal
        case autocompleteSelectedRemote
        
        case feedbackPositive
        case feedbackNegativePrefix(category: String)
        
        case feedbackNegativeBrokenSites
        case feedbackNegativeOther
        
        case feedbackNegativeBrowserFeaturesNav
        case feedbackNegativeBrowserFeaturesTabs
        case feedbackNegativeBrowserFeaturesAds
        case feedbackNegativeBrowserFeaturesVideos
        case feedbackNegativeBrowserFeaturesImages
        case feedbackNegativeBrowserFeaturesBookmarks
        case feedbackNegativeBrowserFeaturesOther
        
        case feedbackNegativeBadResultsTechnical
        case feedbackNegativeBadResultsLayout
        case feedbackNegativeBadResultsSpeed
        case feedbackNegativeBadResultsLangOrRegion
        case feedbackNegativeBadResultsAutocomplete
        case feedbackNegativeBadResultsOther
        
        case feedbackNegativeCustomizationHome
        case feedbackNegativeCustomizationTabs
        case feedbackNegativeCustomizationUI
        case feedbackNegativeCustomizationWhatCleared
        case feedbackNegativeCustomizationWhenCleared
        case feedbackNegativeCustomizationBookmarks
        case feedbackNegativeCustomizationOther
        
        case feedbackNegativePerformanceSlow
        case feedbackNegativePerformanceCrash
        case feedbackNegativePerformanceVideo
        case feedbackNegativePerformanceOther
        
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
        case daxDialogsAutoconsentShown
        case daxDialogsAutoconsentConfirmed
        case daxDialogsAutoconsentCancelled

        case defaultBrowserButtonPressedSettings
        
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
        
        case bookmarksFolderCreated
        
        case bookmarkCreatedAtTopLevel
        case bookmarkCreatedInSubfolder
        
        case bookmarkEditedAtTopLevel
        case bookmarkEditedInSubfolder
        
        case bookmarkImportSuccess
        case bookmarkImportFailure
        case bookmarkImportFailureParsingDL
        case bookmarkImportFailureParsingBody
        case bookmarkImportFailureTransformingSafari
        case bookmarkImportFailureSaving
        case bookmarkImportFailureUnknown
        case bookmarkExportSuccess
        case bookmarkExportFailure
        
        case textSizeSettingsShown
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
        
        case downloadPreparingToStart
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
        case autofillLoginsSettingsAddNewLoginErrorAttemptedToCreateDuplicate
        case autofillLoginsSettingsResetExcludedDisplayed
        case autofillLoginsSettingsResetExcludedConfirmed
        case autofillLoginsSettingsResetExcludedDismissed

        case autofillLoginsPasswordGenerationPromptDisplayed
        case autofillLoginsPasswordGenerationPromptConfirmed
        case autofillLoginsPasswordGenerationPromptDismissed

        case autofillJSPixelFired(_ pixel: AutofillUserScript.JSPixel)
        
        case secureVaultInitError
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

        case appTPVPNCrash
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

        case networkProtectionRekeyCompleted
        case networkProtectionLatency

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

        case networkProtectionServerListStoreFailedToEncodeServerList
        case networkProtectionServerListStoreFailedToDecodeServerList
        case networkProtectionServerListStoreFailedToWriteServerList
        case networkProtectionServerListStoreFailedToReadServerList

        case networkProtectionKeychainErrorFailedToCastKeychainValueToData
        case networkProtectionKeychainReadError
        case networkProtectionKeychainWriteError
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

        case networkProtectionWaitlistUserActive
        case networkProtectionSettingsRowDisplayed
        case networkProtectionWaitlistIntroScreenDisplayed
        case networkProtectionWaitlistTermsDisplayed
        case networkProtectionWaitlistTermsAccepted
        case networkProtectionWaitlistNotificationShown
        case networkProtectionWaitlistNotificationLaunched

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
        
        case contentBlockingErrorReportingIssue
        case contentBlockingCompilationTime
        
        case ampBlockingRulesCompilationFailed

        case webKitDidTerminate
        case webKitTerminationDidReloadCurrentTab
        
        case backgroundTaskSubmissionFailed
        
        case blankOverlayNotDismissed
        
        case cookieDeletionTimedOut
        case cookieDeletionLeftovers
        case legacyCookieMigration
        case legacyCookieCleanupError
        
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

        // Return user measurement
        case debugReturnUserReadATB
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
        case orphanedBookmarksPresent
        
        case bookmarksCouldNotLoadDatabase
        case bookmarksCouldNotPrepareDatabase
        case bookmarksMigrationAlreadyPerformed
        case bookmarksMigrationFailed
        case bookmarksMigrationCouldNotPrepareDatabase
        case bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration
        case bookmarksMigrationCouldNotValidateDatabase
        case bookmarksMigrationCouldNotRemoveOldStore
        case bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders

        case syncFailedToMigrate
        case syncFailedToLoadAccount
        case syncFailedToSetupEngine
        case syncBookmarksCountLimitExceededDaily
        case syncCredentialsCountLimitExceededDaily
        case syncBookmarksRequestSizeLimitExceededDaily
        case syncCredentialsRequestSizeLimitExceededDaily

        case syncSentUnauthenticatedRequest
        case syncMetadataCouldNotLoadDatabase
        case syncBookmarksProviderInitializationFailed
        case syncBookmarksFailed
        case syncCredentialsProviderInitializationFailed
        case syncCredentialsFailed
        case syncSettingsFailed
        case syncSettingsMetadataUpdateFailed

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
    }
    
}

extension Pixel.Event: Equatable {}

extension Pixel.Event {
    
    public var name: String {
        switch self {
        case .appLaunch: return "ml"
        case .refreshPressed: return "m_r"
            
        case .forgetAllPressedBrowsing: return "mf_bp"
        case .forgetAllPressedTabSwitching: return "mf_tp"
        case .forgetAllExecuted: return "mf"
        case .forgetAllDataCleared: return "mf_dc"
            
        case .privacyDashboardOpened: return "mp"
           
        case .dashboardProtectionAllowlistAdd: return "mp_wla"
        case .dashboardProtectionAllowlistRemove: return "mp_wlr"
            
        case .privacyDashboardReportBrokenSite: return "mp_rb"
        case .privacyDashboardPixelFromJS(let rawPixel): return rawPixel
            
        case .tabSwitcherNewLayoutSeen: return "m_ts_n"
        case .tabSwitcherListEnabled: return "m_ts_l"
        case .tabSwitcherGridEnabled: return "m_ts_g"
            
        case .settingsDoNotSellShown: return "ms_dns"
        case .settingsDoNotSellOn: return "ms_dns_on"
        case .settingsDoNotSellOff: return "ms_dns_off"
        
        case .settingsAutoconsentShown: return "m_settings_autoconsent_shown"
        case .settingsAutoconsentOn: return "m_settings_autoconsent_on"
        case .settingsAutoconsentOff: return "m_settings_autoconsent_off"
            
        case .browsingMenuOpened: return "mb"
        case .browsingMenuRefresh: return "mb_rf"
        case .browsingMenuNewTab: return "mb_tb"
        case .browsingMenuAddToBookmarks: return "mb_abk"
        case .browsingMenuEditBookmark: return "mb_ebk"
        case .browsingMenuAddToFavorites: return "mb_af"
        case .browsingMenuRemoveFromFavorites: return "mb_df"
        case .browsingMenuAddToFavoritesAddFavoriteFlow: return "mb_aff"
        case .browsingMenuToggleBrowsingMode: return "mb_dm"
        case .browsingMenuCopy: return "mb_cp"
        case .browsingMenuPrint: return "mb_pr"
        case .browsingMenuSettings: return "mb_st"
        case .browsingMenuFindInPage: return "mb_fp"
        case .browsingMenuDisableProtection: return "mb_wla"
        case .browsingMenuEnableProtection: return "mb_wlr"
        case .browsingMenuReportBrokenSite: return "mb_rb"
        case .browsingMenuFireproof: return "mb_f"
        case .browsingMenuAutofill: return "m_nav_autofill_menu_item_pressed"

        case .browsingMenuShare: return "m_browsingmenu_share"

        case .addressBarShare: return "m_addressbar_share"
        case .addressBarSettings: return "m_addressbar_settings"
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
            
        case .homeScreenShown: return "mh"
        case .homeScreenSearchTapped: return "mh_st"
        case .homeScreenFavouriteLaunched: return "mh_fl"
        case .homeScreenAddFavorite: return "mh_af"
        case .homeScreenAddFavoriteOK: return "mh_af_o"
        case .homeScreenAddFavoriteCancel: return "mh_af_c"
        case .homeScreenEditFavorite: return "mh_ef"
        case .homeScreenDeleteFavorite: return "mh_df"
            
        case .autocompleteSelectedLocal: return "m_au_l"
        case .autocompleteSelectedRemote: return "m_au_r"

        case .feedbackPositive: return "mfbs_positive_submit"
        case .feedbackNegativePrefix(category: let category): return "mfbs_negative_\(category)"
            
        case .feedbackNegativeBrokenSites: return "mfbs_negative_brokenSites_submit"
        case .feedbackNegativeOther: return "mfbs_negative_other_submit"
            
        case .feedbackNegativeBrowserFeaturesNav: return "mfbs_negative_browserFeatures_navigation"
        case .feedbackNegativeBrowserFeaturesTabs: return "mfbs_negative_browserFeatures_tabs"
        case .feedbackNegativeBrowserFeaturesAds: return "mfbs_negative_browserFeatures_ads"
        case .feedbackNegativeBrowserFeaturesVideos: return "mfbs_negative_browserFeatures_videos"
        case .feedbackNegativeBrowserFeaturesImages: return "mfbs_negative_browserFeatures_images"
        case .feedbackNegativeBrowserFeaturesBookmarks: return "mfbs_negative_browserFeatures_bookmarks"
        case .feedbackNegativeBrowserFeaturesOther: return "mfbs_negative_browserFeatures_other"
            
        case .feedbackNegativeBadResultsTechnical: return "mfbs_negative_badResults_technical"
        case .feedbackNegativeBadResultsLayout: return "mfbs_negative_badResults_layout"
        case .feedbackNegativeBadResultsSpeed: return "mfbs_negative_badResults_speed"
        case .feedbackNegativeBadResultsLangOrRegion: return "mfbs_negative_badResults_langRegion"
        case .feedbackNegativeBadResultsAutocomplete: return "mfbs_negative_badResults_autocomplete"
        case .feedbackNegativeBadResultsOther: return "mfbs_negative_badResults_other"
            
        case .feedbackNegativeCustomizationHome: return "mfbs_negative_customization_home"
        case .feedbackNegativeCustomizationTabs: return "mfbs_negative_customization_tabs"
        case .feedbackNegativeCustomizationUI: return "mfbs_negative_customization_ui"
        case .feedbackNegativeCustomizationWhatCleared: return "mfbs_negative_customization_whichDataCleared"
        case .feedbackNegativeCustomizationWhenCleared: return "mfbs_negative_customization_whenDataCleared"
        case .feedbackNegativeCustomizationBookmarks: return "mfbs_negative_customization_bookmarks"
        case .feedbackNegativeCustomizationOther: return "mfbs_negative_customization_other"
            
        case .feedbackNegativePerformanceSlow: return "mfbs_negative_performance_slow"
        case .feedbackNegativePerformanceCrash: return "mfbs_negative_performance_crash"
        case .feedbackNegativePerformanceVideo: return "mfbs_negative_performance_video"
        case .feedbackNegativePerformanceOther: return "mfbs_negative_performance_other"
            
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
        case .daxDialogsAutoconsentShown: return "m_dax_dialog_autoconsent_shown"
        case .daxDialogsAutoconsentConfirmed: return "m_dax_dialog_autoconsent_confirmed"
        case .daxDialogsAutoconsentCancelled: return "m_dax_dialog_autoconsent_cancelled"
            
        case .defaultBrowserButtonPressedSettings: return "m_db_s"
            
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
            
        case .bookmarksFolderCreated: return "m_bookmarks_folder_created"
            
        case .bookmarkCreatedAtTopLevel: return "m_bookmark_created_at_top_level"
        case .bookmarkCreatedInSubfolder: return "m_bookmark_created_in_subfolder"
            
        case .bookmarkEditedAtTopLevel: return "m_bookmark_edited_at_top_level"
        case .bookmarkEditedInSubfolder: return "m_bookmark_edited_in_subfolder"
            
        case .bookmarkImportSuccess: return "m_bi_s"
        case .bookmarkImportFailure: return "m_bi_e"
        case .bookmarkImportFailureParsingDL: return "m_bi_e_parsing_dl"
        case .bookmarkImportFailureParsingBody: return "m_bi_e_parsing_body"
        case .bookmarkImportFailureTransformingSafari: return "m_bi_e_transforming_safari"
        case .bookmarkImportFailureSaving: return "m_bi_e_saving"
        case .bookmarkImportFailureUnknown: return "m_bi_e_unknown"
        case .bookmarkExportSuccess: return "m_be_a"
        case .bookmarkExportFailure: return "m_be_e"
            
        case .textSizeSettingsShown: return "m_text_size_settings_shown"
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
            
        case .downloadPreparingToStart: return "m_download_preparing_to_start"
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
        case .autofillLoginsSettingsAddNewLoginErrorAttemptedToCreateDuplicate:
            return "m_autofill_logins_settings_add-new-login_error_attempted-to-create-duplicate"
        case .autofillLoginsSettingsResetExcludedDisplayed: return "m_autofill_settings_reset_excluded_displayed"
        case .autofillLoginsSettingsResetExcludedConfirmed: return "m_autofill_settings_reset_excluded_confirmed"
        case .autofillLoginsSettingsResetExcludedDismissed: return "m_autofill_settings_reset_excluded_dismissed"

        case .autofillLoginsPasswordGenerationPromptDisplayed: return "m_autofill_logins_password_generation_prompt_displayed"
        case .autofillLoginsPasswordGenerationPromptConfirmed: return "m_autofill_logins_password_generation_prompt_confirmed"
        case .autofillLoginsPasswordGenerationPromptDismissed: return "m_autofill_logins_password_generation_prompt_dismissed"

        case .autofillJSPixelFired(let pixel):
            return "m_ios_\(pixel.pixelName)"
            
        case .secureVaultInitError: return "m_secure_vault_init_error"
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
        case .appTPVPNCrash: return "m_apptp_vpn_crash"
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
        case .networkProtectionRekeyCompleted: return "m_netp_rekey_completed"
        case .networkProtectionLatency: return "m_netp_latency"
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
        case .networkProtectionServerListStoreFailedToEncodeServerList: return "m_netp_storage_error_failed_to_encode_server_list"
        case .networkProtectionServerListStoreFailedToDecodeServerList: return "m_netp_storage_error_failed_to_decode_server_list"
        case .networkProtectionServerListStoreFailedToWriteServerList: return "m_netp_storage_error_server_list_file_system_write_failed"
        case .networkProtectionServerListStoreFailedToReadServerList: return "m_netp_storage_error_server_list_file_system_read_failed"
        case .networkProtectionKeychainErrorFailedToCastKeychainValueToData: return "m_netp_keychain_error_failed_to_cast_keychain_value_to_data"
        case .networkProtectionKeychainReadError: return "m_netp_keychain_error_read_failed"
        case .networkProtectionKeychainWriteError: return "m_netp_keychain_error_write_failed"
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

        case .networkProtectionWaitlistUserActive: return "m_netp_waitlist_user_active"
        case .networkProtectionSettingsRowDisplayed: return "m_netp_waitlist_settings_entry_viewed"
        case .networkProtectionWaitlistIntroScreenDisplayed: return "m_netp_waitlist_intro_screen_viewed"
        case .networkProtectionWaitlistTermsDisplayed: return "m_netp_waitlist_terms_viewed"
        case .networkProtectionWaitlistTermsAccepted: return "m_netp_waitlist_terms_accepted"
        case .networkProtectionWaitlistNotificationShown: return "m_netp_waitlist_notification_shown"
        case .networkProtectionWaitlistNotificationLaunched: return "m_netp_waitlist_notification_launched"

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
            
        case .contentBlockingErrorReportingIssue: return "m_content_blocking_error_reporting_issue"
        case .contentBlockingCompilationTime: return "m_content_blocking_compilation_time"
            
        case .ampBlockingRulesCompilationFailed: return "m_debug_amp_rules_compilation_failed"

        case .webKitDidTerminate: return "m_d_wkt"
        case .webKitTerminationDidReloadCurrentTab: return "m_d_wktct"
            
        case .backgroundTaskSubmissionFailed: return "m_bt_rf"
            
        case .blankOverlayNotDismissed: return "m_d_ovs"
            
        case .cookieDeletionTimedOut: return "m_d_csto"
        case .cookieDeletionLeftovers: return "m_cookie_deletion_leftovers"
        case .legacyCookieMigration: return "m_legacy_cookie_migration"
        case .legacyCookieCleanupError: return "m_legacy_cookie_cleanup_error"
            
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
        case .orphanedBookmarksPresent: return "m_d_bookmarks_orphans_present"
            
        case .bookmarksCouldNotLoadDatabase: return "m_d_bookmarks_could_not_load_database"
        case .bookmarksCouldNotPrepareDatabase: return "m_d_bookmarks_could_not_prepare_database"
        case .bookmarksMigrationAlreadyPerformed: return "m_d_bookmarks_migration_already_performed"
        case .bookmarksMigrationFailed: return "m_d_bookmarks_migration_failed"
        case .bookmarksMigrationCouldNotPrepareDatabase: return "m_d_bookmarks_migration_could_not_prepare_database"
        case .bookmarksMigrationCouldNotPrepareDatabaseOnFailedMigration:
            return "m_d_bookmarks_migration_could_not_prepare_database_on_failed_migration"
        case .bookmarksMigrationCouldNotValidateDatabase: return "m_d_bookmarks_migration_could_not_validate_database"
        case .bookmarksMigrationCouldNotRemoveOldStore: return "m_d_bookmarks_migration_could_not_remove_old_store"
        case .bookmarksMigrationCouldNotPrepareMultipleFavoriteFolders: return "m_d_bookmarks_migration_could_not_prepare_multiple_favorite_folders"

        case .syncFailedToMigrate: return "m_d_sync_failed_to_migrate"
        case .syncFailedToLoadAccount: return "m_d_sync_failed_to_load_account"
        case .syncFailedToSetupEngine: return "m_d_sync_failed_to_setup_engine"
        case .syncBookmarksCountLimitExceededDaily: return "m_d_sync_bookmarks_count_limit_exceeded_daily"
        case .syncCredentialsCountLimitExceededDaily: return "m_d_sync_credentials_count_limit_exceeded_daily"
        case .syncBookmarksRequestSizeLimitExceededDaily: return "m_d_sync_bookmarks_request_size_limit_exceeded_daily"
        case .syncCredentialsRequestSizeLimitExceededDaily: return "m_d_sync_credentials_request_size_limit_exceeded_daily"

        case .syncSentUnauthenticatedRequest: return "m_d_sync_sent_unauthenticated_request"
        case .syncMetadataCouldNotLoadDatabase: return "m_d_sync_metadata_could_not_load_database"
        case .syncBookmarksProviderInitializationFailed: return "m_d_sync_bookmarks_provider_initialization_failed"
        case .syncBookmarksFailed: return "m_d_sync_bookmarks_failed"
        case .syncCredentialsProviderInitializationFailed: return "m_d_sync_credentials_provider_initialization_failed"
        case .syncCredentialsFailed: return "m_d_sync_credentials_failed"
        case .syncSettingsFailed: return "m_d_sync_settings_failed"
        case .syncSettingsMetadataUpdateFailed: return "m_d_sync_settings_metadata_update_failed"


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
        case .debugReturnUserReadATB: return "m_debug_return_user_read_atb"
        case .debugReturnUserUpdateATB: return "m_debug_return_user_update_atb"
        }
        
    }
    
}

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
