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

    lazy var content: [DialogContentItem] = [.text(text: UserText.daxDialogCookieConsentFirst),
                                             .animation(name: cookieBannerAnimationName, delay: 0.35),
                                             .text(text: UserText.daxDialogCookieConsentSecond)]
    
    lazy var buttons: [DialogButtonItem] = [.bordered(label: UserText.daxDialogCookieConsentAcceptButton, action: self.okAction),
                                            .borderless(label: UserText.daxDialogCookieConsentRejectButton, action: self.noAction)]
    
    private var cookieBannerAnimationName: String {
        let useLightStyle = ThemeManager.shared.currentTheme.currentImageSet == .light
        return useLightStyle ? "cookie-banner-illustration-animated" : "cookie-banner-illustration-animated-dark"
    }
}
