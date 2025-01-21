//
//  TabSwitcherViewController+TopBarDelegate.swift
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
import Core
import Bookmarks

extension TabSwitcherViewController: TabSwitcherTopBarModel.Delegate {

    var tabCount: Int {
        tabsModel.count
    }

    func onTabStyleChange() {
        guard isProcessingUpdates == false else { return }

        isProcessingUpdates = true
        // Idea is here to wait for any pending processing of reconfigureItems on a cells,
        // so when transition to/from grid happens we can request cells without any issues
        // related to mismatched identifiers.
        // Alternative is to use reloadItems instead of reconfigureItems but it looks very bad
        // when tabs are reloading in the background.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }

            tabSwitcherSettings.isGridViewEnabled = !tabSwitcherSettings.isGridViewEnabled

            if tabSwitcherSettings.isGridViewEnabled {
                Pixel.fire(pixel: .tabSwitcherGridEnabled)
            } else {
                Pixel.fire(pixel: .tabSwitcherListEnabled)
            }

            self.refreshDisplayModeButton()

            UIView.transition(with: view,
                              duration: 0.3,
                              options: .transitionCrossDissolve, animations: {
                self.collectionView.reloadData()
            }, completion: { _ in
                self.isProcessingUpdates = false
            })
        }
    }

    func burn() {
        func presentForgetDataAlert() {
            let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
                self?.forgetAll()
            })

            if !toolbar.isHidden {
                self.present(controller: alert, fromView: toolbar)
            } else if let frame = topBarModel.fireButtonFrame {
                let point = Point(x: Int(frame.midX),
                                  y: Int(frame.midY))
                self.present(controller: alert, fromView: topBarContainerView, atPoint: point)
            }
        }

        Pixel.fire(pixel: .forgetAllPressedTabSwitching)
        ViewHighlighter.hideAll()
        presentForgetDataAlert()
    }

    func addNewTab() {
        guard !isProcessingUpdates else { return }

        Pixel.fire(pixel: .tabSwitcherNewTab)
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }

    func bookmarkAll() {

        let alert = UIAlertController(title: UserText.alertBookmarkAllTitle,
                                      message: UserText.alertBookmarkAllMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        alert.addAction(title: UserText.actionBookmark, style: .default) {
            let model = MenuBookmarksViewModel(bookmarksDatabase: self.bookmarksDatabase, syncService: self.syncService)
            model.favoritesDisplayMode = AppDependencyProvider.shared.appSettings.favoritesDisplayMode
            let result = self.bookmarkAll(viewModel: model)
            self.displayBookmarkAllStatusMessage(with: result, openTabsCount: self.tabsModel.tabs.count)
        }

        present(alert, animated: true, completion: nil)

    }

    func transitionToMultiSelect() {
        self.isEditing = true
        selectedTabs = Set<Int>()
        collectionView.reloadData()
        updateUIForSelectionMode()
    }

    func transitionFromMultiSelect() {
        self.isEditing = false
        selectedTabs = Set<Int>()
        collectionView.reloadData()
        updateUIForSelectionMode()
    }

    func closeAllTabs() {
        delegate?.tabSwitcherDidRequestCloseAll(tabSwitcher: self)
    }

    func selectAllTabs() {
        selectedTabs = Set<Int>(tabsModel.tabs.indices)
        collectionView.reloadData()
    }

    func showMultiSelectMenu() {

        // TODO proper menu
        var button: UIButton?
        let menu = UIMenu(title: "menu", children: [
            UIAction(title: "One") { _ in
                print("*** 1")
                button?.removeFromSuperview()
            },
            UIAction(title: "Two") { _ in
                print("*** 2")
                button?.removeFromSuperview()
            },
            UIAction(title: "Three") { _ in
                print("*** 3")
                button?.removeFromSuperview()
            },
        ])

        if !toolbar.isHidden {
            // TODO just add the menu to the more button in the toolbar
        } else if let frame = topBarModel.menuButtonFrame {
            let localFrame = topBarContainerView.convert(frame, from: nil)
            let fakeButton = UIButton()
            fakeButton.backgroundColor = .clear
            fakeButton.frame = localFrame
            fakeButton.showsMenuAsPrimaryAction = true
            topBarContainerView.addSubview(fakeButton)
            button = fakeButton // So it can be removed later
            fakeButton.menu = menu
        }

    }

}

extension TabSwitcherViewController {
    func updateUIForSelectionMode() {
        if featureFlagger.isFeatureOn(.tabManagerMultiSelection) {
            if AppWidthObserver.shared.isLargeWidth {
                topBarModel.uiMode = isEditing ? .multiSelectEnabledLarge : .multiSelectAvailableLarge
            } else {
                topBarModel.uiMode = isEditing ? .multiSelectEnabledNormal : .multiSelectAvailableNormal
            }
        } else {
            if AppWidthObserver.shared.isLargeWidth {
                topBarModel.uiMode = .singleSelectLarge
            } else {
                topBarModel.uiMode = .singleSelectNormal
            }
        }
        // TODO update bottom bar if needed
    }
}
