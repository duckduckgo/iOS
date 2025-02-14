//
//  LaunchActionHandler.swift
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

import UIKit

enum LaunchAction {

    case openURL(URL)
    case handleShortcutItem(UIApplicationShortcutItem)
    case showKeyboard(Date?)

    init(urlToOpen: URL?, shortcutItemToHandle: UIApplicationShortcutItem?, lastBackgroundDate: Date?) {
        if let url = urlToOpen {
            self = .openURL(url)
        } else if let shortcutItem = shortcutItemToHandle {
            self = .handleShortcutItem(shortcutItem)
        } else {
            self = .showKeyboard(lastBackgroundDate)
        }
    }

}

@MainActor
protocol LaunchActionHandling {

    func handleLaunchAction(_ action: LaunchAction)

}

@MainActor
final class LaunchActionHandler: LaunchActionHandling {

    private let urlHandler: URLHandling
    private let shortcutItemHandler: ShortcutItemHandling
    private let keyboardPresenter: KeyboardPresenting

    init(urlHandler: URLHandling,
         shortcutItemHandler: ShortcutItemHandling,
         keyboardPresenter: KeyboardPresenting) {
        self.urlHandler = urlHandler
        self.shortcutItemHandler = shortcutItemHandler
        self.keyboardPresenter = keyboardPresenter
    }

    func handleLaunchAction(_ action: LaunchAction) {
        switch action {
        case .openURL(let url):
            openURL(url)
        case .handleShortcutItem(let shortcutItem):
            shortcutItemHandler.handleShortcutItem(shortcutItem)
        case .showKeyboard(let lastBackgroundDate):
            keyboardPresenter.showKeyboardOnLaunch(lastBackgroundDate: lastBackgroundDate)
        }
    }

    private func openURL(_ url: URL) {
        Logger.sync.debug("App launched with url \(url.absoluteString)")
        guard urlHandler.shouldProcessDeepLink(url) else { return }
        NotificationCenter.default.post(name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)
        urlHandler.handleURL(url)
    }

    private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        Logger.general.debug("Handling shortcut item: \(shortcutItem.type)")
        shortcutItemHandler.handleShortcutItem(shortcutItem)
    }

}
