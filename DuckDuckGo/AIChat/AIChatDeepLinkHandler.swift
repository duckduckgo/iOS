//
//  AIChatDeepLinkHandler.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

struct AIChatDeepLinkHandler {

    /// Utilitiy function to handle AI Chat deeplink since it needs to be called from 2 different entry points
    func handleDeepLink(_ url: URL, on mainViewController: MainViewController) {
        firePixel(url)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            mainViewController.openAIChat()
        }
    }

    func firePixel(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Invalid URL")
            return
        }

        let queryItems = components.queryItems
        if let sourceItem = queryItems?.first(where: { $0.name == WidgetSourceType.sourceKey }) {
            switch sourceItem.value {
            case WidgetSourceType.quickActions.rawValue:
                print("A")
            case WidgetSourceType.favorite.rawValue:
                print("B")
            default:
                break
            }
        }
    }
}
