//
//  SmarterEncryptionUpgradePolicy.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
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

    private let lastUpgradedURL: URL?
    private let isProtected: (String?) -> Bool
    private let isUpgradeable: (URL, @escaping (Bool) -> Void) -> Void
    private let upgradeWith: (URL) -> Void

    public init(lastUpgradedURL: URL?,
                isProtected: @escaping (String?) -> Bool,
                isUpgradeable: @escaping (URL, @escaping (Bool) -> Void) -> Void,
                upgradeWith: @escaping (URL) -> Void) {

        self.lastUpgradedURL = lastUpgradedURL
        self.isProtected = isProtected
        self.isUpgradeable = isUpgradeable
        self.upgradeWith = upgradeWith

    }

    public func check(navigationAction: WKNavigationAction, completion: @escaping (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        guard let url = navigationAction.request.url,
              navigationAction.targetFrame?.isMainFrame ?? false,
              !isProtected(url.host) else {
            completion(.allow, nil)
            return
        }

        // assumption is that this always completes
        isUpgradeable(url) { isUpgradeable in
            guard isUpgradeable else {
                completion(.allow, nil)
                return
            }

            completion(.cancel) {
                if let upgradedUrl = url.toHttps() {
                    self.upgradeWith(upgradedUrl)
                }
            }
        }
    }

}

fileprivate extension URL {

    func toHttps() -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard components.scheme == "http" else { return self }
        components.scheme = "https"
        return components.url
    }

}
