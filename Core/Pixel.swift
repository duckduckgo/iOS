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

public enum PixelName: String {
    
    case appLaunch = "ml"
    case defaultBrowserLaunch = "m_dl"
    case navigationDetected = "m_n"

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
    
    case httpsNoLookup = "m_https_nl"
    case httpsLocalUpgrade = "m_https_lu"
    case httpsServiceRequestUpgrade = "m_https_sru"
    case httpsServiceCacheUpdgrade = "m_https_scu"
    case httpsServiceRequestNoUpdgrade = "m_https_srn"
    case httpsServiceCacheNoUpdgrade = "m_https_scn"
    
    case longPressMenuOpened = "mlp"
    case longPressMenuNewBackgroundTabItem = "mlp_b"
    case longPressMenuNewTabItem = "mlp_t"
    case longPressMenuOpenItem = "mlp_o"
    case longPressMenuReadingListItem = "mlp_r"
    case longPressMenuCopyItem = "mlp_c"
    case longPressMenuShareItem = "mlp_s"
    
    case quickActionExtensionSearch = "mqe_s"
    case quickActionExtensionFire = "mqe_f"
    case quickActionExtensionBookmarks = "mqe_b"
    case bookmarksExtensionBookmark = "mbe_b"
    
    case bookmarkTapped = "m_b_t"
    case bookmarkRemoved = "m_b_r"
    case bookmarksEditPressed = "m_b_e"
    case overlayFavoriteLaunched = "m_ov_f"
    
    case tabSwitcherNewLayoutSeen = "m_ts_n"
    case tabSwitcherListEnabled = "m_ts_l"
    case tabSwitcherGridEnabled = "m_ts_g"
    
    case settingsOpened = "ms"
    case settingsHomeRowInstructionsRequested = "ms_hr"
    
    case settingsThemeShown = "ms_tp"
    case settingsThemeChangedSystemDefault = "ms_ts"
    case settingsThemeChangedLight = "ms_tl"
    case settingsThemeChangedDark = "ms_td"

    case settingsAppIconShown = "ms_ais"
    case settingsAppIconChangedPrefix = "ms_aic_"
    case settingsAppIconChangedRed = "ms_aic_red"
    case settingsAppIconChangedYellow = "ms_aic_yellow"
    case settingsAppIconChangedGreen = "ms_aic_green"
    case settingsAppIconChangedBlue = "ms_aic_blue"
    case settingsAppIconChangedPurple = "ms_aic_purple"
    case settingsAppIconChangedBlack = "ms_aic_black"

    case settingsKeyboardShown = "ms_ks"
    case settingsKeyboardNewTabOn = "ms_ks_nt_on"
    case settingsKeyboardNewTabOff = "ms_ks_nt_off"
    case settingsKeyboardAppLaunchOn = "ms_ks_al_on"
    case settingsKeyboardAppLaunchOff = "ms_ks_pl_off"
    
    case settingsUnprotectedSites = "ms_mw"
    case settingsLinkPreviewsOff = "ms_lp_f"
    case settingsLinkPreviewsOn = "ms_lp_n"
    
    case settingsDoNotSellShown = "ms_dns"
    case settingsDoNotSellOn = "ms_dns_on"
    case settingsDoNotSellOff = "ms_dns_off"

    case autoClearSettingsShown = "mac_s"
    case autoClearActionOptionNone = "macwhat_n"
    case autoClearActionOptionTabs = "macwhat_t"
    case autoClearActionOptionTabsAndData = "macwhat_td"
    case autoClearTimingOptionExit = "macwhen_x"
    case autoClearTimingOptionExitOr5Mins = "macwhen_5"
    case autoClearTimingOptionExitOr15Mins = "macwhen_15"
    case autoClearTimingOptionExitOr30Mins = "macwhen_30"
    case autoClearTimingOptionExitOr60Mins = "macwhen_60"

    case browsingMenuOpened = "mb"
    case browsingMenuRefresh = "mb_rf"
    case browsingMenuNewTab = "mb_tb"
    case browsingMenuAddToBookmarks = "mb_abk"
    case browsingMenuAddToFavorites = "mb_af"
    case browsingMenuAddToFavoritesAddFavoriteFlow = "mb_aff"
    case browsingMenuToggleBrowsingMode = "mb_dm"
    case browsingMenuShare = "mb_sh"
    case browsingMenuSettings = "mb_st"
    case browsingMenuFindInPage = "mb_fp"
    case browsingMenuDisableProtection = "mb_wla"
    case browsingMenuEnableProtection = "mb_wlr"
    case browsingMenuReportBrokenSite = "mb_rb"
    case browsingMenuFireproof = "mb_f"
    
    case tabBarBackPressed = "mt_bk"
    case tabBarForwardPressed = "mt_fw"
    case tabBarBookmarksPressed = "mt_bm"
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
    
    case homeRowCTAReminderTapped = "m_hc"
    case homeRowCTAReminderDismissed = "m_hd"
    
    case homeRowInstructionsReplayed = "m_hv"
    
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
    
    case notificationOptIn = "m_ne"
    case notificationOptOut = "m_nd"
    
    case brokenSiteReported = "m_bsr"
    
    case brokenSiteReport = "epbf"

    case preserveLoginsSettingsSwitchOn = "m_pl_s_on"
    case preserveLoginsSettingsSwitchOff = "m_pl_s_off"
    case preserveLoginsSettingsEdit = "m_pl_s_c_e"
    case preserveLoginsSettingsDeleteEditing = "m_pl_s_c_ie"
    case preserveLoginsSettingsDeleteNotEditing = "m_pl_s_c_in"
    case preserveLoginsSettingsClearAll = "m_pl_s_c_a"
    
    case daxDialogsSerp = "m_dx_s"
    case daxDialogsWithoutTrackers = "m_dx_wo"
    case daxDialogsWithTrackers = "m_dx_wt"
    case daxDialogsSiteIsMajor = "m_dx_sm"
    case daxDialogsSiteOwnedByMajor = "m_dx_so"
    case daxDialogsHidden = "m_dx_h"

    case widgetFavoriteLaunch = "m_w_fl"
    case widgetNewSearch = "m_w_ns"
    case widgetAddFavoriteLaunch = "m_w_af"

    case defaultBrowserButtonPressedOnboarding = "m_db_o"
    case defaultBrowserButtonPressedSettings = "m_db_s"
    case defaultBrowserButtonPressedHome = "m_db_h"
    case defaultBrowserHomeMessageShown = "m_db_h_s"
    case defaultBrowserHomeMessageDismissed = "m_db_h_d"

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
    
    case webKitDidTerminate = "m_d_wkt"
    case webKitTerminationDidReloadCurrentTab = "m_d_wktct"

    case settingsAppIconChangeFailed = "m_d_aicf"
    case settingsAppIconChangeNotSupported = "m_d_aicns"

    case backgroundTaskSubmissionFailed = "m_bt_rf"
}

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
    static let appVersion = "appVersion"
    
    static let applicationState = "as"
    static let dataAvailiability = "dp"
    
    static let errorCode = "e"
    static let errorDesc = "d"
    static let errorCount = "c"
    static let underlyingErrorCode = "ue"
    static let underlyingErrorDesc = "ud"

    public static let tabCount = "tc"

    public static let widgetSmall = "ws"
    public static let widgetMedium = "wm"
    public static let widgetLarge = "wl"
    public static let widgetError = "we"
    public static let widgetErrorCode = "ec"
    public static let widgetErrorDomain = "ed"
    public static let widgetUnavailable = "wx"
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
    
    private init() {
    }
    
    public static func fire(pixel: PixelName,
                            forDeviceType deviceType: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom,
                            withAdditionalParameters params: [String: String] = [:],
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders,
                            onComplete: @escaping (Error?) -> Void = {_ in }) {
        
        var newParams = params
        newParams[PixelParameters.appVersion] = AppVersion.shared.versionAndBuildNumber
        if isDebugBuild {
            newParams[PixelParameters.test] = PixelValues.test
        }
        
        let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
        let url = appUrls.pixelUrl(forPixelNamed: pixel.rawValue, formFactor: formFactor)
        
        APIRequest.request(url: url, parameters: newParams, headers: headers, callBackOnMainThread: true) { (_, error) in
            
            os_log("Pixel fired %s %s", log: generalLog, type: .debug, pixel.rawValue, "\(params)")
            onComplete(error)
        }
    }
    
}

extension Pixel {
    
    public static func fire(pixel: PixelName, error: Error, withAdditionalParameters params: [String: String] = [:], isCounted: Bool = false) {
        let nsError = error as NSError
        var newParams = params
        newParams[PixelParameters.errorCode] = "\(nsError.code)"
        newParams[PixelParameters.errorDesc] = nsError.domain
        
        if isCounted {
            let count = PixelCounterStore().incrementCountFor(pixel)
            newParams[PixelParameters.errorCount] = "\(count)"
        }
        
        if let underlyingError = nsError.userInfo["NSUnderlyingError"] as? NSError {
            newParams[PixelParameters.underlyingErrorCode] = "\(underlyingError.code)"
            newParams[PixelParameters.underlyingErrorDesc] = underlyingError.domain
        }
        fire(pixel: pixel, withAdditionalParameters: newParams)
    }
}

public class TimedPixel {
    
    let pixel: PixelName
    let date: Date
    
    public init(_ pixel: PixelName, date: Date = Date()) {
        self.pixel = pixel
        self.date = date
    }
    
    public func fire(_ fireDate: Date = Date(), withAdditionalParmaeters params: [String: String] = [:]) {
        let duration = String(fireDate.timeIntervalSince(date))
        var newParams = params
        newParams[PixelParameters.duration] = duration
        Pixel.fire(pixel: pixel, withAdditionalParameters: newParams)
    }
    
}
