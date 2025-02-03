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

// MARK: Source agnostic action implementations
// TODO fire pixels from the source specific action implementations
extension TabSwitcherViewController {

    var tabCount: Int {
        tabsModel.count
    }

    func bookmarkTabs(withIndexes indices: [Int]) {
        let alert = UIAlertController(title: UserText.alertBookmarkAllTitle,
                                      message: UserText.alertBookmarkAllMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        alert.addAction(title: UserText.actionBookmark, style: .default) {
            let model = MenuBookmarksViewModel(bookmarksDatabase: self.bookmarksDatabase, syncService: self.syncService)
            model.favoritesDisplayMode = AppDependencyProvider.shared.appSettings.favoritesDisplayMode
            let result = self.bookmarkTabs(withIndices: indices, viewModel: model)
            self.displayBookmarkAllStatusMessage(with: result, openTabsCount: self.tabsModel.tabs.count)
        }

        present(alert, animated: true, completion: nil)
    }

    func bookmarkTabAt(_ index: Int) {
        guard let tab = tabsModel.safeGetTabAt(index), let link = tab.link else { return }
        let viewModel = MenuBookmarksViewModel(bookmarksDatabase: self.bookmarksDatabase, syncService: self.syncService)
        viewModel.createBookmark(title: link.displayTitle, url: link.url)
        ActionMessageView.present(message: UserText.webSaveBookmarkDone)
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
                self.refreshTitle()
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
        let alert = UIAlertController(
            title: UserText.closeAllTabs(withCount: tabsModel.count),
            message: UserText.alertMessageCloseTheseTabs,
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: UserText.actionCancel,
                                      style: .default) { _ in })

        alert.addAction(UIAlertAction(title: UserText.closeTabs,
                                      style: .destructive) { _ in

            self.delegate?.tabSwitcherDidRequestCloseAll(tabSwitcher: self)
        })

        present(alert, animated: true)
    }

    func closeTabs(withIndexes indices: [Int], confirmTitle: String, confirmMessage: String) {

        let alert = UIAlertController(
            title: confirmTitle,
            message: confirmMessage,
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: UserText.actionCancel,
                                      style: .default) { _ in })

        alert.addAction(UIAlertAction(title: UserText.closeTabs,
                                      style: .destructive) { _ in

            indices.compactMap {
                self.tabsModel.safeGetTabAt($0)
            }.forEach {
                self.delegate.tabSwitcher(self, didRemoveTab: $0)
            }
            self.selectedTabs = Set<Int>()
            self.collectionView.reloadData()
            self.refreshTitle()
            self.updateUIForSelectionMode()
        })

        present(alert, animated: true)
    }

    func deselectAllTabs() {
        selectedTabs = Set<Int>()
        collectionView.reloadData()
        updateUIForSelectionMode()
    }

    func selectAllTabs() {
        selectedTabs = Set<Int>(tabsModel.tabs.indices)
        collectionView.reloadData()
        updateUIForSelectionMode()
    }

    func shareTabs(_ tabs: [Tab]) {
        let sharingItems = tabs.compactMap { $0.link?.url }
        let controller = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)

        // Generically show the share sheet in the middle of the screen when on iPad
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        present(controller, animated: true)
    }

    func closeOtherTabs(retainingIndexes indices: [Int]) {
        let otherIndices = Set<Int>(tabsModel.tabs.indices).subtracting(indices)
        self.closeTabs(withIndexes: [Int](otherIndices),
                       confirmTitle: UserText.alertTitleCloseOtherTabs(withCount: self.selectedTabs.count),
                       confirmMessage: UserText.alertMessageCloseOtherTabs)

    }

}

// MARK: UI updating
extension TabSwitcherViewController {
    
    func updateUIForSelectionMode() {
        if featureFlagger.isFeatureOn(.tabManagerMultiSelection) {
            if AppWidthObserver.shared.isLargeWidth {
                interfaceMode = isEditing ? .multiSelectedEditingLarge : .multiSelectAvailableLarge
            } else {
                interfaceMode = isEditing ? .multiSelectEditingNormal : .multiSelectAvailableNormal
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

        case .multiSelectEditingNormal:
            topBarView.topItem?.leftBarButtonItems = [
                createSelectAllButton(),
            ]

        case .multiSelectedEditingLarge:
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

        case .multiSelectEditingNormal:
            topBarView.topItem?.rightBarButtonItems = [
                createDoneBarButton(),
            ]

        case .multiSelectedEditingLarge:
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

        case .multiSelectEditingNormal:
            toolbar.items = [
                createCloseAllTabsButton(),
                UIBarButtonItem.flexibleSpace(),
                createMultiSelectionMenuBarButton(),
            ]
            toolbar.isHidden = false

        case .multiSelectedEditingLarge,
                .multiSelectAvailableLarge,
                .singleSelectLarge:
            toolbar.isHidden = true
        }

    }

    var selectedPagesCount: Int {
        return selectedTabs.compactMap {
            tabsModel.safeGetTabAt($0)
        }.compactMap {
            $0.link
        }.count
    }

    func createMultiSelectionMenu() -> UIMenu {
        let selectedPagesCount = self.selectedPagesCount

        var children = [UIMenuElement]()
        
        if self.interfaceMode.isLarge {
            if selectedTabs.count == tabsModel.count {
                children.append(action(UserText.deselectAllTabs, systemImage: "circle", self.selectModeDeselectAllTabs))
            } else {
                children.append(action(UserText.selectAllTabs, systemImage: "checkmark.circle", self.selectModeSelectAllTabs))
            }
        }

        if selectedPagesCount > 0 {
            // share
            // bookmark
            children.append(UIMenu(title: "", options: .displayInline, children: [
                action(UserText.shareLink(withCount: selectedPagesCount), "Share-Apple-16", self.selectModeShareLink),
                action(UserText.bookmarkTabs(withCount: selectedPagesCount), "Bookmark-Add-16", self.selectModeBookmarkSelected),
            ]))
        }

        if selectedTabs.count != tabsModel.count && selectedPagesCount > 0 {
            // bookmark all
            children.append(UIMenu(title: "", options: .displayInline, children: [
                action(UserText.tabSwitcherBookmarkAllTabs, "Bookmark-All-16", self.selectModeBookmarkAll),
            ]))
        }

        if selectedTabs.count > 0 && tabsModel.count > selectedTabs.count {
            if interfaceMode.isLarge {
                // close
                children.append(UIMenu(title: "", options: .displayInline, children: [
                    action(UserText.closeTabs(withCount: selectedTabs.count), "Close-16", destructive: true, self.selectModeCloseSelectedTabs),
                ]))
            } else {
                // close other (close is on the button)
                children.append(UIMenu(title: "", options: .displayInline, children: [
                    action(UserText.tabSwitcherCloseOtherTabs, "Tab-Close-16", destructive: true, self.selectModeCloseOtherTabs),
                ]))
            }
        }

        return UIMenu(title: "", children: children)
    }

    func createEditMenu() -> UIMenu {
        return UIMenu(children: [
            action(UserText.tabSwitcherSelectTabs, systemImage: "checkmark.cicle", self.editMenuSelectAll),
            action(UserText.closeAllTabs(withCount: tabsModel.count), "Tab-Close-16", destructive: true, self.editMenuCloseAllTabs),
        ])
    }

    func trimMenuTitleIfNeeded(_ s: String, _ maxLength: Int) -> String {
        if s.count > maxLength {
            return s.prefix(maxLength) + "..."
        }
        return s
    }

    func createLongPressMenuItems(forIndex index: Int) -> [UIMenuElement] {
        guard let tab = tabsModel.safeGetTabAt(index) else { return [] }

        let selectedPagesCount = self.selectedPagesCount
        let bookmarksModel = MenuBookmarksViewModel(bookmarksDatabase: self.bookmarksDatabase, syncService: self.syncService)

        let group0 = [
            // Share Link
            tabsModel.safeGetTabAt(index)?.link != nil ? self.action(index, UserText.tabSwitcherShareLink, "Share-Apple-16", self.longPressMenuShareLink) : nil,

            // Bookmark This Page (if not already bookmarked)
            shouldShowBookmarkThisPageLongPressMenuItem(tab, bookmarksModel) ? self.action(index, UserText.tabSwitcherBookmarkPage, "Bookmark-Add-16", self.longPressMenuBookmarkThisPage) : nil,
        ]

        let group1 = [
            // IMO: Doesn't make sense
            // Bookmark All Tabs -> shortcut to same functionality at top level
            // self.action(index, UserText.tabSwitcherBookmarkAllTabs, "Bookmark-All-16", self.longPressMenuBookmarkAllTabs),

            // Select Tabs -> switch to selection mode with this tab selected (if not already selected)
            selectedTabs.contains(index) ? nil : self.action(index, UserText.tabSwitcherSelectTabs, "Check-Circle-16", self.longPressMenuSelectTabs),
        ]

        let group2 = [
            // Close Tab
            self.action(index, UserText.keyCommandCloseTab, "Close-16", destructive: true, self.longPressMenuCloseTab),

            // Close Other Tabs
            tabsModel.count > 1 ? self.action(index, UserText.tabSwitcherCloseOtherTabs, "Tab-Close-16", destructive: true, self.longPressMenuCloseOtherTabs) : nil,
        ]

        return group0.compactMap { $0 } +
        [
            // -- divider --
            UIMenu(title: "", options: .displayInline, children: group1.compactMap { $0 }),

            // -- divider --
            UIMenu(title: "", options: .displayInline, children: group2.compactMap { $0 }),
        ]
    }

    private func shouldShowBookmarkThisPageLongPressMenuItem(_ tab: Tab, _ bookmarksModel: MenuBookmarksViewModel) -> Bool {
        return tab.link?.url != nil &&
        bookmarksModel.bookmark(for: tab.link!.url) == nil &&
        tabsModel.count > selectedTabs.count
    }

}

// MARK: Button factories
extension TabSwitcherViewController {

    func createTabStyleSwitcherBarButton() -> UIBarButtonItem {
        let image = UIImage(named: tabsStyle.rawValue)
        return UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.onTabStyleChange()
        })
    }

    func createAddAllBookmarksBarButton() -> UIBarButtonItem {
        let image = UIImage(named: "Bookmark-New-24")
        let button = UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.bookmarkTabs(withIndexes: self.tabsModel.tabs.indices.map { $0 })
        })
        button.accessibilityLabel = UserText.bookmarkAllTabs
        return button
    }

    func createPlusBarButton() -> UIBarButtonItem {
        let image = UIImage(named: "Add-24")
        let button = UIBarButtonItem(title: nil, image: image, primaryAction: UIAction { _ in
            self.addNewTab()
        })
        button.accessibilityLabel = UserText.keyCommandNewTab
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
        if selectedTabs.count == tabsModel.count {
            return UIBarButtonItem(title: UserText.deselectAllTabs, primaryAction: UIAction { _ in
                self.deselectAllTabs()
            })
        } else {
            return UIBarButtonItem(title: UserText.selectAllTabs, primaryAction: UIAction { _ in
                self.selectAllTabs()
            })
        }
    }

    func createMultiSelectionMenuBarButton() -> UIBarButtonItem {
        let menu = createMultiSelectionMenu()
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        button.isEnabled = !menu.children.isEmpty
        return button
    }

    func createCloseAllTabsButton() -> UIBarButtonItem {
        if selectedTabs.count == 0 {
            let button = UIBarButtonItem(title: UserText.closeTab)
            button.isEnabled = false
            return button
        } else {
            return UIBarButtonItem(title: UserText.closeTabs(withCount: selectedTabs.count), primaryAction: UIAction { _ in
                self.closeTabs(withIndexes: [Int](self.selectedTabs),
                               confirmTitle: UserText.alertTitleCloseSelectedTabs(withCount: self.selectedTabs.count),
                               confirmMessage: UserText.alertMessageCloseTheseTabs)
            })
        }
    }

}

// MARK: Edit menu actions
extension TabSwitcherViewController {

    func editMenuSelectAll() {
        transitionToMultiSelect()
    }

    func editMenuCloseAllTabs() {
        closeAllTabs()
    }

}

// MARK: Select mode menu actions
extension TabSwitcherViewController {

    func selectModeCloseSelectedTabs() {
        self.closeTabs(withIndexes: [Int](self.selectedTabs),
                       confirmTitle: UserText.alertTitleCloseSelectedTabs(withCount: self.selectedTabs.count),
                       confirmMessage: UserText.alertMessageCloseTheseTabs)
    }

    func selectModeCloseOtherTabs() {
        closeOtherTabs(retainingIndexes: [Int](selectedTabs))
    }

    func selectModeBookmarkAll() {
        bookmarkTabs(withIndexes: tabsModel.tabs.indices.map { $0 })
    }

    func selectModeBookmarkSelected() {
        bookmarkTabs(withIndexes: [Int](selectedTabs))
    }

    func selectModeShareLink() {
        shareTabs(selectedTabs.compactMap { tabsModel.safeGetTabAt($0) })
    }

    func selectModeDeselectAllTabs() {
        deselectAllTabs()
    }

    func selectModeSelectAllTabs() {
        selectAllTabs()
    }

}

// MARK: Long press menu actions
extension TabSwitcherViewController {

    func longPressMenuShareLink(index: Int) {
        guard let tab = tabsModel.safeGetTabAt(index) else { return }
        shareTabs([tab])
    }

    func longPressMenuBookmarkThisPage(index: Int) {
        bookmarkTabAt(index)
    }

    func longPressMenuBookmarkAllTabs(index: Int) {
        selectAllTabs()
    }

    func longPressMenuSelectTabs(index: Int) {
        if !isEditing {
            transitionToMultiSelect()
        }

        selectedTabs.insert(index)
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }

    func longPressMenuCloseTab(index: Int) {
        guard let tab = tabsModel.safeGetTabAt(index) else { return }
        deleteTab(tab: tab)
    }

    func longPressMenuCloseOtherTabs(index: Int) {
        closeOtherTabs(retainingIndexes: [index])
    }

}

// MARK: UIAction factories
extension TabSwitcherViewController {

    func action(_ title: String, _ imageNamed: String, destructive: Bool = false, _ handler: @escaping () -> Void) -> UIAction {
        let attributes: UIAction.Attributes = destructive ? .destructive : []
        return UIAction(title: title, image: UIImage(named: imageNamed), attributes: attributes) { _ in
            handler()
        }
    }

    func action(_ title: String, systemImage: String, destructive: Bool = false, _ handler: @escaping () -> Void) -> UIAction {
        let attributes: UIAction.Attributes = destructive ? .destructive : []
        return UIAction(title: title, image: UIImage(systemName: systemImage), attributes: attributes) { _ in
            handler()
        }
    }

    func action<T>(_ argument: T, _ title: String, _ imageName: String, destructive: Bool = false, _ action: @escaping (T) -> Void) -> UIAction {
        let attributes: UIAction.Attributes = destructive ? .destructive : []
        return UIAction(title: title, image: UIImage(named: imageName), attributes: attributes) { _ in
            action(argument)
        }
    }

}
