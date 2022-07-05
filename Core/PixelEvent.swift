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

// swiftlint:disable file_length
// swiftlint:disable identifier_name
// swiftlint:disable type_body_length
extension Pixel {
    
    public enum Event {
        
        case appLaunch
        case defaultBrowserLaunch
        case refreshPressed
        
        case forgetAllPressedBrowsing
        case forgetAllPressedTabSwitching
        case forgetAllExecuted
        case forgetAllDataCleared
        
        case privacyDashboardOpened
        case privacyDashboardScorecard
        case privacyDashboardEncryption
        case privacyDashboardNetworks
        case privacyDashboardPrivacyPractices
        case privacyDashboardGlobalStats
        case privacyDashboardProtectionDisabled
        case privacyDashboardProtectionEnabled
        case privacyDashboardManageProtection
        case privacyDashboardReportBrokenSite
        
        case tabSwitcherNewLayoutSeen
        case tabSwitcherListEnabled
        case tabSwitcherGridEnabled
        
        case settingsDoNotSellShown
        case settingsDoNotSellOn
        case settingsDoNotSellOff
        
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
        
        case widgetFavoriteLaunch
        case widgetNewSearch
        
        case defaultBrowserButtonPressedSettings
        
        case widgetsOnboardingCTAPressed
        case widgetsOnboardingDeclineOptionPressed
        case widgetsOnboardingMovedToBackground
        
        case emailUserPressedUseAddress
        case emailUserPressedUseAlias
        case emailUserCreatedAlias
        case emailTooltipDismissed
        
        case voiceSearchDone
        case openVoiceSearch
        case voiceSearchCancelled
        
        case emailDidShowWaitlistDialog
        case emailDidPressWaitlistDialogDismiss
        case emailDidPressWaitlistDialogNotifyMe
        
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
        case downloadAttemptToOpenBLOB
        
        case jsAlertShown
        case jsAlertBlocked
        case jsAlertBackgroundTap

        case featureFlaggingInternalUserAuthenticated

        case autofillLoginsSaveLoginModalOnboardingDisplayed
        
        case autofillLoginsSaveLoginModalDisplayed
        case autofillLoginsSaveLoginModalConfirmed
        
        case autofillLoginsSavePasswordModalDisplayed
        case autofillLoginsSavePasswordModalConfirmed
        
        case autofillLoginsUpdatePasswordModalDisplayed
        case autofillLoginsUpdatePasswordModalConfirmed
        
        case autofillLoginsUpdateUsernameModelDisplayed
        case autofillLoginsUpdateUsernameModelConfirmed

        case autofillLoginsFillLoginInlineDisplayed
        case autofillLoginsFillLoginInlineConfirmed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed
        case autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable

        case autofillSettingsOpened

        case secureVaultInitError
        case secureVaultError
        
        case secureVaultInitFailedError
        case secureVaultFailedToOpenDatabaseError
        
        // MARK: SERP pixels
        
        case serpRequerySame
        case serpRequeryNew
        
        // MARK: macOS browser waitlist pixels
        
        case macBrowserWaitlistDidPressShareButton
        case macBrowserWaitlistDidPressShareButtonDismiss
        case macBrowserWaitlistDidPressShareButtonShared
        
        case macBrowserWaitlistNotificationShown
        case macBrowserWaitlistNotificationLaunched
        
        // MARK: debug pixels
        
        case dbMigrationError
        case dbRemovalError
        case dbDestroyError
        case dbDestroyFileError
        case dbInitializationError
        case dbSaveExcludedHTTPSDomainsError
        case dbSaveBloomFilterError
        
        case configurationFetchInfo
        
        case trackerDataParseFailed
        case trackerDataReloadFailed
        case trackerDataCouldNotBeLoaded
        case fileStoreWriteFailed
        case privacyConfigurationReloadFailed
        case privacyConfigurationParseFailed
        case privacyConfigurationCouldNotBeLoaded
        
        case contentBlockingTDSCompilationFailed
        case contentBlockingTempListCompilationFailed
        case contentBlockingAllowListCompilationFailed
        case contentBlockingUnpSitesCompilationFailed
        case contentBlockingFallbackCompilationFailed
        
        case contentBlockingErrorReportingIssue
        case contentBlockingCompilationTime
        
        case ampBlockingRulesCompilationFailed
        
        case contentBlockingIdentifierError
        
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
        
        case compilationResult(result: CompileRulesResult, waitTime: CompileRulesWaitTime, appState: AppState)
        
    }
    
}

extension Pixel.Event: Equatable {}

extension Pixel.Event {
    
    public var name: String {
        switch self {
        case .appLaunch: return "ml"
        case .defaultBrowserLaunch: return "m_dl"
        case .refreshPressed: return "m_r"
            
        case .forgetAllPressedBrowsing: return "mf_bp"
        case .forgetAllPressedTabSwitching: return "mf_tp"
        case .forgetAllExecuted: return "mf"
        case .forgetAllDataCleared: return "mf_dc"
            
        case .privacyDashboardOpened: return "mp"
        case .privacyDashboardScorecard: return "mp_c"
        case .privacyDashboardEncryption: return "mp_e"
        case .privacyDashboardNetworks: return "mp_n"
        case .privacyDashboardPrivacyPractices: return "mp_p"
        case .privacyDashboardGlobalStats: return "mp_s"
        case .privacyDashboardProtectionDisabled: return "mp_wla"
        case .privacyDashboardProtectionEnabled: return "mp_wlr"
        case .privacyDashboardManageProtection: return "mp_mw"
        case .privacyDashboardReportBrokenSite: return "mp_rb"
            
        case .tabSwitcherNewLayoutSeen: return "m_ts_n"
        case .tabSwitcherListEnabled: return "m_ts_l"
        case .tabSwitcherGridEnabled: return "m_ts_g"
            
        case .settingsDoNotSellShown: return "ms_dns"
        case .settingsDoNotSellOn: return "ms_dns_on"
        case .settingsDoNotSellOff: return "ms_dns_off"
            
        case .browsingMenuOpened: return "mb"
        case .browsingMenuRefresh: return "mb_rf"
        case .browsingMenuNewTab: return "mb_tb"
        case .browsingMenuAddToBookmarks: return "mb_abk"
        case .browsingMenuEditBookmark: return "mb_ebk"
        case .browsingMenuAddToFavorites: return "mb_af"
        case .browsingMenuRemoveFromFavorites: return "mb_df"
        case .browsingMenuAddToFavoritesAddFavoriteFlow: return "mb_aff"
        case .browsingMenuToggleBrowsingMode: return "mb_dm"
        case .browsingMenuShare: return "mb_sh"
        case .browsingMenuCopy: return "mb_cp"
        case .browsingMenuPrint: return "mb_pr"
        case .browsingMenuSettings: return "mb_st"
        case .browsingMenuFindInPage: return "mb_fp"
        case .browsingMenuDisableProtection: return "mb_wla"
        case .browsingMenuEnableProtection: return "mb_wlr"
        case .browsingMenuReportBrokenSite: return "mb_rb"
        case .browsingMenuFireproof: return "mb_f"
            
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
            
        case .widgetFavoriteLaunch: return "m_w_fl"
        case .widgetNewSearch: return "m_w_ns"
            
        case .defaultBrowserButtonPressedSettings: return "m_db_s"
            
        case .widgetsOnboardingCTAPressed: return "m_o_w_a"
        case .widgetsOnboardingDeclineOptionPressed: return "m_o_w_d"
        case .widgetsOnboardingMovedToBackground: return "m_o_w_b"
            
        case .emailUserPressedUseAddress: return "email_filled_main"
        case .emailUserPressedUseAlias: return "email_filled_random"
        case .emailUserCreatedAlias: return "email_generated_button"
        case .emailTooltipDismissed: return "email_tooltip_dismissed"
            
        case .voiceSearchDone: return "m_voice_search_done"
        case .openVoiceSearch: return "m_open_voice_search"
        case .voiceSearchCancelled: return "m_voice_search_cancelled"
            
        case .emailDidShowWaitlistDialog: return "email_did_show_waitlist_dialog"
        case .emailDidPressWaitlistDialogDismiss: return "email_did_press_waitlist_dialog_dismiss"
        case .emailDidPressWaitlistDialogNotifyMe: return "email_did_press_waitlist_dialog_notify_me"
            
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
        case .downloadAttemptToOpenBLOB: return "m_download_attempt_to_open_blob"
            
        case .jsAlertShown: return "m_js_alert_shown"
        case .jsAlertBlocked: return "m_js_alert_blocked"
        case .jsAlertBackgroundTap: return "m_js_alert_bg_tap"
            
        case .featureFlaggingInternalUserAuthenticated: return "m_internal-user_authenticated"

        case .autofillLoginsSaveLoginModalOnboardingDisplayed: return "m_autofill_logins_save_login_onboarding_inline_displayed"
        
        case .autofillLoginsSaveLoginModalDisplayed: return "m_autofill_logins_save_login_inline_displayed"
        case .autofillLoginsSaveLoginModalConfirmed: return "m_autofill_logins_save_login_inline_confirmed"
        
        case .autofillLoginsSavePasswordModalDisplayed: return "m_autofill_logins_save_password_inline_displayed"
        case .autofillLoginsSavePasswordModalConfirmed: return "m_autofill_logins_save_password_inline_confirmed"
        
        case .autofillLoginsUpdatePasswordModalDisplayed: return "m_autofill_logins_update_password_inline_displayed"
        case .autofillLoginsUpdatePasswordModalConfirmed: return "m_autofill_logins_update_password_inline_confirmed"
        
        case .autofillLoginsUpdateUsernameModelDisplayed: return "m_autofill_logins_update_username_inline_displayed"
        case .autofillLoginsUpdateUsernameModelConfirmed: return "m_autofill_logins_update_username_inline_confirmed"

        case .autofillLoginsFillLoginInlineDisplayed: return "m_autofill_logins_fill_login_inline_displayed"
        case .autofillLoginsFillLoginInlineConfirmed: return "m_autofill_logins_fill_login_inline_confirmed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_authenticated"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_failed"
        case .autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable:
            return "m_autofill_logins_fill_login_inline_authentication_device-auth_unavailable"
            
        case .autofillSettingsOpened: return "m_autofill_settings_opened"
            
        case .secureVaultInitError: return "m_secure_vault_init_error"
        case .secureVaultError: return "m_secure_vault_error"
            
        case .secureVaultInitFailedError: return "m_secure-vault_error_init-failed"
        case .secureVaultFailedToOpenDatabaseError: return "m_secure-vault_error_failed-to-open-database"
            
        // MARK: SERP pixels
            
        case .serpRequerySame: return "rq_0"
        case .serpRequeryNew: return "rq_1"
            
        // MARK: macOS browser waitlist pixels
            
        case .macBrowserWaitlistDidPressShareButton: return "m_macos_waitlist_did_press_share_button"
        case .macBrowserWaitlistDidPressShareButtonDismiss: return "m_macos_waitlist_did_press_share_button_dismiss"
        case .macBrowserWaitlistDidPressShareButtonShared: return "m_macos_waitlist_did_press_share_button_shared"
            
        case .macBrowserWaitlistNotificationShown: return "m_notification_shown_mac_waitlist"
        case .macBrowserWaitlistNotificationLaunched: return "m_notification_launch_mac_waitlist"
            
        // MARK: debug pixels
            
        case .dbMigrationError: return "m_d_dbme"
        case .dbRemovalError: return "m_d_dbre"
        case .dbDestroyError: return "m_d_dbde"
        case .dbDestroyFileError: return "m_d_dbdf"
        case .dbInitializationError: return "m_d_dbie"
        case .dbSaveExcludedHTTPSDomainsError: return "m_d_dbsw"
        case .dbSaveBloomFilterError: return "m_d_dbsb"
            
        case .configurationFetchInfo: return "m_d_cfgfetch"
            
        case .trackerDataParseFailed: return "m_d_tds_p"
        case .trackerDataReloadFailed: return "m_d_tds_r"
        case .trackerDataCouldNotBeLoaded: return "m_d_tds_l"
        case .fileStoreWriteFailed: return "m_d_fswf"
        case .privacyConfigurationReloadFailed: return "m_d_pc_r"
        case .privacyConfigurationParseFailed: return "m_d_pc_p"
        case .privacyConfigurationCouldNotBeLoaded: return "m_d_pc_l"
            
        case .contentBlockingTDSCompilationFailed: return "m_d_cb_ct"
        case .contentBlockingTempListCompilationFailed: return "m_d_cb_cl"
        case .contentBlockingAllowListCompilationFailed: return "m_d_cb_ca"
        case .contentBlockingUnpSitesCompilationFailed: return "m_d_cb_cu"
        case .contentBlockingFallbackCompilationFailed: return "m_d_cb_cf"
            
        case .contentBlockingErrorReportingIssue: return "m_content_blocking_error_reporting_issue"
        case .contentBlockingCompilationTime: return "m_content_blocking_compilation_time"
            
        case .ampBlockingRulesCompilationFailed: return "m_debug_amp_rules_compilation_failed"
            
        case .contentBlockingIdentifierError: return "m_d_cb_ie"
            
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
            
        case .compilationResult(result: let result, waitTime: let waitTime, appState: let appState):
            return "m_compilation_result_\(result)_time_\(waitTime)_state_\(appState)"
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
    
}
