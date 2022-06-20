//
//  Pixel.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import os.log

// swiftlint:disable file_length
// swiftlint:disable identifier_name
// swiftlint:disable type_body_length
public enum PixelName: String {
    
    case appLaunch = "ml"
    case defaultBrowserLaunch = "m_dl"
    case refreshPressed = "m_r"

    case forgetAllPressedBrowsing = "mf_bp"
    case forgetAllPressedTabSwitching = "mf_tp"
    case forgetAllExecuted = "mf"
    case forgetAllDataCleared = "mf_dc"

    case privacyDashboardOpened = "mp"
    case privacyDashboardScorecard = "mp_c"
    case privacyDashboardEncryption = "mp_e"
    case privacyDashboardNetworks = "mp_n"
    case privacyDashboardPrivacyPractices = "mp_p"
    case privacyDashboardGlobalStats = "mp_s"
    case privacyDashboardProtectionDisabled = "mp_wla"
    case privacyDashboardProtectionEnabled = "mp_wlr"
    case privacyDashboardManageProtection = "mp_mw"
    case privacyDashboardReportBrokenSite = "mp_rb"
    
    case tabSwitcherNewLayoutSeen = "m_ts_n"
    case tabSwitcherListEnabled = "m_ts_l"
    case tabSwitcherGridEnabled = "m_ts_g"
    
    case settingsDoNotSellShown = "ms_dns"
    case settingsDoNotSellOn = "ms_dns_on"
    case settingsDoNotSellOff = "ms_dns_off"

    case browsingMenuOpened = "mb"
    case browsingMenuRefresh = "mb_rf"
    case browsingMenuNewTab = "mb_tb"
    case browsingMenuAddToBookmarks = "mb_abk"
    case browsingMenuEditBookmark = "mb_ebk"
    case browsingMenuAddToFavorites = "mb_af"
    case browsingMenuRemoveFromFavorites = "mb_df"
    case browsingMenuAddToFavoritesAddFavoriteFlow = "mb_aff"
    case browsingMenuToggleBrowsingMode = "mb_dm"
    case browsingMenuShare = "mb_sh"
    case browsingMenuCopy = "mb_cp"
    case browsingMenuPrint = "mb_pr"
    case browsingMenuSettings = "mb_st"
    case browsingMenuFindInPage = "mb_fp"
    case browsingMenuDisableProtection = "mb_wla"
    case browsingMenuEnableProtection = "mb_wlr"
    case browsingMenuReportBrokenSite = "mb_rb"
    case browsingMenuFireproof = "mb_f"
    
    case tabBarBackPressed = "mt_bk"
    case tabBarForwardPressed = "mt_fw"
    case bookmarksButtonPressed = "mt_bm"
    case tabBarBookmarksLongPressed = "mt_bl"
    case tabBarTabSwitcherPressed = "mt_tb"

    case homeScreenShown = "mh"
    case homeScreenSearchTapped = "mh_st"
    case homeScreenFavouriteLaunched = "mh_fl"
    case homeScreenAddFavorite = "mh_af"
    case homeScreenAddFavoriteOK = "mh_af_o"
    case homeScreenAddFavoriteCancel = "mh_af_c"
    case homeScreenEditFavorite = "mh_ef"
    case homeScreenDeleteFavorite = "mh_df"
    
    case autocompleteSelectedLocal = "m_au_l"
    case autocompleteSelectedRemote = "m_au_r"

    case feedbackPositive = "mfbs_positive_submit"
    case feedbackNegativePrefix = "mfbs_negative_"
    
    case feedbackNegativeBrokenSites = "mfbs_negative_brokenSites_submit"
    case feedbackNegativeOther = "mfbs_negative_other_submit"
    
    case feedbackNegativeBrowserFeaturesNav = "mfbs_negative_browserFeatures_navigation"
    case feedbackNegativeBrowserFeaturesTabs = "mfbs_negative_browserFeatures_tabs"
    case feedbackNegativeBrowserFeaturesAds = "mfbs_negative_browserFeatures_ads"
    case feedbackNegativeBrowserFeaturesVideos = "mfbs_negative_browserFeatures_videos"
    case feedbackNegativeBrowserFeaturesImages = "mfbs_negative_browserFeatures_images"
    case feedbackNegativeBrowserFeaturesBookmarks = "mfbs_negative_browserFeatures_bookmarks"
    case feedbackNegativeBrowserFeaturesOther = "mfbs_negative_browserFeatures_other"
    
    case feedbackNegativeBadResultsTechnical = "mfbs_negative_badResults_technical"
    case feedbackNegativeBadResultsLayout = "mfbs_negative_badResults_layout"
    case feedbackNegativeBadResultsSpeed = "mfbs_negative_badResults_speed"
    case feedbackNegativeBadResultsLangOrRegion = "mfbs_negative_badResults_langRegion"
    case feedbackNegativeBadResultsAutocomplete = "mfbs_negative_badResults_autocomplete"
    case feedbackNegativeBadResultsOther = "mfbs_negative_badResults_other"
    
    case feedbackNegativeCustomizationHome = "mfbs_negative_customization_home"
    case feedbackNegativeCustomizationTabs = "mfbs_negative_customization_tabs"
    case feedbackNegativeCustomizationUI = "mfbs_negative_customization_ui"
    case feedbackNegativeCustomizationWhatCleared = "mfbs_negative_customization_whichDataCleared"
    case feedbackNegativeCustomizationWhenCleared = "mfbs_negative_customization_whenDataCleared"
    case feedbackNegativeCustomizationBookmarks = "mfbs_negative_customization_bookmarks"
    case feedbackNegativeCustomizationOther = "mfbs_negative_customization_other"
    
    case feedbackNegativePerformanceSlow = "mfbs_negative_performance_slow"
    case feedbackNegativePerformanceCrash = "mfbs_negative_performance_crash"
    case feedbackNegativePerformanceVideo = "mfbs_negative_performance_video"
    case feedbackNegativePerformanceOther = "mfbs_negative_performance_other"
    
    case brokenSiteReport = "epbf"
    
    case daxDialogsSerp = "m_dx_s"
    case daxDialogsWithoutTrackers = "m_dx_wo"
    case daxDialogsWithoutTrackersFollowUp = "m_dx_wof"
    case daxDialogsWithTrackers = "m_dx_wt"
    case daxDialogsSiteIsMajor = "m_dx_sm"
    case daxDialogsSiteOwnedByMajor = "m_dx_so"
    case daxDialogsHidden = "m_dx_h"
    case daxDialogsFireEducationShown = "m_dx_fe_s"
    case daxDialogsFireEducationConfirmed = "m_dx_fe_co"
    case daxDialogsFireEducationCancelled = "m_dx_fe_ca"
    
    case widgetFavoriteLaunch = "m_w_fl"
    case widgetNewSearch = "m_w_ns"

    case defaultBrowserButtonPressedSettings = "m_db_s"
    
    case widgetsOnboardingCTAPressed = "m_o_w_a"
    case widgetsOnboardingDeclineOptionPressed = "m_o_w_d"
    case widgetsOnboardingMovedToBackground = "m_o_w_b"

    case emailUserPressedUseAddress = "email_filled_main"
    case emailUserPressedUseAlias = "email_filled_random"
    case emailUserCreatedAlias = "email_generated_button"
    case emailTooltipDismissed = "email_tooltip_dismissed"
    
    case voiceSearchDone = "m_voice_search_done"
    case openVoiceSearch = "m_open_voice_search"
    case voiceSearchCancelled = "m_voice_search_cancelled"

    case emailDidShowWaitlistDialog = "email_did_show_waitlist_dialog"
    case emailDidPressWaitlistDialogDismiss = "email_did_press_waitlist_dialog_dismiss"
    case emailDidPressWaitlistDialogNotifyMe = "email_did_press_waitlist_dialog_notify_me"
    
    case bookmarksFolderCreated = "m_bookmarks_folder_created"

    case bookmarkCreatedAtTopLevel = "m_bookmark_created_at_top_level"
    case bookmarkCreatedInSubfolder = "m_bookmark_created_in_subfolder"

    case bookmarkEditedAtTopLevel = "m_bookmark_edited_at_top_level"
    case bookmarkEditedInSubfolder = "m_bookmark_edited_in_subfolder"
    
    case bookmarkImportSuccess = "m_bi_s"
    case bookmarkImportFailure = "m_bi_e"
    case bookmarkImportFailureParsingDL = "m_bi_e_parsing_dl"
    case bookmarkImportFailureParsingBody = "m_bi_e_parsing_body"
    case bookmarkImportFailureTransformingSafari = "m_bi_e_transforming_safari"
    case bookmarkImportFailureSaving = "m_bi_e_saving"
    case bookmarkImportFailureUnknown = "m_bi_e_unknown"
    case bookmarkExportSuccess = "m_be_a"
    case bookmarkExportFailure = "m_be_e"

    case textSizeSettingsShown = "m_text_size_settings_shown"
    case textSizeSettingsChanged = "m_text_size_settings_changed"
    
    case downloadStarted = "m_download_started"
    case downloadStartedDueToUnhandledMIMEType = "m_download_started_due_to_unhandled_mime_type"
    case downloadTriedToPresentPreviewWithoutTab = "m_download_tried_to_present_preview_without_tab"
    case downloadsListOpened = "m_downloads_list_opened"

    case downloadsListOngoingDownloadCancelled = "m_downloads_list_ongoing_download_cancelled"
    case downloadsListCompleteDownloadDeleted = "m_downloads_list_complete_download_deleted"
    case downloadsListAllCompleteDownloadsDeleted = "m_downloads_list_all_complete_downloads_deleted"
    case downloadsListDeleteUndo = "m_downloads_list_delete_undo"
    case downloadsListSharePressed = "m_downloads_list_share_pressed"
    
    case downloadsSharingPredownloadedLocalFile = "m_downloads_sharing_predownloaded_local_file"
    
    case downloadAttemptToOpenBLOB = "m_download_attempt_to_open_blob"

    case jsAlertShown = "m_js_alert_shown"
    case jsAlertBlocked = "m_js_alert_blocked"
    
    case featureFlaggingInternalUserAuthenticated = "m_internal-user_authenticated"

    case autofillLoginsSaveLoginModalOnboardingDisplayed = "m_autofill_logins_save_login_onboarding_inline_displayed"
    
    case autofillLoginsSaveLoginModalDisplayed = "m_autofill_logins_save_login_inline_displayed"
    case autofillLoginsSaveLoginModalConfirmed = "m_autofill_logins_save_login_inline_confirmed"
    
    case autofillLoginsSavePasswordModalDisplayed = "m_autofill_logins_save_password_inline_displayed"
    case autofillLoginsSavePasswordModalConfirmed = "m_autofill_logins_save_password_inline_confirmed"
    
    case autofillLoginsUpdatePasswordModalDisplayed = "m_autofill_logins_update_password_inline_displayed"
    case autofillLoginsUpdatePasswordModalConfirmed = "m_autofill_logins_update_password_inline_confirmed"
    
    case autofillLoginsUpdateUsernameModelDisplayed = "m_autofill_logins_update_username_inline_displayed"
    case autofillLoginsUpdateUsernameModelConfirmed = "m_autofill_logins_update_username_inline_confirmed"

    case autofillLoginsFillLoginInlineDisplayed = "m_autofill_logins_fill_login_inline_displayed"
    case autofillLoginsFillLoginInlineConfirmed = "m_autofill_logins_fill_login_inline_confirmed"
    case autofillLoginsFillLoginInlineAuthenticationDeviceAuthAuthenticated =
            "m_autofill_logins_fill_login_inline_authentication_device-auth_authenticated"
    case autofillLoginsFillLoginInlineAuthenticationDeviceAuthFailed = "m_autofill_logins_fill_login_inline_authentication_device-auth_failed"
    case autofillLoginsFillLoginInlineAuthenticationDeviceAuthUnavailable =
            "m_autofill_logins_fill_login_inline_authentication_device-auth_unavailable"

    case autofillSettingsOpened = "m_autofill_settings_opened"

    case secureVaultInitError = "m_secure_vault_init_error"
    case secureVaultError = "m_secure_vault_error"

    // MARK: SERP pixels
    
    case serpRequerySame = "rq_0"
    case serpRequeryNew = "rq_1"
    
    // MARK: macOS browser waitlist pixels
    
    case macBrowserWaitlistDidPressShareButton = "m_macos_waitlist_did_press_share_button"
    case macBrowserWaitlistDidPressShareButtonDismiss = "m_macos_waitlist_did_press_share_button_dismiss"
    case macBrowserWaitlistDidPressShareButtonShared = "m_macos_waitlist_did_press_share_button_shared"
    
    case macBrowserWaitlistNotificationShown = "m_notification_shown_mac_waitlist"
    case macBrowserWaitlistNotificationLaunched = "m_notification_launch_mac_waitlist"

    // MARK: debug pixels
    
    case dbMigrationError = "m_d_dbme"
    case dbRemovalError = "m_d_dbre"
    case dbDestroyError = "m_d_dbde"
    case dbDestroyFileError = "m_d_dbdf"
    case dbInitializationError = "m_d_dbie"
    case dbSaveExcludedHTTPSDomainsError = "m_d_dbsw"
    case dbSaveBloomFilterError = "m_d_dbsb"
    
    case configurationFetchInfo = "m_d_cfgfetch"
    
    case trackerDataParseFailed = "m_d_tds_p"
    case trackerDataReloadFailed = "m_d_tds_r"
    case trackerDataCouldNotBeLoaded = "m_d_tds_l"
    case fileStoreWriteFailed = "m_d_fswf"
    case privacyConfigurationReloadFailed = "m_d_pc_r"
    case privacyConfigurationParseFailed = "m_d_pc_p"
    case privacyConfigurationCouldNotBeLoaded = "m_d_pc_l"
    
    case contentBlockingTDSCompilationFailed = "m_d_cb_ct"
    case contentBlockingTempListCompilationFailed = "m_d_cb_cl"
    case contentBlockingAllowListCompilationFailed = "m_d_cb_ca"
    case contentBlockingUnpSitesCompilationFailed = "m_d_cb_cu"
    case contentBlockingFallbackCompilationFailed = "m_d_cb_cf"
    
    case contentBlockingErrorReportingIssue = "m_content_blocking_error_reporting_issue"
    case contentBlockingCompilationTime = "m_content_blocking_compilation_time"

    case ampBlockingRulesCompilationFailed = "m_debug_amp_rules_compilation_failed"

    case contentBlockingIdentifierError = "m_d_cb_ie"

    case webKitDidTerminate = "m_d_wkt"
    case webKitTerminationDidReloadCurrentTab = "m_d_wktct"

    case backgroundTaskSubmissionFailed = "m_bt_rf"
    
    case blankOverlayNotDismissed = "m_d_ovs"

    case cookieDeletionTimedOut = "m_d_csto"
    case cookieDeletionLeftovers = "m_cookie_deletion_leftovers"
    case legacyCookieMigration = "m_legacy_cookie_migration"
    case legacyCookieCleanupError = "m_legacy_cookie_cleanup_error"

    case cachedTabPreviewsExceedsTabCount = "m_d_tpetc"
    case cachedTabPreviewRemovalError = "m_d_tpre"
    
    case waitResultTabClosed = "m_wait_result_tab_closed"
    case waitResultAppQuit = "m_wait_result_app_quit"
    case waitResultSuccess = "m_wait_result_success"
    
}
// swiftlint:enable type_body_length
// swiftlint:enable identifier_name

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
    static let appVersion = "appVersion"
    
    public static let autocompleteBookmarkCapable = "bc"
    public static let autocompleteIncludedLocalResults = "sb"
    
    public static let originatedFromMenu = "om"
    
    static let applicationState = "as"
    static let dataAvailiability = "dp"
    
    static let errorCode = "e"
    static let errorDomain = "d"
    static let errorDescription = "de"
    static let errorCount = "c"
    static let underlyingErrorCode = "ue"
    static let underlyingErrorDomain = "ud"

    public static let tabCount = "tc"

    public static let widgetSmall = "ws"
    public static let widgetMedium = "wm"
    public static let widgetLarge = "wl"
    public static let widgetError = "we"
    public static let widgetErrorCode = "ec"
    public static let widgetErrorDomain = "ed"
    public static let widgetUnavailable = "wx"

    static let removeCookiesTimedOut = "rc"
    static let clearWebDataTimedOut = "cd"

    public static let tabPreviewCountDelta = "cd"
    
    public static let etag = "et"

    public static let emailCohort = "cohort"
    public static let emailLastUsed = "duck_address_last_used"
    
    // Cookie clearing
    public static let storeInitialCount = "store_initial_count"
    public static let storeProtectedCount = "store_protected_count"
    public static let didStoreDeletionTimeOut = "did_store_deletion_time_out"
    public static let storageInitialCount = "storage_initial_count"
    public static let storageProtectedCount = "storage_protected_count"
    public static let storeAfterDeletionCount = "store_after_deletion_count"
    public static let storageAfterDeletionCount = "storage_after_deletion_count"
    public static let storeAfterDeletionDiffCount = "store_after_deletion_diff_count"
    public static let storageAfterDeletionDiffCount = "storage_after_deletion_diff_count"
    
    public static let count = "count"

    public static let textSizeInitial = "text_size_initial"
    public static let textSizeUpdated = "text_size_updated"
    
    public static let canAutoPreviewMIMEType = "can_auto_preview_mime_type"
    public static let mimeType = "mime_type"
    public static let fileSizeGreaterThan10MB = "file_size_greater_than_10mb"
    
    public static let bookmarkCount = "bco"
}

public struct PixelValues {
    static let test = "1"
}

public class Pixel {

    private static let appUrls = AppUrls()
    
    private struct Constants {
        static let tablet = "tablet"
        static let phone = "phone"
    }

    public enum QueryParameters {
        case atb
        case appVersion
    }
    
    private init() {
    }
    
    public static func fire(pixel: Pixel.Event,
                            forDeviceType deviceType: UIUserInterfaceIdiom? = UIDevice.current.userInterfaceIdiom,
                            withAdditionalParameters params: [String: String] = [:],
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders,
                            includedParameters: [QueryParameters] = [.atb, .appVersion],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        
        var newParams = params
        if includedParameters.contains(.appVersion) {
            newParams[PixelParameters.appVersion] = AppVersion.shared.versionAndBuildNumber
        }
        if isDebugBuild {
            newParams[PixelParameters.test] = PixelValues.test
        }
        
        let url: URL
        if let deviceType = deviceType {
            let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
            url = appUrls.pixelUrl(forPixelNamed: pixel.name,
                                   formFactor: formFactor,
                                   includeATB: includedParameters.contains(.atb))
        } else {
            url = appUrls.pixelUrl(forPixelNamed: pixel.name, includeATB: includedParameters.contains(.atb) )
        }
        
        APIRequest.request(url: url, parameters: newParams, headers: headers, callBackOnMainThread: true) { (_, error) in
            
            os_log("Pixel fired %s %s", log: generalLog, type: .debug, pixel.name, "\(params)")
            onComplete(error)
        }
    }
    
}

extension Pixel {
    
    public static func fire(pixel: Pixel.Event,
                            error: Error,
                            withAdditionalParameters params: [String: String] = [:],
                            onComplete: @escaping (Error?) -> Void = { _ in }) {
        let nsError = error as NSError
        var newParams = params
        newParams[PixelParameters.errorCode] = "\(nsError.code)"
        newParams[PixelParameters.errorDomain] = nsError.domain
        
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError {
            newParams[PixelParameters.underlyingErrorCode] = "\(underlyingError.code)"
            newParams[PixelParameters.underlyingErrorDomain] = underlyingError.domain
        } else if let sqlErrorCode = nsError.userInfo["NSSQLiteErrorDomain"] as? NSNumber {
            newParams[PixelParameters.underlyingErrorCode] = "\(sqlErrorCode.intValue)"
            newParams[PixelParameters.underlyingErrorDomain] = "NSSQLiteErrorDomain"
        }
        fire(pixel: pixel, withAdditionalParameters: newParams, includedParameters: [], onComplete: onComplete)
    }
}

public class TimedPixel {
    
    let pixel: Pixel.Event
    let date: Date
    
    public init(_ pixel: Pixel.Event, date: Date = Date()) {
        self.pixel = pixel
        self.date = date
    }
    
    public func fire(_ fireDate: Date = Date(), withAdditionalParameters params: [String: String] = [:]) {
        let duration = String(fireDate.timeIntervalSince(date))
        var newParams = params
        newParams[PixelParameters.duration] = duration
        Pixel.fire(pixel: pixel, withAdditionalParameters: newParams)
    }
    
}
// swiftlint:enable file_length
