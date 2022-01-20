//
//  WebJSAlert.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

struct WebJSAlert {
    enum JSAlertType {
        case confirm(handler: (_ suppress: Bool, _ confirm: Bool) -> Void)
        case text(handler: (_ suppress: Bool, _ text: String?) -> Void, defaultText: String?)
        case alert(handler: (_ suppress: Bool) -> Void)
    }
    
    private let message: String
    private let alertType: JSAlertType
    
    init(message: String, alertType: WebJSAlert.JSAlertType) {
        self.message = message
        self.alertType = alertType
    }
    
    func createAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        switch alertType {
            
        case .confirm(let handler):
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertOKButton,
                                                    style: .default, handler: { _ in
                handler(false, true)
            }))
            
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertCancelButton,
                                                    style: .default, handler: { _ in
                handler(false, false)
            }))
            
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertDisableAlertsButton,
                                                    style: .destructive, handler: { _ in
                handler(true, false)
            }))
            return alertController
            
        case .alert(let handler):
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertOKButton,
                                                    style: .default, handler: { _ in
                handler(false)
            }))
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertDisableAlertsButton,
                                                    style: .destructive, handler: { _ in
                handler(true)
            }))
            return alertController
            
        case .text(let handler, let defaultText):
            alertController.addTextField { textField in
                textField.text = defaultText
            }
            
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertOKButton,
                                                    style: .default, handler: { [weak alertController] _ in
                handler(false, alertController?.textFields?.first?.text)
                
            }))
            
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertCancelButton,
                                                    style: .default, handler: { _ in
                handler(false, nil)
            }))
            
            alertController.addAction(UIAlertAction(title: UserText.webJSAlertDisableAlertsButton,
                                                    style: .destructive, handler: { _ in
                handler(true, nil)
            }))
            
            return alertController
        }
    }
}
