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
                            withHeaders headers: HTTPHeaders = APIHeaders().defaultHeaders) {
        let formFactor = deviceType == .pad ? Constants.tablet : Constants.phone
        Alamofire.request(appUrls.pixelUrl(forPixelNamed: pixel.rawValue, formFactor: formFactor),
                          headers: headers).response { data in
            Logger.log(items: "Fire pixel \(pixel.rawValue) \(data)")
        }
    }
    
}
