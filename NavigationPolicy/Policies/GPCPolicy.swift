//
//  GPCPolicy.swift
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

public class GPCPolicy: NavigationActionPolicy {

    static let secGPCHeader = "Sec-GPC"

    static let gpcEnabledDomains = [
        "global-privacy-control.glitch.me",
        "washingtonpost.com",
        "nytimes.com"
    ]

    private let gpcEnabled: Bool
    private let load: (URLRequest) -> Void

    public init(gpcEnabled: Bool, load: @escaping (URLRequest) -> Void) {
        self.gpcEnabled = gpcEnabled
        self.load = load
    }

    public func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {
        if navigationAction.targetFrame?.isMainFrame ?? false,
           ["http", "https"].contains(navigationAction.request.url?.scheme),
           navigationAction.navigationType != .backForward,
           let request = requestForDoNotSell(basedOn: navigationAction.request) {

            completion(.cancel) {
                self.load(request)
            }
            return
        }

        completion(.allow, nil)
    }

    private func requestForDoNotSell(basedOn incomingRequest: URLRequest) -> URLRequest? {
        /*
         For now, the GPC header is only applied to sites known to be honoring GPC (nytimes.com, washingtonpost.com),
         while the DOM signal is available to all websites.
         This is done to avoid an issue with back navigation when adding the header (e.g. with 't.co').
         */
        guard let url = incomingRequest.url, isGPCEnabledFor(url) else { return nil }

        var request = incomingRequest
        if gpcEnabled {
            if let headers = request.allHTTPHeaderFields,
               headers.firstIndex(where: { $0.key == Self.secGPCHeader }) == nil {
                request.addValue("1", forHTTPHeaderField: Self.secGPCHeader)
                return request
            }
        } else {
            if let headers = request.allHTTPHeaderFields, headers.firstIndex(where: { $0.key == Self.secGPCHeader }) != nil {
                request.setValue(nil, forHTTPHeaderField: Self.secGPCHeader)
                return request
            }
        }
        return nil
    }

    private func isGPCEnabledFor(_ url: URL) -> Bool {
        guard let navigationDomain = url.host else { return false }
        let urls = Self.gpcEnabledDomains.compactMap { URL(string: "https://\($0)") }
        return urls.contains(where: {
            guard let domain = $0.host else { return false }
            return navigationDomain == domain || domain.hasSuffix(".\(domain)")
        })
    }

}
