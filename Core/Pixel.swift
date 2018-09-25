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

    case httpsUpgradeSiteError = "ehd"
}

public class Pixel {

    private static let appUrls = AppUrls()
    
    public struct Parameters {
        static let url = "url"
        static let errorCode = "error_code"
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
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders) {
        
        let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
        let url = appUrls
            .pixelUrl(forPixelNamed: pixel.rawValue, formFactor: formFactor)
            .addParams(params)
        
        Alamofire.request(url, headers: headers).response { data in
            Logger.log(items: "Fire pixel \(pixel.rawValue) \(data)")
        }
    
    }
    
}
