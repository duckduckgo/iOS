//
//  Simulated.swift
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

import Core
import UIKit

@MainActor
struct Simulated: AppState {

    init() {
        Pixel.isDryRun = true
        _ = DefaultUserAgentManager.shared
        Database.shared.loadStore { _, _ in }
        _ = BookmarksDatabaseSetup().loadStoreAndMigrate(bookmarksDatabase: BookmarksDatabase.make())

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

        let blockingDelegate = BlockingNavigationDelegate()
        let webView = blockingDelegate.prepareWebView()
        window.rootViewController?.view.addSubview(webView)
        window.rootViewController?.view.backgroundColor = .red
        webView.frame = CGRect(x: 10, y: 10, width: 300, height: 300)

        UIApplication.shared.setWindow(window)

        let request = URLRequest(url: URL(string: "about:blank")!)
        webView.load(request)
    }

}

extension Simulated {

    mutating func handle(action: AppAction) { }

}
