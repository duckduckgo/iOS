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

    /// A publisher that emits a signal after a 10-minute interval.
    /// This is used to notify the controller that it should perform a reload or cleanup operation,
    var cleanupPublisher: PassthroughSubject<Void, Never> { get }

    /// Cancels the currently active cleanup timer.
    func cancelTimer()

    /// Initiates the cleanup timer, which is set to trigger after a specified duration.
    /// The purpose of this timer is to clear previous chat conversations
    func startCleanupTimer()
}


final class AIChatViewModel: AIChatViewModeling {
    private let remoteSettings: AIChatRemoteSettingsProvider
    private var cleanupTimerCancellable: AnyCancellable?

    let webViewConfiguration: WKWebViewConfiguration
    let cleanupPublisher = PassthroughSubject<Void, Never>()

    let cleanupTime: TimeInterval

    init(webViewConfiguration: WKWebViewConfiguration, remoteSettings: AIChatRemoteSettingsProvider, cleanupTime: TimeInterval = 5) {
        self.cleanupTime = cleanupTime
        self.webViewConfiguration = webViewConfiguration
        self.remoteSettings = remoteSettings
    }

    func cancelTimer() {
        Logger.aiChat.debug("Cancelling cleanup timer")
        cleanupTimerCancellable?.cancel()
    }

    func startCleanupTimer() {
        cancelTimer()

        Logger.aiChat.debug("Starting cleanup timer")

        cleanupTimerCancellable = Just(())
            .delay(for: .seconds(cleanupTime), scheduler: RunLoop.main)
            .sink { [weak self] in
                Logger.aiChat.debug("Cleanup timer done")
                self?.cleanupPublisher.send()
            }
    }

    var aiChatURL: URL {
        remoteSettings.aiChatURL
    }
}
