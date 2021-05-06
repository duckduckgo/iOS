//
//  ReissueSearchPolicy.swift
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

public class ReissueSearchPolicy: NavigationActionPolicy {

    private let isDuckDuckGoSearch: (URL) -> Bool
    private let hasCorrectStatsParams: (URL) -> Bool
    private let hasCorrectSearchHeaderParams: (URL) -> Bool
    private let reissueSearch: (URL) -> Void

    public init(isDuckDuckGoSearch: @escaping (URL) -> Bool,
                hasCorrectStatsParams: @escaping (URL) -> Bool,
                hasCorrectSearchHeaderParams: @escaping (URL) -> Bool,
                reissueSearch: @escaping (URL) -> Void) {

        self.isDuckDuckGoSearch = isDuckDuckGoSearch
        self.hasCorrectStatsParams = hasCorrectStatsParams
        self.hasCorrectSearchHeaderParams = hasCorrectSearchHeaderParams
        self.reissueSearch = reissueSearch
        
    }

    public func check(navigationAction: WKNavigationAction, completion: (WKNavigationActionPolicy, (() -> Void)?) -> Void) {

        if let url = navigationAction.request.url,
           isDuckDuckGoSearch(url),
           (!hasCorrectStatsParams(url) || !hasCorrectSearchHeaderParams(url)) {
            completion(.cancel) {
                self.reissueSearch(url)
            }
        } else {
            completion(.allow, nil)
        }

    }

}
