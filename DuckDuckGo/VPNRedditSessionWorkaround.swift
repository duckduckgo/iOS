//
//  VPNRedditSessionWorkaround.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import NetworkProtection
import Subscription
import WebKit

final class VPNRedditSessionWorkaround {

    private let accountManager: AccountManaging
    private let tunnelController: TunnelController

    init(accountManager: AccountManaging, tunnelController: TunnelController) {
        self.accountManager = accountManager
        self.tunnelController = tunnelController
    }

    @MainActor
    func installRedditSessionWorkaround() async {
        let configuration = WKWebViewConfiguration.persistent()
        await installRedditSessionWorkaround(to: configuration.websiteDataStore.httpCookieStore)
    }

    @MainActor
    func installRedditSessionWorkaround(to cookieStore: WKHTTPCookieStore) async {
        guard accountManager.isUserAuthenticated,
              await tunnelController.isConnected,
            let redditSessionCookie = HTTPCookie.emptyRedditSession else {
            return
        }

        let cookies = await cookieStore.allCookies()
        var requiresRedditSessionCookie = true
        for cookie in cookies {
            if cookie.domain == redditSessionCookie.domain, cookie.name == redditSessionCookie.name, !cookie.value.isEmpty {
                requiresRedditSessionCookie = false
                break
            }
        }

        if requiresRedditSessionCookie {
            await cookieStore.setCookie(redditSessionCookie)
            print("SAMDEBUG: Added reddit session cookie")
        }
    }

    func removeRedditWorkaround(from cookieStore: WKHTTPCookieStore) async {
        guard let redditSessionCookie = HTTPCookie.emptyRedditSession else {
            return
        }

        let cookies = await cookieStore.allCookies()
        for cookie in cookies {
            if cookie.domain == redditSessionCookie.domain, cookie.name == redditSessionCookie.name {
                if cookie.value == redditSessionCookie.value {
                    await cookieStore.deleteCookie(cookie)
                    print("SAMDEBUG: Deleted reddit session cookie")
                }

                break
            }
        }
    }

}

private extension HTTPCookie {

    static var emptyRedditSession: HTTPCookie? {
        return HTTPCookie(properties: [
            .domain: ".reddit.com",
            .path: "/",
            .name: "reddit_session",
            .value: "",
            .secure: "TRUE"
        ])
    }

}
