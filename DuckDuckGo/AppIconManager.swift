//
//  AppIconManager.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import os.log

class AppIconManager {

    static var shared = AppIconManager()

    var isAppIconChangeSupported: Bool {
        UIApplication.shared.supportsAlternateIcons
    }
    
    var appIcon: AppIcon {
        guard let appIconName = UIApplication.shared.alternateIconName,
            let appIcon = AppIcon(rawValue: appIconName) else {
             return AppIcon.defaultAppIcon
        }

        return appIcon
    }

    func changeAppIcon(_ appIcon: AppIcon, completionHandler: ((Error?) -> Void)? = nil) {
        let appIconChanger = AppIconChanger()
        appIconChanger.changeAppIcon(appIcon, completionHandler: completionHandler)
    }
    
}
