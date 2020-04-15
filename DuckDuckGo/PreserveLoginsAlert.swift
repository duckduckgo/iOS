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

    static func showDisableLoginDetectionPrompt(usingController controller: UIViewController) {
        let prompt = UIAlertController(title: "Disable Sign In Detection?",
                                       message: "You can change this in settings",
                                       preferredStyle: isPad ? .alert : .actionSheet)
        prompt.addAction(title: "Yes", style: .default)
        prompt.addAction(title: "No", style: .cancel)
        controller.present(prompt, animated: true)
    }
    
    static func showFireproofToast(usingController controller: UIViewController, forDomain domain: String) {
        controller.view.showBottomToast("'\(domain)' has been fireproofed")
    }
    
    static func showConfirmFireproofWebsite(usingController controller: UIViewController, onConfirmHandler: @escaping () -> Void) {
        let prompt = UIAlertController(title: nil,
                                       message: UserText.preserverLoginsFireproofWebsiteMessage,
                                       preferredStyle: isPad ? .alert : .actionSheet)
        prompt.addAction(title: UserText.preserveLoginsMenuTitle, style: .default) {
            onConfirmHandler()
        }
        prompt.addAction(title: UserText.actionCancel, style: .cancel)
        controller.present(prompt, animated: true)
    }
    
    static func showFireproofWebsitePrompt(usingController controller: UIViewController,
                                           onConfirmHandler: @escaping () -> Void,
                                           onCancelHandler: @escaping () -> Void) {
        let prompt = UIAlertController(title: "Stay signed in to websites?",
                                       message: "The Fire Button can protect this website's cookies for convenience (by default, we destroy them).",
                                       preferredStyle: isPad ? .alert : .actionSheet)
        prompt.addAction(title: "Yes - This website only") {
            onConfirmHandler()
        }
        prompt.addAction(title: "Yes - All websites") {
            onCancelHandler()
        }
        prompt.addAction(title: "Not now") {
            onCancelHandler()
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
