//
//  AIChatViewModel.swift
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
import Combine
import os.log

protocol AIChatViewModeling {
    /// The URL to be loaded in the AI Chat View Controller's web view.
    var aiChatURL: URL { get }

    /// The configuration settings for the web view used in the AI Chat.
    /// This configuration can include preferences such as data storage
    var webViewConfiguration: WKWebViewConfiguration { get }
}

final class AIChatViewModel: AIChatViewModeling {
    private let settings: AIChatSettingsProvider
    let webViewConfiguration: WKWebViewConfiguration

    init(webViewConfiguration: WKWebViewConfiguration, settings: AIChatSettingsProvider) {
        self.webViewConfiguration = webViewConfiguration
        self.settings = settings
    }

    var aiChatURL: URL {
        settings.aiChatURL
    }
}