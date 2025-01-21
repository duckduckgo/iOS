//
//  SpecialErrorPageContextHandling.swift
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
import WebKit
import SpecialErrorPages

/// A type that defines the base functionality for handling navigation related to special error pages.
protocol SpecialErrorPageContextHandling: SpecialErrorPageThreatProvider {
    /// The delegate that handles navigation actions for special error pages.
    var delegate: SpecialErrorPageNavigationDelegate? { get set }

    /// A Boolean value indicating whether the special error page is currently visible.
    var isSpecialErrorPageVisible: Bool { get }

    /// A boolean value indicating whether the WebView request requires showing a special error page.
    var isSpecialErrorPageRequest: Bool { get }

    /// Attaches a web view to the special error page handling.
    func attachWebView(_ webView: WKWebView)

    /// Sets the user script for the special error page.
    func setUserScript(_ userScript: SpecialErrorPageUserScript?)
}
