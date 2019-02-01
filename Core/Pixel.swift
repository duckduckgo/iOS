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
    case forgetAllExecuted = "mf"
    
    case privacyDashboardOpened = "mp"
    case privacyDashboardScorecard = "mp_c"
    case privacyDashboardEncryption = "mp_e"
    case privacyDashboardNetworks = "mp_n"
    case privacyDashboardPrivacyPractices = "mp_p"
    case privacyDashboardGlobalStats = "mp_s"
    
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
    case settingsThemeToggledLight = "ms_tl"
    case settingsThemeToggledDark = "ms_td"
    
    case autoClearSettingsShown = "mac_s"
    case autoClearActionOptionNone = "macwhat_n"
    case autoClearActionOptionTabs = "macwhat_t"
    case autoClearActionOptionTabsAndData = "macwhat_td"
    case autoClearTimingOptionExit = "macwhen_x"
    case autoClearTimingOptionExitOr5Mins = "macwhen_5"
    case autoClearTimingOptionExitOr15Mins = "macwhen_15"
    case autoClearTimingOptionExitOr30Mins = "macwhen_30"
    case autoClearTimingOptionExitOr60Mins = "macwhen_60"

    case httpsUpgradeSiteError = "ehd"
    case httpsUpgradeSiteSummary = "ehs"

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

    case tabBarBackPressed = "mt_bk"
    case tabBarForwardPressed = "mt_fw"
    case tabBarBookmarksPressed = "mt_bm"
    case tabBarTabSwitcherPressed = "mt_tb"

    case homeScreenShown = "mh"
    case homeScreenSearchTapped = "mh_st"
    case homeScreenFavoriteLaunched = "mh_fl"
    case homeScreenAddFavorite = "mh_af"
    case homeScreenAddFavoriteOk = "mh_af_o"
    case homeScreenAddFavoriteCancel = "mh_af_c"
    case homeScreenEditFavorite = "mh_ef"
    case homeScreenDeleteFavorite = "mh_df"
    case homeScreenFavoriteMoved = "mh_fm"
    
}

public class Pixel {

    private static let appUrls = AppUrls()
    
    public struct EhdParameters {
        public static let url = "url"
        public static let errorCode = "error_code"
    }
    
    public struct EhsParameters {
        public static let totalCount = "total"
        public static let failureCount = "failures"
    }
    
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
        
        let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
        let url = appUrls
            .pixelUrl(forPixelNamed: pixel.rawValue, formFactor: formFactor)
            .addParams(params)
        
        Alamofire.request(url, headers: headers).validate(statusCode: 200..<300).response { response in
            Logger.log(items: "Pixel fired \(pixel.rawValue) \(response)")
            onComplete(response.error)
        }
    }
}
