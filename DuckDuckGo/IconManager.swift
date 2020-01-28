//
//  IconManager.swift
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

class IconManager {

    static var shared = IconManager()

    var isIconChangeSupported: Bool {
        if #available(iOS 10.3, *) {
            return UIApplication.shared.supportsAlternateIcons
        } else {
            return false
        }
    }

    enum IconManagerError: Error {
        case changeNotSupported
    }

    func changeApplicationIcon(_ icon: Icon, completionHandler: ((Error?) -> Void)? = nil) {
        if applicationIcon == icon {
            completionHandler?(nil)
            return
        }

        if #available(iOS 10.3, *), isIconChangeSupported {
            let alternateIconName = icon != Icon.defaultIcon ? icon.rawValue : nil
            UIApplication.shared.setAlternateIconName(alternateIconName) { error in
                if let error = error {
                    Pixel.fire(pixel: .settingsIconChangeFailed, error: error)
                    Logger.log(text: "Error while changing icon: \(error.localizedDescription)")
                    completionHandler?(error)
                } else {
                    completionHandler?(nil)
                }
            }
        } else {
            let error = IconManagerError.changeNotSupported
            Pixel.fire(pixel: .settingsIconChangeNotSupported, error: error)
            Logger.log(text: "Error while changing icon: \(error.localizedDescription)")
            completionHandler?(error)
        }
    }

    var applicationIcon: Icon {
        if #available(iOS 10.3, *) {
            guard let iconName = UIApplication.shared.alternateIconName,
                let icon = Icon(rawValue: iconName) else {
                return Icon.defaultIcon
            }

            return icon
        } else {
            return Icon.defaultIcon
        }
    }

}
