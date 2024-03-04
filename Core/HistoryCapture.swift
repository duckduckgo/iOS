//
//  HistoryCapture.swift
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

public class HistoryCapture {

    enum NavigationState {

        case none
        case navigating
        case idle
        case error
        case subFrame

    }

    let historyManager: HistoryManaging

    var navigationState = NavigationState.none
    var url: URL?

    public init(historyManager: HistoryManaging) {
        self.historyManager = historyManager
    }

    public func urlDidChange(_ url: URL?) {
        print("***", #function, url?.absoluteString ?? "nil", navigationState)
        self.url = url

        // Only add visits when the url changes if we've navigated at least once and are now idle
        guard navigationState == .idle else { return }
        addVisit()
    }

    public func webViewDidCommit() {
        print("***", #function)
        navigationState = .navigating
    }

    public func webViewDidReceiveServerRedirect() {
        print("***", #function)
    }

    public func webViewRequestedPolicyDecisionForNavigationResponse() {
        print("***", #function)
    }

    public func webViewRequestedPolicyDecisionForNavigationAction(onMainFrame isMainFrame: Bool) {
        print("***", #function)
        guard !isMainFrame else { return }
        navigationState = .subFrame
    }

    public func webViewDidFinishNavigation() {
        print("***", #function)
        if navigationState == .navigating {
            addVisit()
        }
        navigationState = .idle
    }

    public func webViewDidStartProvisionalNavigation() {
        print("***", #function)
    }

    public func webViewDidFailNavigation() {
        print("***", #function)
        navigationState = .error
    }

    private func addVisit() {
        guard let url else { return }
        print("***", #function, url)
        historyManager.historyCoordinator.addVisit(of: url)
    }

}
