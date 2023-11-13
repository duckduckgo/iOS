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
        
        let alwaysAvailable: [UIKeyCommand] = [
            UIKeyCommand(title: "", action: #selector(keyboardFire), input: UIKeyCommand.inputBackspace,
                         modifierFlags: [ .control, .alternate ], discoverabilityTitle: UserText.keyCommandFire)
        ]
        
        guard tabSwitcherController == nil else {
            return alwaysAvailable
        }
        
        var browsingCommands = [UIKeyCommand]()
        if homeController == nil {
            browsingCommands = [
                UIKeyCommand(title: "", action: #selector(keyboardFind), input: "f", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandFind),
                UIKeyCommand(title: "", action: #selector(keyboardBrowserForward), input: "]", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandBrowserForward),
                UIKeyCommand(title: "", action: #selector(keyboardBrowserBack), input: "[", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandBrowserBack),
                UIKeyCommand(title: "", action: #selector(keyboardBrowserForward), input: UIKeyCommand.inputRightArrow, modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandBrowserForward),
                UIKeyCommand(title: "", action: #selector(keyboardBrowserBack), input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandBrowserBack),
                UIKeyCommand(title: "", action: #selector(keyboardReload), input: "r", modifierFlags: .command,
                             discoverabilityTitle: UserText.keyCommandReload),
                UIKeyCommand(title: "", action: #selector(keyboardPrint), input: "p", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandPrint),
                UIKeyCommand(title: "", action: #selector(keyboardAddBookmark), input: "d", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandAddBookmark),
                UIKeyCommand(title: "", action: #selector(keyboardAddFavorite), input: "d", modifierFlags: [.command, .control],
                             discoverabilityTitle: UserText.keyCommandAddFavorite),
                UIKeyCommand(title: "", action: #selector(keyboardNoOperation), input: "tap link", modifierFlags: [.command, .shift],
                             discoverabilityTitle: UserText.keyCommandOpenInNewTab),
                UIKeyCommand(title: "", action: #selector(keyboardNoOperation), input: "tap link", modifierFlags: [.command],
                             discoverabilityTitle: UserText.keyCommandOpenInNewBackgroundTab)
            ]
        }
        
        var findInPageCommands = [UIKeyCommand]()
        if findInPageView.findInPage != nil {
            findInPageCommands = [
                UIKeyCommand(title: "", action: #selector(keyboardFindNext), input: "g", modifierFlags: .command,
                             discoverabilityTitle: UserText.keyCommandFindNext),
                UIKeyCommand(title: "", action: #selector(keyboardFindPrevious), input: "g", modifierFlags: [.command, .shift ],
                             discoverabilityTitle: UserText.keyCommandFindPrevious)
            ]
        }
        
        var arrowKeys = [UIKeyCommand]()
        if viewCoordinator.omniBar.textField.isFirstResponder {
            arrowKeys = [
                UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionUp), input: UIKeyCommand.inputUpArrow, modifierFlags: []),
                UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionDown), input: UIKeyCommand.inputDownArrow, modifierFlags: [])
            ]
        }

        let other: [UIKeyCommand] = [
            UIKeyCommand(title: "", action: #selector(keyboardCloseTab), input: "w", modifierFlags: .command,
                         discoverabilityTitle: UserText.keyCommandCloseTab),
            UIKeyCommand(title: "", action: #selector(keyboardNewTab), input: "t", modifierFlags: .command,
                         discoverabilityTitle: UserText.keyCommandNewTab),
            UIKeyCommand(title: "", action: #selector(keyboardNewTab), input: "n", modifierFlags: .command,
                         discoverabilityTitle: UserText.keyCommandNewTab),
            UIKeyCommand(title: "", action: #selector(keyboardNextTab), input: "]", modifierFlags: [.shift, .command],
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(title: "", action: #selector(keyboardPreviousTab), input: "[", modifierFlags: [.shift, .command],
                         discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(title: "", action: #selector(keyboardNextTab), input: "]", modifierFlags: [.shift, .command],
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(title: "", action: #selector(keyboardPreviousTab), input: "[", modifierFlags: [.shift, .command],
                         discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(title: "", action: #selector(keyboardShowAllTabs), input: "\\", modifierFlags: [.shift, .control],
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(title: "", action: #selector(keyboardShowAllTabs), input: UIKeyCommand.inputTab, modifierFlags: [.alternate, .command],
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(title: "", action: #selector(keyboardShowAllTabs), input: "\\", modifierFlags: [.shift, .command],
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(title: "", action: #selector(keyboardLocation), input: "l", modifierFlags: [.command],
                         discoverabilityTitle: UserText.keyCommandLocation),
            UIKeyCommand(title: "", action: #selector(keyboardNextTab), input: UIKeyCommand.inputTab, modifierFlags: .control,
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(title: "", action: #selector(keyboardPreviousTab), input: UIKeyCommand.inputTab, modifierFlags: [.control, .shift],
                         discoverabilityTitle: UserText.keyCommandPreviousTab),

            // No discoverability as these should be intuitive
            UIKeyCommand(title: "", action: #selector(keyboardEscape), input: UIKeyCommand.inputEscape, modifierFlags: [])
        ]

        let commands = [alwaysAvailable, browsingCommands, findInPageCommands, arrowKeys, other].flatMap { $0 }
        if #available(iOS 15, *) {
            commands.forEach {
                $0.wantsPriorityOverSystemBehavior = true
            }
        }
        return commands
    }

    @objc func keyboardMoveSelectionUp() {
        suggestionTrayController?.keyboardMoveSelectionUp()
    }

    @objc func keyboardMoveSelectionDown() {
        suggestionTrayController?.keyboardMoveSelectionDown()
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
            viewCoordinator.omniBar.becomeFirstResponder()
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
        saveBookmark(favorite: false)
    }

    @objc func keyboardAddFavorite() {
        saveBookmark(favorite: true)
    }
    
    @objc func keyboardNoOperation() { }

    private func saveBookmark(favorite: Bool) {
        currentTab?.saveAsBookmark(favorite: favorite, viewModel: menuBookmarksViewModel)
    }

}
