//
//  ToolbarStateHandling.swift
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

enum ToolbarContentState: Equatable {
    case newTab
    case pageLoaded(currentTab: TabViewController)
}

protocol ToolbarStateHandling {
    func updateTabbarWithState(toolBar: UIToolbar, state: ToolbarContentState)
}

final class ToolbarHandler: ToolbarStateHandling {
    var backButton = UIBarButtonItem(title: UserText.keyCommandBrowserBack, image: UIImage(named: "BrowsePrevious"))
    var fireButton = UIBarButtonItem(title: UserText.actionForgetAll, image: UIImage(named: "Fire"))
    var forwardButton = UIBarButtonItem(title: UserText.keyCommandBrowserForward, image: UIImage(named: "BrowseNext"))
    var tabSwitcherButton = UIBarButtonItem(title: UserText.tabSwitcherAccessibilityLabel, image: UIImage(named: "Add-24"))
    var bookmarkButton = UIBarButtonItem(title: UserText.actionOpenBookmarks, image: UIImage(named: "Book-24"))
    var passwordsButton = UIBarButtonItem(title: UserText.actionOpenPasswords, image: UIImage(named: "Key-24"))
    var browserMenuButton = UIBarButtonItem(title: UserText.menuButtonHint, image: UIImage(named: "Menu-Horizontal-24"))

    private var state: ToolbarContentState?

    func updateTabbarWithState(toolBar: UIToolbar, state: ToolbarContentState) {
        defer {
            self.state = state

            if case let .pageLoaded(currentTab) = state {
                updateNavigationButtons(currentTab)
            }
        }

        if self.state == state {
            return
        }

        var buttons: [UIBarButtonItem] = []
        switch state {
        case .pageLoaded:
            buttons = [backButton,
                       .flexibleSpace(),
                       forwardButton,
                       .flexibleSpace(),
                       fireButton,
                       .flexibleSpace(),
                       tabSwitcherButton,
                       .flexibleSpace(),
                       browserMenuButton]
        case .newTab:
            buttons = [bookmarkButton,
                       .flexibleSpace(),
                       passwordsButton,
                       .flexibleSpace(),
                       fireButton,
                       .flexibleSpace(),
                       tabSwitcherButton,
                       .flexibleSpace(),
                       browserMenuButton]
        }

        toolBar.setItems(buttons, animated: false)
    }

    private func updateNavigationButtons(_ currentTab: TabViewController) {
        backButton.isEnabled = currentTab.canGoBack
        forwardButton.isEnabled = currentTab.canGoForward
    }
}
