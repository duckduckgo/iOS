//
//  MockMaliciousSiteProtectionNavigationHandler.swift
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
@testable import DuckDuckGo

final class MockMaliciousSiteProtectionNavigationHandler: MaliciousSiteProtectionNavigationHandling & SpecialErrorPageActionHandler {
    private(set) var didCallHandleWebViewNavigationAction = false
    private(set) var capturedNavigationAction: WKNavigationAction?

    private(set) var didCallHandleMaliciousSiteProtectionNavigation = false
    private(set) var capturedWebView: WKWebView?

    private(set) var didCallVisitSite = false
    private(set) var capturedVisitSiteURL: URL?
    private(set) var capturedErrorData: SpecialErrorData?

    private(set) var didCallLeaveSite = false

    private(set) var didCallAdvancedInfoPresented = false

    var result: MaliciousSiteProtectionNavigationResult = .navigationNotHandled

    func handleWebView(navigationAction: WKNavigationAction) {
        didCallHandleWebViewNavigationAction = true
        capturedNavigationAction = navigationAction
    }

    func handleMaliciousSiteProtectionNavigation(webView: WKWebView) async -> MaliciousSiteProtectionNavigationResult {
        didCallHandleMaliciousSiteProtectionNavigation = true
        capturedWebView = webView
        return result
    }
    
    func visitSite(url: URL, errorData: SpecialErrorData) {
        didCallVisitSite = true
        capturedVisitSiteURL = url
        capturedErrorData = errorData
    }
    
    func leaveSite() {
        didCallLeaveSite = true
    }
    
    func advancedInfoPresented() {
        didCallAdvancedInfoPresented = true
    }
}
