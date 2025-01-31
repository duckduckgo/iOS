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
    case pageLoaded(currentTab: Navigatable)

    static func == (lhs: ToolbarContentState, rhs: ToolbarContentState) -> Bool {
        switch (lhs, rhs) {
        case (.newTab, .newTab):
            return true
        case (.pageLoaded(let lhsTab), .pageLoaded(let rhsTab)):
            return lhsTab.canGoBack == rhsTab.canGoBack && lhsTab.canGoForward == rhsTab.canGoForward
        default:
            return false
        }
    }
}

protocol ToolbarStateHandling {
    func updateTabbarWithState(toolBar: UIToolbar, state: ToolbarContentState)
}

final class ToolbarHandler: ToolbarStateHandling {
   lazy var backButton = createBarButtonItem(title: UserText.keyCommandBrowserBack, imageName: "BrowsePrevious")
   lazy var fireButton = createBarButtonItem(title: UserText.actionForgetAll, imageName: "Fire")
   lazy var forwardButton = createBarButtonItem(title: UserText.keyCommandBrowserForward, imageName: "BrowseNext")
   lazy var tabSwitcherButton = createBarButtonItem(title: UserText.tabSwitcherAccessibilityLabel, imageName: "Add-24")
   lazy var bookmarkButton = createBarButtonItem(title: UserText.actionOpenBookmarks, imageName: "Book-24")
   lazy var passwordsButton = createBarButtonItem(title: UserText.actionOpenPasswords, imageName: "Key-24")
   lazy var browserMenuButton = createBarButtonItem(title: UserText.menuButtonHint, imageName: "Menu-Horizontal-24")

    private var state: ToolbarContentState?

    // MARK: - Public Methods

    func updateTabbarWithState(toolBar: UIToolbar, state: ToolbarContentState) {
        /// We always want to update the navigation buttons if the state is page loaded
        if case let .pageLoaded(currentTab) = state {
            updateNavigationButtons(currentTab)
        }

        guard self.state != state else { return }

        self.state = state

        let buttons: [UIBarButtonItem]
        switch state {
        case .pageLoaded:
            buttons = createPageLoadedButtons()
        case .newTab:
            buttons = createNewTabButtons()
        }
        // TODO: Add feature flag, always return createPageLoadedButtons in case the new feature is off
        toolBar.setItems(buttons, animated: false)
    }

    // MARK: - Private Methods

    private func createBarButtonItem(title: String, imageName: String) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, image: UIImage(named: imageName), primaryAction: nil)
    }

    private func createPageLoadedButtons() -> [UIBarButtonItem] {
        return [
            backButton,
            .flexibleSpace(),
            forwardButton,
            .flexibleSpace(),
            fireButton,
            .flexibleSpace(),
            tabSwitcherButton,
            .flexibleSpace(),
            browserMenuButton
        ]
    }

    private func createNewTabButtons() -> [UIBarButtonItem] {
        return [
            bookmarkButton,
            .flexibleSpace(),
            passwordsButton,
            .flexibleSpace(),
            fireButton,
            .flexibleSpace(),
            tabSwitcherButton,
            .flexibleSpace(),
            browserMenuButton
        ]
    }

    private func updateNavigationButtons(_ currentTab: Navigatable) {
        backButton.isEnabled = currentTab.canGoBack
        forwardButton.isEnabled = currentTab.canGoForward
    }
}
