//
//  HTTPCookieExtension.swift
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

import WebKit

extension HTTPCookie {

    /// Checks that the `cookieDomain` (provided by a cookie) matches a given domain. e.g.
    /// * cookie domain example.com would match a domain called example.com
    /// * cookie domain `.example.com` would also match a domain called example.com and also any subdomain, e.g. `docs.example.com`
    ///
    /// See `UserDefaultsFireproofingTests` for more examples.
    static func cookieDomain(_ cookieDomain: String, matchesTestDomain testDomain: String) -> Bool {
        return testDomain == cookieDomain
            || ".\(testDomain)" == cookieDomain
            || (cookieDomain.hasPrefix(".") && testDomain.hasSuffix(cookieDomain))
    }

}
