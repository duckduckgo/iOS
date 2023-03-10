//
//  AppURLs.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

public extension URL {

    private static let base: String = ProcessInfo.processInfo.environment["BASE_URL", default: "https://duckduckgo.com"]
    private static let staticBase: String = "https://staticcdn.duckduckgo.com"

    static let ddg = URL(string: URL.base)!

    static let autocomplete = URL(string: "\(base)/ac/")!
    static let emailProtection = URL(string: "\(base)/email")!
    static let emailProtectionQuickLink = URL(string: "ddgQuickLink://\(base)/email")!

    static let surrogates = URL(string: "\(staticBase)/surrogates.txt")!
    static let privacyConfig = URL(string: "\(staticBase)/trackerblocking/config/v2/ios-config.json")!
    static let trackerDataSet = URL(string: "\(staticBase)/trackerblocking/v3/apple-tds.json")!
    static let bloomFilter = URL(string: "\(staticBase)/https/https-mobile-v2-bloom.bin")!
    static let bloomFilterSpec = URL(string: "\(staticBase)/https/https-mobile-v2-bloom-spec.json")!
    static let bloomFilterExcludedDomains = URL(string: "\(staticBase)/https/https-mobile-v2-false-positives.json")!

    private static var devMode: String { isDebugBuild ? "?test=1" : "" }
    static let atb = URL(string: "\(base)/atb.js\(devMode)")!
    static let exti = URL(string: "\(base)/exti/\(devMode)")!
    static let feedback = URL(string: "\(base)/feedback.js?type=app-feedback")!

    static let appStore = URL(string: "https://apps.apple.com/app/duckduckgo-privacy-browser/id663592361")!

    static let mac = URL(string: "\(base)/mac")!
    static let windows = URL(string: "\(base)/windows")!

    static func exti(forAtb atb: String) -> URL { URL.exti.appendingParameter(name: Param.atb, value: atb) }

    static func makeAutocomplete(for text: String) throws -> URL {
        URL.autocomplete.appendingParameters([
            Param.search: text,
            Param.enableNavSuggestions: ParamValue.enableNavSuggestions
        ])
    }

    static func isDuckDuckGo(domain: String?) -> Bool {
        guard let domain = domain, let url = URL(string: "https://\(domain)") else { return false }
        return url.isDuckDuckGo
    }

    var isDuckDuckGo: Bool { isPart(ofDomain: URL.ddg.host!) }

    var isDuckDuckGoStatic: Bool {
        let staticPaths = ["/settings", "/params"]
        guard isDuckDuckGo, staticPaths.contains(path) else { return false }
        return true
    }

    var isDuckDuckGoSearch: Bool {
        guard isDuckDuckGo, getParameter(named: Param.search) != nil else { return false }
        return true
    }

    var isDuckDuckGoEmailProtection: Bool { absoluteString.starts(with: URL.emailProtection.absoluteString) }

    var searchQuery: String? {
        guard isDuckDuckGo else { return nil }
        return getParameter(named: Param.search)
    }

    enum Param {

        static let search = "q"
        static let source = "t"
        static let atb = "atb"
        static let setAtb = "set_atb"
        static let activityType = "at"
        static let partialHost = "pv1"
        static let searchHeader = "ko"
        static let vertical = "ia"
        static let verticalRewrite = "iar"
        static let verticalMaps = "iaxm"
        static let enableNavSuggestions = "is_nav"
        static let email = "email"

    }

    enum ParamValue {

        static let source = "ddg_ios"
        static let appUsage = "app_use"
        static let searchHeader = "-1"
        static let enableNavSuggestions = "1"
        static let emailEnabled = "1"
        static let emailDisabled = "0"
        static let majorVerticals: Set<String> = ["images", "videos", "news"]

    }

    func applyingSearchHeaderParams() -> URL {
        removingParameters(named: [Param.searchHeader]).appendingParameter(name: Param.searchHeader, value: ParamValue.searchHeader)
    }

    var hasCorrectSearchHeaderParams: Bool {
        guard let header = getParameter(named: Param.searchHeader) else { return false }
        return header == ParamValue.searchHeader
    }

    func removingInternalSearchParameters() -> URL {
        guard isDuckDuckGoSearch else { return self }
        return removingParameters(named: [Param.atb, Param.source, Param.searchHeader])
    }

}
