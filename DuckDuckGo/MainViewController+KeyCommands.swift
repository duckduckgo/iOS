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
        if currentTab != nil {
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
                UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(keyboardCloseTab),
                             discoverabilityTitle: UserText.keyCommandCloseTab)
            ]
        }
        
        return alwaysAvailable + browsingCommands + [
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
            UIKeyCommand(input: "\\", modifierFlags: [.shift, .command], action: #selector(keyboardShowAllTabs),
                         discoverabilityTitle: UserText.keyCommandShowAllTabs),
            UIKeyCommand(input: "l", modifierFlags: [.command], action: #selector(keyboardLocation),
                         discoverabilityTitle: UserText.keyCommandLocation),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .control, action: #selector(keyboardNextTab),
                         discoverabilityTitle: UserText.keyCommandNextTab),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: [.control, .shift], action: #selector(keyboardPreviousTab),
                         discoverabilityTitle: UserText.keyCommandPreviousTab),
            
            // No discoverability as these should be intuitive
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyboardArrowUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyboardArrowDown)),
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(keyboardEscape))
        ]
    }

    @objc func keyboardLocation() {
        guard tabSwitcherController == nil else { return }

        if let controller = homeController {
            controller.launchNewSearch()
        } else {
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
        autocompleteController?.keyboardEscape()
        onCancelPressed()
    }
    
    @objc func keyboardArrowDown() {
        guard tabSwitcherController == nil else { return }
        
        if let controller = autocompleteController {
            controller.keyboardMoveSelectionDown()
        } else {
            currentTab?.webView.becomeFirstResponder()
        }
    }
    
    @objc func keyboardArrowUp() {
        guard tabSwitcherController == nil else { return }
        
        if let controller = autocompleteController {
            controller.keyboardMoveSelectionUp()
        } else {
            currentTab?.webView.becomeFirstResponder()
        }
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
        if tabManager.count == 0 {
            launchNewSearch()
        }
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
    
}
