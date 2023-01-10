//
//  CookieConsentDaxDialogModel.swift
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

final class CookieConsentDaxDialogModel: CustomDaxDialogModel {
    
    var okAction: () -> Void
    var noAction: () -> Void
    
    init(okAction: @escaping () -> Void, noAction: @escaping () -> Void) {
        self.okAction = okAction
        self.noAction = noAction
    }

    #warning("move strings to UserText and use light/dark variants for animation")
    lazy var content: [DialogContentItem] = [.text(text: "Looks like this site has a cookie consent pop-up👇"),
                                             .animation(name: "cookie-banner-illustration-animated", delay: 0.35),
                                             .text(text: "Want me to handle these for you? I can try to minimize cookies, maximize privacy, and hide pop-ups like these.")]
    
    lazy var buttons: [DialogButtonItem] = [.bordered(label: "Manage Cookie Pop-ups", action: self.okAction),
                                            .borderless(label: "No Thanks", action: self.noAction)]
}
