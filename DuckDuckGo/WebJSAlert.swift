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
        case confirm(handler: (_ confirm: Bool) -> Void, closeTab: () -> Void)
        case text(handler: (_ text: String?) -> Void, defaultText: String?, closeTab: () -> Void)
        case alert(handler: () -> Void, closeTab: () -> Void)
    }

    let domain: String
    let message: String
    private let alertType: JSAlertType
    private var handlerCalled = false

    var text: String? {
        guard case .text(handler: _, defaultText: let defaultText, closeTab: _) = alertType else { return nil }
        return defaultText ?? ""
    }

    var isSimpleAlert: Bool {
        guard case .alert = alertType else { return false }
        return true
    }
    
    init(domain: String, message: String, alertType: WebJSAlert.JSAlertType) {
        self.domain = domain
        self.message = message
        self.alertType = alertType
    }

    func complete(with result: Bool, text: String?) {
        handlerCalled = true

        switch alertType {
        case .confirm(handler: let handler, closeTab: _):
            handler(result)
        case .text(handler: let handler, defaultText: _, closeTab: _):
            handler(text)
        case .alert(handler: let handler, closeTab: _):
            handler()
        }
    }

    func closeTab() {
        switch alertType {
        case .confirm(handler: _, closeTab: let closeTab):
            closeTab()
        case .text(handler: _, defaultText: _, closeTab: let closeTab):
            closeTab()
        case .alert(handler: _, closeTab: let closeTab):
            closeTab()
        }
    }

    deinit {
        if !handlerCalled {
            complete(with: false, text: nil)
        }
    }

}
