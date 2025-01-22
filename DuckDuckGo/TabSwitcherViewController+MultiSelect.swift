//
//  TabSwitcherViewController+MultiSelect.swift
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

extension TabSwitcherViewController {

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
                interfaceMode = isEditing ? .multiSelectEnabledLarge : .multiSelectAvailableLarge
            } else {
                interfaceMode = isEditing ? .multiSelectEnabledNormal : .multiSelectAvailableNormal
            }
        } else {
            if AppWidthObserver.shared.isLargeWidth {
               interfaceMode = .singleSelectLarge
            } else {
               interfaceMode = .singleSelectNormal
            }
        }

        updateTopLeftButtons()
        updateTopRightButtons()
        updateBottomBar()
    }

    func updateTopLeftButtons() {

        switch interfaceMode {
        case .singleSelectNormal:
            topBarView.topItem?.leftBarButtonItems = [
                createAddAllBookmarksBarButton(),
            ]

        case .singleSelectLarge:
            topBarView.topItem?.leftBarButtonItems = [
                createAddAllBookmarksBarButton(),
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectAvailableNormal:
            topBarView.topItem?.leftBarButtonItems = [
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectAvailableLarge:
            topBarView.topItem?.leftBarButtonItems = [
                createEditBarButton(),
                createTabStyleSwitcherBarButton(),
            ]

        case .multiSelectEnabledNormal:
            topBarView.topItem?.leftBarButtonItems = [
                createSelectAllButton(),
            ]

        case .multiSelectEnabledLarge:
            topBarView.topItem?.leftBarButtonItems = [
                createDoneBarButton(),
            ]

        }
    }

    func updateTopRightButtons() {

        switch interfaceMode {
        case .singleSelectNormal:
            topBarView.topItem?.rightBarButtonItems = [
                createTabStyleSwitcherBarButton(),
            ]

        case .singleSelectLarge, .multiSelectAvailableLarge:
            topBarView.topItem?.rightBarButtonItems = [
                createDoneBarButton(),
                createFireBarButton(),
                createPlusBarButton(),
            ]

        case .multiSelectAvailableNormal:
            topBarView.topItem?.rightBarButtonItems = [
                createEditBarButton(),
            ]

        case .multiSelectEnabledNormal:
            topBarView.topItem?.rightBarButtonItems = [
                createDoneBarButton(),
            ]

        case .multiSelectEnabledLarge:
            topBarView.topItem?.rightBarButtonItems = [
                createMultiSelectionMenuBarButton(),
            ]

        }
    }

    func updateBottomBar() {

        switch interfaceMode {
        case .singleSelectNormal,
                .multiSelectAvailableNormal:
            toolbar.items = [
                createPlusBarButton(),
                UIBarButtonItem.flexibleSpace(),
                createFireBarButton(),
                UIBarButtonItem.flexibleSpace(),
                createDoneBarButton(),
            ]
            toolbar.isHidden = false

        case .multiSelectEnabledNormal:
            toolbar.items = [
                createCloseAllTabsButton(),
                UIBarButtonItem.flexibleSpace(),
                createMultiSelectionMenuBarButton(),
            ]
            toolbar.isHidden = false

        case .multiSelectEnabledLarge,
                .multiSelectAvailableLarge,
                .singleSelectLarge:
            toolbar.isHidden = true
        }

    }

    func createTabStyleSwitcherBarButton() -> UIBarButtonItem {
        let image = UIImage(named: tabsStyle.rawValue)
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
        return UIBarButtonItem(title: UserText.selectAllTabs, primaryAction: UIAction { _ in
            self.selectAllTabs()
        })
    }

    func createMultiSelectionMenuBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: createMultiSelectionMenu())
    }

    func createCloseAllTabsButton() -> UIBarButtonItem {
        if selectedTabs.count == 0 {
            let button = UIBarButtonItem(title: UserText.closeTab)
            button.isEnabled = false
            return button
        } else {
            return UIBarButtonItem(title: UserText.closeTabs(withCount: selectedTabs.count), primaryAction: UIAction { _ in
                self.closeSelectedTabs()
            })
        }
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

            UIAction(title: UserText.closeAllTabs(withCount: tabsModel.count), image: UIImage(named: "Tab-Close-16"), attributes: .destructive) { _ in
                self.closeAllTabs()
            },
        ])
    }

}

// To be removed when fully rolled out
extension TabSwitcherViewController {

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

}
