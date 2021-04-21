//
//  NewTabPolicy.swift
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
import WebKit

struct NewTabPolicy: NavigationActionPolicy {

    weak var tab: TabViewController?

    func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {
        assert(tab != nil)

        guard let tab = tab else { return }

        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           let modifierFlags = tab.delegate?.tabWillRequestNewTab(tab) {

            completion(.cancel) {
                if modifierFlags.contains(.command) {
                    if modifierFlags.contains(.shift) {
                        tab.delegate?.tab(tab, didRequestNewTabForUrl: url, openedByPage: false)
                    } else {
                        tab.delegate?.tab(tab, didRequestNewBackgroundTabForUrl: url)
                    }
                }
            }
        } else {
            completion(.allow, nil)
        }

    }

}
