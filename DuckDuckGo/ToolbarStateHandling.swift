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
import BrowserServicesKit

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
    func updateToolbarWithState(_ state: ToolbarContentState)
}

final class ToolbarHandler: ToolbarStateHandling {
    weak var toolbar: UIToolbar?
    private let featureFlagger: FeatureFlagger

   lazy var backButton = createBarButtonItem(title: UserText.keyCommandBrowserBack, imageName: "BrowsePrevious")
   lazy var fireButton = createBarButtonItem(title: UserText.actionForgetAll, imageName: "Fire")
   lazy var forwardButton = createBarButtonItem(title: UserText.keyCommandBrowserForward, imageName: "BrowseNext")
   lazy var tabSwitcherButton = createBarButtonItem(title: UserText.tabSwitcherAccessibilityLabel, imageName: "Add-24")
   lazy var bookmarkButton = createBarButtonItem(title: UserText.actionOpenBookmarks, imageName: "Book-24")
   lazy var passwordsButton = createBarButtonItem(title: UserText.actionOpenPasswords, imageName: "Key-24")
   lazy var browserMenuButton = createBarButtonItem(title: UserText.menuButtonHint, imageName: "Menu-Horizontal-24")

    private var state: ToolbarContentState?

    init(toolbar: UIToolbar, featureFlagger: FeatureFlagger) {
        self.toolbar = toolbar
        self.featureFlagger = featureFlagger
    }

    // MARK: - Public Methods

    func updateToolbarWithState(_ state: ToolbarContentState) {
        guard let toolbar = toolbar else { return }

        updateNavigationButtonsWithState(state)

        /// Avoid unnecessary updates if the state hasn't changed
        guard self.state != state else { return }
        self.state = state

        let buttons: [UIBarButtonItem] = {
            switch state {
            case .pageLoaded:
                return createPageLoadedButtons()
            case .newTab:
                return featureFlagger.isFeatureOn(.aiChatNewTabPage) ? createNewTabButtons() : createLegacyNewTabButtons()
            }
        }()

        toolbar.setItems(buttons, animated: false)
    }

    // MARK: - Private Methods

    private func updateNavigationButtonsWithState(_ state: ToolbarContentState) {
        let currentTab: Navigatable? = {
            if case let .pageLoaded(tab) = state {
                return tab
            }
            return nil
        }()

        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
    }

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

    private func createLegacyNewTabButtons() -> [UIBarButtonItem] {
        return [
            backButton,
            .flexibleSpace(),
            forwardButton,
            .flexibleSpace(),
            fireButton,
            .flexibleSpace(),
            tabSwitcherButton,
            .flexibleSpace(),
            bookmarkButton
        ]
    }
}
