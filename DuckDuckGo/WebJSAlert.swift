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

import Foundation
import Core

class WebJSAlert {

    enum JSAlertType {
        case confirm(handler: (_ blockAlerts: Bool, _ confirm: Bool) -> Void)
        case text(handler: (_ blockAlerts: Bool, _ text: String?) -> Void, defaultText: String?)
        case alert(handler: (_ blockAlerts: Bool) -> Void)
    }
    
    let message: String
    private let alertType: JSAlertType
    private var handlerCalled = false

    var text: String? {
        guard case .text(handler: _, defaultText: let defaultText) = alertType else { return nil }
        return defaultText ?? ""
    }

    var isConfirm: Bool {
        guard case .confirm = alertType else { return false }
        return true
    }
    
    init(message: String, alertType: WebJSAlert.JSAlertType) {
        self.message = message
        self.alertType = alertType
    }

    func complete(with result: Bool, blockAlerts: Bool, text: String?) {
        handlerCalled = true

        switch alertType {
        case .confirm(handler: let handler):
            handler(blockAlerts, result)
        case .text(handler: let handler, defaultText: _):
            handler(blockAlerts, text)
        case .alert(handler: let handler):
            handler(blockAlerts)
        }
    }

    deinit {
        if !handlerCalled {
            complete(with: false, blockAlerts: false, text: nil)
        }
    }

}
