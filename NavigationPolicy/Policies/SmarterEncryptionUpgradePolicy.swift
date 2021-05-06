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
    private let upgrade: (URL) -> Void

    public init(lastUpgradedURL: URL?,
                isProtected: @escaping (String?) -> Bool,
                isUpgradeable: @escaping (URL, @escaping (Bool) -> Void) -> Void,
                upgrade: @escaping (URL) -> Void) {

        self.lastUpgradedURL = lastUpgradedURL
        self.isProtected = isProtected
        self.isUpgradeable = isUpgradeable
        self.upgrade = upgrade

    }

    public func check(navigationAction: WKNavigationAction, completion: @escaping (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        guard let url = navigationAction.request.url,
              !isProtected(url.host) else {
            completion(.allow, nil)
            return
        }

        isUpgradeable(url) { isUpgradeable in

            if isUpgradeable {
                completion(.cancel) {

                }
            }

        }

//        isUpgradeable(url) { isUpgradable in
//            if isUpgradable {
//                completion(.cancel) {
//                    self.upgrade(url)
//                }
//            } else {
//                completion(.allow, nil)
//            }
//        }
        //
        //    private func upgradeUrl(_ url: URL, navigationAction: WKNavigationAction) -> URL? {
        //        guard !failingUrls.contains(url.host ?? ""), navigationAction.isTargetingMainFrame() else { return nil }
        //
        //        if let upgradedUrl: URL = url.toHttps(), lastUpgradedURL != upgradedUrl {
        //            return upgradedUrl
        //        }
        //
        //        return nil
        //    }


    }

}
