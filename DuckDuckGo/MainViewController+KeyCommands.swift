//
//  MainViewController+KeyCommands.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

extension MainViewController {
    
    override var keyCommands: [UIKeyCommand]? {
        
        let alwaysAvailable = [
            UIKeyCommand(input: UIKeyCommand.inputBackspace, modifierFlags: [ .control, .alternate ], action: #selector(keyboardFire),
                         discoverabilityTitle: UserText.keyCommandFire)
        ]
        
        guard tabSwitcherController == nil else {
            return alwaysAvailable
        }
        
        var browsingCommands = [UIKeyCommand]()
        if homeController == nil {
            browsingCommands = [
                UIKeyCommand(input: "f", modifierFlags: [.command], action: #selector(keyboardFind),
                             discoverabilityTitle: UserText.keyCommandFind),
                UIKeyCommand(input: "]", modifierFlags: [.command], action: #selector(keyboardBrowserForward),
                             discoverabilityTitle: UserText.keyCommandBrowserForward),
                UIKeyCommand(input: "[", modifierFlags: [.command], action: #selector(keyboardBrowserBack),
                             discoverabilityTitle: UserText.keyCommandBrowserBack),
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], action: #selector(keyboardBrowserForward),
                             discoverabilityTitle: UserText.keyCommandBrowserForward),
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command], action: #selector(keyboardBrowserBack),
                             discoverabilityTitle: UserText.keyCommandBrowserBack),
                UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(keyboardReload),
                             discoverabilityTitle: UserText.keyCommandReload),
                UIKeyCommand(input: "p", modifierFlags: [.command], action: #selector(keyboardPrint),
                             discoverabilityTitle: UserText.keyCommandPrint),
                UIKeyCommand(input: "d", modifierFlags: [.command], action: #selector(keyboardAddBookmark),
                             discoverabilityTitle: UserText.keyCommandAddBookmark),
                UIKeyCommand(input: "d", modifierFlags: [.command, .control], action: #selector(keyboardAddFavorite),
                         discoverabilityTitle: UserText.keyCommandAddFavorite),
                UIKeyCommand(input: "tap link", modifierFlags: [.command, .shift], action: #selector(keyboardNoOperation),
                     discoverabilityTitle: UserText.keyCommandOpenInNewTab),
                UIKeyCommand(input: "tap link", modifierFlags: [.command], action: #selector(keyboardNoOperation),
                     discoverabilityTitle: UserText.keyCommandOpenInNewBackgroundTab)
            ]
        }

        var findInPageCommands = [UIKeyCommand]()
        if findInPageView.findInPage != nil {
            findInPageCommands = [
                UIKeyCommand(input: "g", modifierFlags: .command, action: #selector(keyboardFindNext),
                             discoverabilityTitle: UserText.keyCommandFindNext),
                UIKeyCommand(input: "g", modifierFlags: [.command, .shift ], action: #selector(keyboardFindPrevious),
                             discoverabilityTitle: UserText.keyCommandFindPrevious)
            ]
        }

        return alwaysAvailable + browsingCommands + findInPageCommands + [
            UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(keyboardCloseTab),
                         discoverabilityTitle: UserText.keyCommandCloseTab),
            UIKeyCommand(input: "t", modifierFlags: .command, action: #selector(keyboardNewTab),
                         discoverabilityTitle: UserText.keyCommandNewTab),
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(keyboardNewTab),
                         discoverabilityTitle: UserText.keyCommandNewTab),
            UIKeyCommand(input: "]", modifierFlags: [.shift, .command], action: #selector(keyboardNextTab),
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(input: "[", modifierFlags: [.shift, .command], action: #selector(keyboardPreviousTab),
                         discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(input: "]", modifierFlags: [.shift, .command], action: #selector(keyboardNextTab),
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(input: "[", modifierFlags: [.shift, .command], action: #selector(keyboardPreviousTab),
                         discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(input: "\\", modifierFlags: [.shift, .control], action: #selector(keyboardShowAllTabs),
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: [.alternate, .command], action: #selector(keyboardShowAllTabs),
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(input: "\\", modifierFlags: [.shift, .command], action: #selector(keyboardShowAllTabs),
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(input: "l", modifierFlags: [.command], action: #selector(keyboardLocation),
                         discoverabilityTitle: UserText.keyCommandLocation),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .control, action: #selector(keyboardNextTab),
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: [.control, .shift], action: #selector(keyboardPreviousTab),
                         discoverabilityTitle: UserText.keyCommandPreviousTab),

            // No discoverability as these should be intuitive
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(keyboardEscape))
        ]
    }

    @objc func keyboardReload() {
        self.currentTab?.refresh()
    }

    @objc func keyboardFindNext() {
        self.findInPageView.findInPage?.next()
    }

    @objc func keyboardFindPrevious() {
        self.findInPageView.findInPage?.previous()
    }

    @objc func keyboardLocation() {
        guard tabSwitcherController == nil else { return }

        if let controller = homeController {
            controller.launchNewSearch()
        } else {
            showBars()
            omniBar.becomeFirstResponder()
        }
    }

    @objc func keyboardFire() {
        onQuickFirePressed()
    }
    
    @objc func keyboardFind() {
        currentTab?.requestFindInPage()
    }
    
    @objc func keyboardEscape() {
        guard tabSwitcherController == nil else { return }
        findInPageView.done()
        hideSuggestionTray()
        onCancelPressed()
    }
    
    @objc func keyboardNewTab() {
        guard tabSwitcherController == nil else { return }
        
        if currentTab != nil {
            newTab()
        } else {
            keyboardFind()
        }
    }
    
    @objc func keyboardCloseTab() {
        guard tabSwitcherController == nil else { return }
        
        guard let tab = currentTab else { return }
        closeTab(tab.tabModel)
    }
    
    @objc func keyboardNextTab() {
        guard tabSwitcherController == nil else { return }
        
        guard let tab = currentTab else { return }
        guard let index = tabManager.model.indexOf(tab: tab.tabModel) else { return }
        let targetTabIndex = index + 1 >= tabManager.model.count ? 0 : index + 1
        onCancelPressed()
        select(tabAt: targetTabIndex)
    }
    
    @objc func keyboardPreviousTab() {
        guard tabSwitcherController == nil else { return }
        
        guard let tab = currentTab else { return }
        guard let index = tabManager.model.indexOf(tab: tab.tabModel) else { return }
        let targetTabIndex = index - 1 < 0 ? tabManager.model.count - 1 : index - 1
        onCancelPressed()
        select(tabAt: targetTabIndex)
    }
    
    @objc func keyboardShowAllTabs() {
        guard tabSwitcherController == nil else { return }
        
        onCancelPressed()
        showTabSwitcher()
    }
    
    @objc func keyboardBrowserForward() {
        guard tabSwitcherController == nil else { return }
        
        currentTab?.goForward()
    }
    
    @objc func keyboardBrowserBack() {
        guard tabSwitcherController == nil else { return }
        
        currentTab?.goBack()
    }
    
    @objc func keyboardPrint() {
        currentTab?.print()
    }

    @objc func keyboardAddBookmark() {
        currentTab?.saveAsBookmark(favorite: false)
    }

    @objc func keyboardAddFavorite() {
        currentTab?.saveAsBookmark(favorite: true)
    }
    
    @objc func keyboardNoOperation() { }
    
}
