//
//  UIAlertControllerExtension.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

extension UIAlertController {

    static func makeDeviceAuthenticationAlert(completion: @escaping () -> Void) -> UIAlertController {

        let deviceType: String

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            deviceType = UserText.deviceTypeiPad
        case .phone:
            deviceType = UserText.deviceTypeiPhone
        default:
            deviceType = UserText.deviceTypeDefault
        }

        let alertController = UIAlertController(
            title: UserText.credentialProviderNoDeviceAuthSetTitle,
            message: String(format: UserText.credentialProviderNoDeviceAuthSetMessage, deviceType),
            preferredStyle: .alert
        )

        let closeButton = UIAlertAction(title: UserText.actionClose, style: .default) { _ in
            completion()
        }

        alertController.addAction(closeButton)
        return alertController
    }

}
