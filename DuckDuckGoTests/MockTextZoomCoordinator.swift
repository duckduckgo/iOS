//
//  MockTextZoomCoordinator.swift
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
@testable import DuckDuckGo
import Core
import WebKit

class MockTextZoomCoordinator: TextZoomCoordinating {

    let isEnabled: Bool = true

    func textZoomLevel(forHost host: String?) -> TextZoomLevel {
        return .percent100
    }
    
    func set(textZoomLevel level: DuckDuckGo.TextZoomLevel, forHost host: String?) {
    }
    
    func onWebViewCreated(applyToWebView webView: WKWebView) {
    }
    
    func onNavigationCommitted(applyToWebView webView: WKWebView) {
    }
    
    func onTextZoomChange(applyToWebView webView: WKWebView) {
    }
    
    func showTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView) {
    }
    
    func makeBrowsingMenuEntry(forLink: Link, inController controller: UIViewController, forWebView webView: WKWebView) -> BrowsingMenuEntry? {
        return nil
    }

    func resetTextZoomLevels(excludingDomains: [String]) {
    }

}
