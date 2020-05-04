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
  
    static let wwwPrefix = "www."
    
    static func showFireproofToast(usingController controller: UIViewController, forDomain domain: String) {
        controller.view.showBottomToast(UserText.preserveLoginsToast.format(arguments: domain.dropPrefix(prefix: wwwPrefix)))
    }
    
    static func showConfirmFireproofWebsite(usingController controller: UIViewController,
                                            forDomain domain: String,
                                            onConfirmHandler: @escaping () -> Void) {
        let prompt = UIAlertController(title: nil,
                                       message: UserText.preserveLoginsFireproofAsk.format(arguments: domain.dropPrefix(prefix: wwwPrefix)),
                                       preferredStyle: isPad ? .alert : .actionSheet)
        prompt.addAction(title: UserText.preserveLoginsFireproofConfirm, style: .default) {
            onConfirmHandler()
        }
        prompt.addAction(title: UserText.actionCancel, style: .cancel)
        controller.present(prompt, animated: true)
    }
    
    static func showFireproofWebsitePrompt(usingController controller: UIViewController,
                                           forDomain domain: String,
                                           onConfirmHandler: @escaping () -> Void) {
        let prompt = UIAlertController(title: nil,
                                       message: UserText.preserveLoginsFireproofAsk.format(arguments: domain.dropPrefix(prefix: wwwPrefix)),
                                       preferredStyle: isPad ? .alert : .actionSheet)
        prompt.addAction(title: UserText.preserveLoginsFireproofConfirm) {
            onConfirmHandler()
        }
        prompt.addAction(title: UserText.preserveLoginsFireproofDefer, style: .cancel)
        controller.present(prompt, animated: true)
    }
    
    static func showClearAllAlert(usingController controller: UIViewController, cancelled: @escaping () -> Void, confirmed: @escaping () -> Void) {
        
        if isPad {
            let alert = UIAlertController(title: UserText.preserveLoginsRemoveAll, message: nil, preferredStyle: .alert)
            alert.addAction(title: UserText.preserveLoginsRemoveAllOk, style: .destructive) {
                confirmed()
            }
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                cancelled()
            }
            controller.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: UserText.preserveLoginsRemoveAll, style: .destructive) {
                confirmed()
            }
            alert.addAction(title: UserText.actionCancel, style: .cancel) {
                cancelled()
            }
            controller.present(alert, animated: true)
        }
        
    }
    
}
