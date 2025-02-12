//
//  TabSwitcherViewController+KeyCommands.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

extension TabSwitcherViewController {
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            
            UIKeyCommand(title: "", action: #selector(keyboardCloseWindow), input: UIKeyCommand.inputEscape,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandClose),
                        
            UIKeyCommand(title: "", action: #selector(keyboardCloseWindow), input: "w",
                         modifierFlags: [.command], discoverabilityTitle: UserText.keyCommandClose),

            UIKeyCommand(title: "", action: #selector(keyboardNewTab), input: "t",
                         modifierFlags: [ .command ], discoverabilityTitle: UserText.keyCommandNewTab),
            UIKeyCommand(title: "", action: #selector(keyboardNewTab), input: "n",
                         modifierFlags: [ .command ], discoverabilityTitle: UserText.keyCommandNewTab),
            
            UIKeyCommand(title: "", action: #selector(keyboardSelectCurrent), input: UIKeyCommand.inputEnter,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandSelect),
            
            UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionUp), input: UIKeyCommand.inputUpArrow,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionDown), input: UIKeyCommand.inputDownArrow,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandNextTab),
            
            UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionUp), input: UIKeyCommand.inputLeftArrow,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandPreviousTab),
            UIKeyCommand(title: "", action: #selector(keyboardMoveSelectionDown), input: UIKeyCommand.inputRightArrow,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandNextTab),

            UIKeyCommand(title: "", action: #selector(keyboardRemoveTab), input: UIKeyCommand.inputBackspace,
                         modifierFlags: [], discoverabilityTitle: UserText.keyCommandCloseTab)
        ]
    }
    
    @objc func keyboardNewTab() {
        guard !isProcessingUpdates else { return }
        delegate?.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }
    
    @objc func keyboardCloseWindow() {
        dismiss()
    }
    
    @objc func keyboardSelectCurrent() {
        guard currentSelection != nil else { return }
        markCurrentAsViewedAndDismiss()
    }
    
    @objc func keyboardRemoveTab() {
        guard let current = currentSelection else { return }
        let tab = tabsModel.get(tabAt: current)
        
        deleteTab(tab: tab)
        if tabsModel.count > 0 {
            currentSelection = max(0, current - 1)
        } else {
            currentSelection = nil
        }
        refreshTitle()
        collectionView.reloadData()
    }
    
    @objc func keyboardMoveSelectionUp() {
        guard let current = currentSelection else {
            softSelect(tabAtIndex: tabsModel.count - 1)
            return
        }
        let targetIndex = current - 1 < 0 ? tabsModel.count - 1 : current - 1
        softSelect(tabAtIndex: targetIndex)
    }
    
    @objc func keyboardMoveSelectionDown() {
        guard let current = currentSelection else {
            softSelect(tabAtIndex: 0)
            return
        }
        let targetIndex = current + 1 >= tabsModel.count ? 0 : current + 1
        softSelect(tabAtIndex: targetIndex)
    }
    
    private func softSelect(tabAtIndex index: Int) {
        guard tabsModel.count > 0 else { return }
        
        var paths = [IndexPath(row: index, section: 0)]
        if let oldSelection = currentSelection {
            paths.append(IndexPath(row: oldSelection, section: 0))
        }
        currentSelection = index
        collectionView.reloadItems(at: paths)
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
    }
    
}
