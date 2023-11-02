//
//  CriticalAlerts.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import UIKit
import Core

struct CriticalAlerts {

    static func makePreemptiveCrashAlert() -> UIAlertController {
        let alertController = UIAlertController(title: UserText.preemptiveCrashTitle,
                                                message: UserText.preemptiveCrashBody,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle()

        let crashButton = UIAlertAction(title: UserText.preemptiveCrashAction, style: .default) { _ in
            fatalError("App is in unrecoverable state")
        }

        alertController.addAction(crashButton)
        return alertController
    }

    static func makeInsufficientDiskSpaceAlert() -> UIAlertController {
        let alertController = UIAlertController(title: UserText.insufficientDiskSpaceTitle,
                                                message: UserText.insufficientDiskSpaceBody,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle()

        let openSettingsButton = UIAlertAction(title: UserText.insufficientDiskSpaceAction, style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url, options: [:]) { _ in
                fatalError("App is in unrecoverable state")
            }
        }

        alertController.addAction(openSettingsButton)
        return alertController
    }

    static func makeEmailProtectionSignInAlert() -> UIAlertController {
        let alertController = UIAlertController(title: UserText.emailProtectionSignInTitle,
                                                message: UserText.emailProtectionSignInBody,
                                                preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle()

        let closeButton = UIAlertAction(title: UserText.keyCommandClose, style: .cancel)
        let signInButton = UIAlertAction(title: UserText.emailProtectionSignInAction, style: .default) { _ in
            UIApplication.shared.open(URL.emailProtectionQuickLink, options: [:], completionHandler: nil)
        }

        alertController.addAction(closeButton)
        alertController.addAction(signInButton)
        return alertController
    }

}
