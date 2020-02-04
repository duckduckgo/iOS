//
//  PreserveLoginsAlert.swift
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

import Foundation
import Core

class PreserveLoginsAlert {
    
    static func showInitialPromptIfNeeded(usingController controller: UIViewController, completion: @escaping () -> Void) {
        let logins = PreserveLogins.shared
        guard logins.userDecision == .unknown, !logins.detectedDomains.isEmpty else {
            completion()
            return
        }

        let dateShown = Date()
        let prompt = UIAlertController(title: UserText.preserveLoginsTitle,
                                       message: UserText.preserveLoginsMessage,
                                       preferredStyle: .alert)
        prompt.addAction(title: UserText.preserveLoginsRemember) {
            PreserveLogins.shared.userDecision = .preserveLogins
            TimedPixel(.preserveLoginsUserDecisionPreserve, date: dateShown).fire()
            completion()
        }
        prompt.addAction(title: UserText.preserveLoginsForget) {
            PreserveLogins.shared.userDecision = .forgetAll
            TimedPixel(.preserveLoginsUserDecisionForget, date: dateShown).fire()
            completion()
        }
        controller.present(prompt, animated: true)
    }
    
    static func showClearAllAlert(usingController controller: UIViewController, cancelled: @escaping () -> Void, confirmed: @escaping () -> Void) {
        
        if isPad {
            let alert = UIAlertController(title: UserText.preserveLoginsSignOut, message: nil, preferredStyle: .alert)
            alert.addAction(title: "OK", style: .destructive) {
                confirmed()
            }
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                cancelled()
            }
            controller.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: UserText.preserveLoginsSignOut, style: .destructive) {
                confirmed()
            }
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                cancelled()
            }
            controller.present(alert, animated: true)
        }
        
    }
    
}
