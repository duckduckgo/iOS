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
        return [
            UIKeyCommand(input: "t", modifierFlags: .command, action: #selector(keyboardNewTab)),
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(keyboardNewTab)),
            UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(keyboardCloseTab)),
            UIKeyCommand(input: "]", modifierFlags: [.shift, .command], action: #selector(keyboardNextTab)),
            UIKeyCommand(input: "[", modifierFlags: [.shift, .command], action: #selector(keyboardPreviousTab)),
            UIKeyCommand(input: "]", modifierFlags: [.shift, .command], action: #selector(keyboardNextTab)),
            UIKeyCommand(input: "[", modifierFlags: [.shift, .command], action: #selector(keyboardPreviousTab)),
            UIKeyCommand(input: "\\", modifierFlags: [.shift, .control], action: #selector(keyboardShowAllTabs)),
            UIKeyCommand(input: "\\", modifierFlags: [.shift, .command], action: #selector(keyboardShowAllTabs)),
            UIKeyCommand(input: "]", modifierFlags: [.command], action: #selector(keyboardBrowserForward)),
            UIKeyCommand(input: "[", modifierFlags: [.command], action: #selector(keyboardBrowserBack)),
            UIKeyCommand(input: "f", modifierFlags: [.alternate, .command], action: #selector(keyboardFind)),
            UIKeyCommand(input: UIKeyCommand.inputBackspace, modifierFlags: [ .command, .alternate ], action: #selector(keyboardFire)),
            UIKeyCommand(input: UIKeyCommand.inputBackspace, modifierFlags: [ .control, .alternate ], action: #selector(keyboardFire)),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: [], action: #selector(keyboardTab)),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .control, action: #selector(keyboardNextTab)),
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: [.control, .shift], action: #selector(keyboardPreviousTab)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], action: #selector(keyboardBrowserForward)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command], action: #selector(keyboardBrowserBack)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyboardArrowUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyboardArrowDown)),
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(keyboardEscape))
        ]
    }

    @objc func keyboardTab() {
        keyboardFind()
    }

    @objc func keyboardFire() {
        onQuickFirePressed()
    }
    
    @objc func keyboardFind() {
        guard tabSwitcherController == nil else { return }
        
        if let controller = homeController {
            controller.launchNewSearch()
        } else {
            omniBar.becomeFirstResponder()
        }
    }
    
    @objc func keyboardEscape() {
        guard tabSwitcherController == nil else { return }
        
        if let controller = autocompleteController {
            controller.keyboardEscape()
            homeController?.collectionView.omniBarCancelPressed()
        } else if let controller = homeController {
            controller.omniBarCancelPressed()
        } else {
            omniBar.resignFirstResponder()
        }
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
