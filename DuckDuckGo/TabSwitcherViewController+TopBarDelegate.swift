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

extension TabSwitcherViewController { // : TabSwitcherTopBarModel.Delegate {

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

            self.updateUIForSelectionMode()
        }
    }

    func burn(sender: AnyObject) {
        func presentForgetDataAlert() {
            let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
                self?.forgetAll()
            })

            if let view = sender as? UIView {
                self.present(controller: alert, fromView: view)
            } else if let button = sender as? UIBarButtonItem {
                self.present(controller: alert, fromButtonItem: button)
            } else {
                assertionFailure("Unexpected sender")
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

    func closeSelectedTabs() {
        selectedTabs.compactMap {
            tabsModel.safeGetTabAt($0)
        }.forEach {
            delegate.tabSwitcher(self, didRemoveTab: $0)
        }
        selectedTabs = Set<Int>()
        collectionView.reloadData()
        updateUIForSelectionMode()
    }

    func selectAllTabs() {
        selectedTabs = Set<Int>(tabsModel.tabs.indices)
        collectionView.reloadData()
        updateUIForSelectionMode()
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

        updateTopLeftButtons()
        updateTopRightButtons()
        updateBottomBar()
    }

    func updateTopLeftButtons() {

        switch topBarModel.uiMode {
        case .singleSelectNormal:
            // add all bookmarks button
            topBarView.topItem?.leftBarButtonItems = [
                createAddAllBookmarksBarButton(),
            ]

        case .singleSelectLarge:
            // add all bookmarks button
            // tab style switcher
            topBarView.topItem?.leftBarButtonItems = [
                createAddAllBookmarksBarButton(),
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectAvailableNormal:
            // tab style switcher
            topBarView.topItem?.leftBarButtonItems = [
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectAvailableLarge:
            // edit button
            // tab style switcher
            topBarView.topItem?.leftBarButtonItems = [
                createEditBarButton(),
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectEnabledNormal:
            // select all button
            topBarView.topItem?.leftBarButtonItems = [
                createSelectAllButton(),
            ]

        case .multiSelectEnabledLarge:
            // done button
            topBarView.topItem?.leftBarButtonItems = [
                createDoneBarButton(),
            ]

        }
    }

    func updateTopRightButtons() {

        switch topBarModel.uiMode {
        case .singleSelectNormal:
            // tab style switcher
            topBarView.topItem?.rightBarButtonItems = [
                createTabStyleSwitcherBarButton(),
            ]

        case .singleSelectLarge, .multiSelectAvailableLarge:
            // plus button
            // fire button
            // done button
            topBarView.topItem?.rightBarButtonItems = [
                createDoneBarButton(),
                createFireBarButton(),
                createPlusBarButton(),
            ]

        case .multiSelectAvailableNormal:
            // edit button
            topBarView.topItem?.rightBarButtonItems = [
                createEditBarButton(),
            ]

        case .multiSelectEnabledNormal:
            // done button
            topBarView.topItem?.rightBarButtonItems = [
                createDoneBarButton(),
            ]

        case .multiSelectEnabledLarge:
            // multi-select menu button
            topBarView.topItem?.rightBarButtonItems = [
                createMultiSelectionMenuBarButton(),
            ]

        }
    }

    func updateBottomBar() {

        switch topBarModel.uiMode {
        case .singleSelectNormal,
                .multiSelectAvailableNormal:
            // done button
            // separator
            // fire button
            // separator
            // plus button
            toolbar.items = [
                createPlusBarButton(),
                UIBarButtonItem.flexibleSpace(),
                createFireBarButton(),
                UIBarButtonItem.flexibleSpace(),
                createDoneBarButton(),
            ]
            toolbar.isHidden = false

        case .multiSelectEnabledNormal:
            // close tabs
            // separator
            // multi-select menu button
            toolbar.items = [
                createMultiSelectionMenuBarButton(),
                UIBarButtonItem.flexibleSpace(),
                createCloseAllTabsButton(),
            ]
            toolbar.isHidden = false

        case .multiSelectEnabledLarge,
                .multiSelectAvailableLarge,
                .singleSelectLarge:
            // hidden
            toolbar.isHidden = true
        }

    }

    func createTabStyleSwitcherBarButton() -> UIBarButtonItem {
        let image = UIImage(named: topBarModel.tabsStyle.rawValue)
        return UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.onTabStyleChange()
        })
    }

    func createAddAllBookmarksBarButton() -> UIBarButtonItem {
        let image = UIImage(named: "Bookmark-New-24")
        return UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.bookmarkAll()
        })
    }

    func createPlusBarButton() -> UIBarButtonItem {
        let image = UIImage(named: "Add-24")
        let button = UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.addNewTab()
        })
        return button
    }

    func createFireBarButton() -> UIBarButtonItem {
        let image = UIImage(named: "Fire")
        var captured: UIBarButtonItem?
        let button = UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            guard let captured else { return }
            self.burn(sender: captured)
        })
        captured = button
        return button
    }

    func createDoneBarButton() -> UIBarButtonItem {
        var captured: UIBarButtonItem?
        let button = UIBarButtonItem(title: UserText.navigationTitleDone, image: nil, primaryAction: UIAction { _ in
            guard let captured else { return }
            self.onDonePressed(captured)
        })
        captured = button
        return button
    }

    func createEditBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: UserText.actionGenericEdit, menu: createEditMenu())
    }

    func createSelectAllButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Select all", primaryAction: UIAction { _ in
            self.selectAllTabs()
        })
    }

    func createMultiSelectionMenuBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: createMultiSelectionMenu())
    }

    func createCloseAllTabsButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: UserText.closeTabs(withCount: selectedTabs.count), primaryAction: UIAction { _ in
            self.closeSelectedTabs()
        })
    }

    func createMultiSelectionMenu() -> UIMenu {
        return UIMenu(title: "Menu", children: [
            UIAction(title: "Item") { _ in
                print("Action!")
            }
        ])
    }

    func createEditMenu() -> UIMenu {
        return UIMenu(children: [
            UIAction(title: "Select Tabs", image: UIImage(systemName: "checkmark.circle")) { _ in
                self.transitionToMultiSelect()
            },

            UIAction(title: UserText.closeTabs(withCount: tabsModel.count), image: UIImage(named: "Tab-Close-16"), attributes: .destructive) { _ in
                self.closeAllTabs()
            },
        ])
    }

}
