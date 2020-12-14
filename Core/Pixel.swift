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

// swiftlint:disable identifier_name
public enum PixelName: String {
    
    case appLaunch = "ml"
    case defaultBrowserLaunch = "m_dl"
    case navigationDetected = "m_n"
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
    
    case httpsNoLookup = "m_https_nl"
    case httpsLocalUpgrade = "m_https_lu"
    case httpsNoUpgrade = "m_https_nu"
    
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

    case widgetFavoriteLaunch = "m_w_fl"
    case widgetNewSearch = "m_w_ns"
    case widgetAddFavoriteLaunch = "m_w_af"

    case defaultBrowserButtonPressedSettings = "m_db_s"
    case defaultBrowserButtonPressedHome = "m_db_h"
    case defaultBrowserHomeMessageShown = "m_db_h_s"
    case defaultBrowserHomeMessageDismissed = "m_db_h_d"
    
    case widgetsOnboardingCTAPressed = "m_o_w_a"
    case widgetsOnboardingDeclineOptionPressed = "m_o_w_d"
    case widgetsOnboardingMovedToBackground = "m_o_w_b"

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
// swiftlint:enable identifier_name

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
    static let appVersion = "appVersion"
    
    public static let autocompleteBookmarkCapable = "bc"
    public static let autocompleteIncludedLocalResults = "sb"
    
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
