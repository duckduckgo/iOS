//
//  NoMicPermissionAlert.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

struct NoMicPermissionAlert {
    
    static func buildAlert() -> UIAlertController {
        let alertController = UIAlertController(title: UserText.noVoicePermissionAlertTitle,
                                                message: UserText.noVoicePermissionAlertMessage,
                                                preferredStyle: .alert)

        let openSettingsButton = UIAlertAction(title: UserText.noVoicePermissionActionSettings, style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: UserText.actionCancel, style: .cancel, handler: nil)

        alertController.addAction(openSettingsButton)
        alertController.addAction(cancelAction)
        return alertController
    }
}
