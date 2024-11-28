//
//  AIChatModel.swift
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

final class AIChatModel {
    private var cleanupTimerCancellable: AnyCancellable?

    let webViewConfiguration: WKWebViewConfiguration
    let cleanupPublisher = PassthroughSubject<Void, Never>()

    init(webViewConfiguration: WKWebViewConfiguration) {
        self.webViewConfiguration = webViewConfiguration
    }

    func cancelTimer() {
        cleanupTimerCancellable?.cancel()
    }

    func startCleanupTimer() {
        print("Start timer")
        cancelTimer()

        cleanupTimerCancellable = Just(())
            .delay(for: .seconds(5), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.cleanupPublisher.send()
            }
    }
}
