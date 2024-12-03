//
//  RootDebugViewController+VanillaBrowser.swift
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
import BareBonesBrowserKit
import SwiftUI
import WebKit
import Core
import Common
import os.log

extension RootDebugViewController {

    fileprivate static let ddgURL = URL(string: "https://duckduckgo.com/")!
    @objc func openVanillaBrowser(_ sender: Any?) {
        let homeURL = tabManager.current()?.tabModel.link?.url ?? RootDebugViewController.ddgURL
        openVanillaBrowser(url: homeURL)
    }

    static var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        configuration.processPool = WKProcessPool()
        return configuration
    }()

    fileprivate func openVanillaBrowser(url: URL) {
        Logger.lifecycle.debug("Vanilla Browser open URL \(url.absoluteString)")
        let browserView = BareBonesBrowserView(initialURL: url,
                                               homeURL: RootDebugViewController.ddgURL,
                                               uiDelegate: nil,
                                               configuration: Self.webViewConfiguration,
                                               userAgent: DefaultUserAgentManager.duckDuckGoUserAgent)
        present(controller: UIHostingController(rootView: browserView), fromView: self.view)
    }
}
