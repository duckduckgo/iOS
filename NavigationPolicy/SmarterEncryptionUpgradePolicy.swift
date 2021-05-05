//
//  SmarterEncryptionUpgradePolicy.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
///Users/brindy/Projects/DuckDuckGo/iOS/NavigationPolicy/OpenInExternalAppPolicy.swift
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

public class SmarterEncryptionUpgradePolicy: NavigationActionPolicy {

    private let isProtected: (String?) -> Bool
    private let isUpgradeable: (URL, (Bool) -> Void) -> Void
    private let upgrade: (URL) -> Void

    public init(isProtected: @escaping (String?) -> Bool, isUpgradeable: @escaping (URL, (Bool) -> Void) -> Void, upgrade: @escaping (URL) -> Void) {
        self.isProtected = isProtected
        self.isUpgradeable = isUpgradeable
        self.upgrade = upgrade
    }

    public func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        guard let url = navigationAction.request.url,
              !isProtected(url.host) else {
            completion(.allow, nil)
            return
        }

        isUpgradeable(url) { isUpgradable in
            if isUpgradable {
                completion(.cancel) {
                    self.upgrade(url)
                }
            } else {
                completion(.allow, nil)
            }
        }

    }

}
