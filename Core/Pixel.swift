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
import Alamofire

public enum PixelName: String {
    
    case appLaunch = "ml"

    case forgetAllPressed = "mf_p"
    case forgetAllExecuted = "mf"
    
    case privacyDashboardOpened = "mp"
    case privacyDashboardScorecard = "mp_c"
    case privacyDashboardEncryption = "mp_e"
    case privacyDashboardNetworks = "mp_n"
    case privacyDashboardPrivacyPractices = "mp_p"
    case privacyDashboardGlobalStats = "mp_s"
    case privacyDashboardToggleProtectionOn = "mp_ta"
    case privacyDashboardToggleProtectionOff = "mp_tb"
    
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
    
    case settingsOpened = "ms"
    case settingsHomeRowInstructionsRequested = "ms_hr"
    
    case settingsThemeShown = "ms_tp"
    case settingsThemeChangedSystemDefault = "ms_ts"
    case settingsThemeChangedLight = "ms_tl"
    case settingsThemeChangedDark = "ms_td"

    case settingsHomePageShown = "ms_hp"
    case settingsHomePageSimple = "ms_hp_s"
    case settingsHomePageCenterSearch = "ms_hp_c"
    case settingsHomePageCenterSearchAndFavorites = "ms_hp_f"

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
    case browsingMenuToggleBrowsingMode = "mb_dm"
    case browsingMenuShare = "mb_sh"
    case browsingMenuWhitelist = "mb_wl"
    case browsingMenuReportBrokenSite = "mb_rb"
    case browsingMenuSettings = "mb_st"
    case browsingMenuFindInPage = "mb_fp"

    case tabBarBackPressed = "mt_bk"
    case tabBarForwardPressed = "mt_fw"
    case tabBarBookmarksPressed = "mt_bm"
    case tabBarTabSwitcherPressed = "mt_tb"

    case onboardingShown = "m_o"
    case onboardingSummaryFinished = "m_o_s"
    
    case homeScreenShown = "mh"
    case homeScreenSearchTapped = "mh_st"
    case homeScreenFavouriteLaunched = "mh_fl"
    case homeScreenAddFavorite = "mh_af"
    case homeScreenAddFavoriteOK = "mh_af_o"
    case homeScreenAddFavoriteCancel = "mh_af_c"
    case homeScreenEditFavorite = "mh_ef"
    case homeScreenDeleteFavorite = "mh_df"
    case homeScreenPrivacyStatsTapped = "mh_ps"
    
    case homeRowCTAShowMeTapped = "m_ha"
    case homeRowCTANoThanksTapped = "m_hb"
    
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
    
    case etagStoreOOSWithDisconnectMeFix = "m_d_dcf_oos"
    case etagStoreOOSWithEasylistFix = "m_d_elf_oos"
    
    case dbMigrationError = "m_d_dbme"
    case dbRemovalError = "m_d_dbre"
    case dbDestroyError = "m_d_dbde"
    case dbInitializationError = "m_d_dbie"
    case dbSaveWhitelistError = "m_d_dbsw"
    case dbSaveBloomFilterError = "m_d_dbsb"
    
    case configurationFetchInfo = "m_d_cfgfetch"
    case brokenSiteReported = "m_bsr"
}

public struct PixelParameters {
    public static let url = "url"
    public static let duration = "dur"
    static let test = "test"
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
                            withAdditionalParameters params: [String: String?] = [:],
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders,
                            onComplete: @escaping (Error?) -> Void = {_ in }) {
        
        var newParams = params
        if isDebugBuild {
            newParams[PixelParameters.test] = PixelValues.test
        }
        
        let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
        let url = appUrls
            .pixelUrl(forPixelNamed: pixel.rawValue, formFactor: formFactor)
            .addParams(newParams)
        
        Alamofire.request(url, headers: headers).validate(statusCode: 200..<300).response { response in
            Logger.log(items: "Pixel fired \(pixel.rawValue)")
            onComplete(response.error)
        }
    }
    
}

extension Pixel {
    
    public static func fire(pixel: PixelName, error: Error) {
        let nsError = error as NSError
        
        let params: [String: String?] = ["e": "\(nsError.code)", "d": nsError.domain]
        
        fire(pixel: pixel, withAdditionalParameters: params)
    }
}

public class TimedPixel {
    
    let pixel: PixelName
    let date: Date
    
    public init(_ pixel: PixelName, date: Date = Date()) {
        self.pixel = pixel
        self.date = date
    }
    
    public func fire(_ fireDate: Date = Date()) {
        let duration = String(fireDate.timeIntervalSince(date))
        Pixel.fire(pixel: pixel, withAdditionalParameters: [PixelParameters.duration: duration])
    }
    
}
