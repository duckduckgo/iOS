//
//  TabSwitcherViewController.swift
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
import Common
import Core
import DDGSync
import WebKit
import Bookmarks
import Persistence
import os.log
import SwiftUI
import BrowserServicesKit

class TabSwitcherViewController: UIViewController {

    struct Constants {
        static let preferredMinNumberOfRows: CGFloat = 2.7

        static let cellMinHeight: CGFloat = 140.0
        static let cellMaxHeight: CGFloat = 209.0
    }

    struct BookmarkAllResult {
        let newCount: Int
        let existingCount: Int
    }

    enum InterfaceMode {

        var isMultiSelection: Bool {
            return !isSingleSelection
        }

        var isSingleSelection: Bool {
            return [InterfaceMode.singleSelectNormal, .singleSelectLarge].contains(self)
        }

        var isLarge: Bool {
            return [InterfaceMode.singleSelectLarge, .multiSelectAvailableLarge, .multiSelectedEditingLarge].contains(self)
        }

        var isNormal: Bool {
            return !isLarge
        }

        case singleSelectNormal
        case singleSelectLarge
        case multiSelectAvailableNormal
        case multiSelectAvailableLarge
        case multiSelectEditingNormal
        case multiSelectedEditingLarge

    }

    enum TabsStyle: String {

        case list = "tabsToggleList"
        case grid = "tabsToggleGrid"

    }

    @IBOutlet weak var topBarView: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!

    weak var delegate: TabSwitcherDelegate!
    weak var tabsModel: TabsModel!
    weak var previewsSource: TabPreviewsSource!

    private(set) var bookmarksDatabase: CoreDataDatabase
    let syncService: DDGSyncing

    override var canBecomeFirstResponder: Bool { return true }

    var currentSelection: Int?

    var tabSwitcherSettings: TabSwitcherSettings = DefaultTabSwitcherSettings()
    var isProcessingUpdates = false
    private var canUpdateCollection = true

    let favicons: Favicons

    var tabsStyle: TabsStyle = .list
    var interfaceMode: InterfaceMode = .singleSelectNormal

    let featureFlagger: FeatureFlagger

    let barsHandler = TabSwitcherBarsStateHandler()

    required init?(coder: NSCoder,
                   bookmarksDatabase: CoreDataDatabase,
                   syncService: DDGSyncing,
                   featureFlagger: FeatureFlagger,
                   favicons: Favicons = Favicons.shared) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.featureFlagger = featureFlagger
        self.favicons = favicons
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    fileprivate func createTopBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        topBarView.standardAppearance = appearance
        topBarView.scrollEdgeAppearance = appearance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createTopBar()

        refreshTitle()
        setupBackgroundView()
        currentSelection = tabsModel.currentIndex
        decorate()
        becomeFirstResponder()
        updateUIForSelectionMode()

        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true

        if !tabSwitcherSettings.hasSeenNewLayout {
            Pixel.fire(pixel: .tabSwitcherNewLayoutSeen)
            tabSwitcherSettings.hasSeenNewLayout = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUIForSelectionMode()
    }

    private func setupBackgroundView() {
        let view = UIView(frame: collectionView.frame)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
        collectionView.backgroundView = view
    }

    func refreshDisplayModeButton() {
        tabsStyle = tabSwitcherSettings.isGridViewEnabled ? .grid : .list
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        updateUIForSelectionMode()
    }

    func prepareForPresentation() {
        view.layoutIfNeeded()
        self.scrollToInitialTab()
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        // TODO FIX: If the user taps between tabs this will dismiss.
        //  Only dimiss if it's in the big whitespace below the collection view.

        if isEditing {
            transitionFromMultiSelect()
        } else {
            dismiss()
        }
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let path = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView.beginInteractiveMovementForItem(at: path)

        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))

        case .ended:
            collectionView.endInteractiveMovement()

        default:
            collectionView.cancelInteractiveMovement()
        }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func scrollToInitialTab() {
        let index = tabsModel.currentIndex
        guard index < collectionView.numberOfItems(inSection: 0) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }

    func refreshTitle() {
        topBarView.topItem?.title = UserText.numberOfTabs(tabsModel.count)
    }

    func displayBookmarkAllStatusMessage(with results: BookmarkAllResult, openTabsCount: Int) {
        if interfaceMode.isMultiSelection {
            ActionMessageView.present(message: UserText.tabsBookmarked(withCount: results.newCount))
        } else {
            ActionMessageView.present(message: UserText.bookmarkAllTabsSaved)
        }
    }

    func bookmarkTabs(withIndices indexes: [Int], viewModel: MenuBookmarksInteracting) -> BookmarkAllResult {
        let tabs = self.tabsModel.tabs
        var newCount = 0

        indexes.compactMap {
            tabsModel.safeGetTabAt($0)
        }.forEach { tab in
            guard let link = tab.link else { return }
            if viewModel.bookmark(for: link.url) == nil {
                viewModel.createBookmark(title: link.displayTitle, url: link.url)
                favicons.loadFavicon(forDomain: link.url.host, intoCache: .fireproof, fromCache: .tabs)
                newCount += 1
            }
        }
        return .init(newCount: newCount, existingCount: tabs.count - newCount)
    }

    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        addNewTab()
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if isEditing {
            transitionFromMultiSelect()
        } else {
            dismiss()
        }
    }
    
    func markCurrentAsViewedAndDismiss() {
        // Will be dismissed, so no need to process incoming updates
        canUpdateCollection = false

        if let current = currentSelection {
            let tab = tabsModel.get(tabAt: current)
            tab.viewed = true
            tabsModel.save()
            delegate?.tabSwitcher(self, didSelectTab: tab)
        }
        dismiss()
    }

    @IBAction func onFirePressed(sender: AnyObject) {
        burn(sender: sender)
    }

    func forgetAll() {
        self.delegate.tabSwitcherDidRequestForgetAll(tabSwitcher: self)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        canUpdateCollection = false
        tabsModel.tabs.forEach { $0.removeObserver(self) }
        super.dismiss(animated: animated, completion: completion)
    }
}

extension TabSwitcherViewController: TabViewCellDelegate {

    func deleteTab(tab: Tab) {
        guard let index = tabsModel.indexOf(tab: tab) else { return }
        let isLastTab = tabsModel.count == 1
        if isLastTab {
            // Will be dismissed, so no need to process incoming updates
            canUpdateCollection = false

            delegate.tabSwitcher(self, didRemoveTab: tab)
            currentSelection = tabsModel.currentIndex
            refreshTitle()
            collectionView.reloadData()
            DispatchQueue.global(qos: .background).async {
                Favicons.shared.clearCache(.tabs, clearMemoryCache: true)
            }
        } else {
            collectionView.performBatchUpdates({
                isProcessingUpdates = true
                delegate.tabSwitcher(self, didRemoveTab: tab)
                currentSelection = tabsModel.currentIndex
                collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            }, completion: { _ in
                self.isProcessingUpdates = false
                guard let current = self.currentSelection else { return }
                self.refreshTitle()
                self.collectionView.reloadItems(at: [IndexPath(row: current, section: 0)])
                
                // remove favicon from tabs cache when no other tabs have that domain
                self.removeFavicon(forTab: tab)
            })
        }
    }
    
    func isCurrent(tab: Tab) -> Bool {
        return currentSelection == tabsModel.indexOf(tab: tab)
    }

    private func removeFavicon(forTab tab: Tab) {
        DispatchQueue.global(qos: .background).async {
            if let currentHost = tab.link?.url.host,
               !self.tabsModel.tabExists(withHost: currentHost) {
                Favicons.shared.removeTabFavicon(forDomain: currentHost)
            }
        }
    }

}

extension TabSwitcherViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabsModel.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = tabSwitcherSettings.isGridViewEnabled ? TabViewCell.gridReuseIdentifier : TabViewCell.listReuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TabViewCell else {
            fatalError("Failed to dequeue cell \(cellIdentifier) as TabViewCell")
        }
        cell.delegate = self
        cell.isDeleting = false
        
        if indexPath.row < tabsModel.count {
            let tab = tabsModel.get(tabAt: indexPath.row)
            tab.addObserver(self)
            cell.update(withTab: tab,
                        isSelectionModeEnabled: self.isEditing,
                        preview: previewsSource.preview(for: tab))
        }
        
        return cell
    }
}

extension TabSwitcherViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Pixel.fire(pixel: .tabSwitcherSwitchTabs)
        currentSelection = indexPath.row
        if isEditing {
            (collectionView.cellForItem(at: indexPath) as? TabViewCell)?.toggleSelection()
            updateUIForSelectionMode()
        } else {
            markCurrentAsViewedAndDismiss()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? TabViewCell)?.toggleSelection()
        updateUIForSelectionMode()
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

        assert(!indexPaths.isEmpty)

        guard interfaceMode.isMultiSelection else { return nil }

        let title = indexPaths.count == 1 ?
            trimMenuTitleIfNeeded(tabsModel.get(tabAt: indexPaths[0].row).link?.displayTitle ?? "", 50) :
            UserText.numberOfTabs(indexPaths.count)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let menuItems = indexPaths.count == 1 ?
                self.createLongPressMenuItemsForSingleTab(forIndex: indexPaths[0].row) :
                self.createLongPressMenuItemsForMultipleTabs()
            return UIMenu(title: title, children: menuItems.compactMap { $0 })
        }

    }

}

extension TabSwitcherViewController: UICollectionViewDelegateFlowLayout {

    private func calculateColumnWidth(minimumColumnWidth: CGFloat, maxColumns: Int) -> CGFloat {
        // Spacing is supposed to be equal between cells and on left/right side of the collection view
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let spacing = layout?.sectionInset.left ?? 0.0
        
        let contentWidth = collectionView.bounds.width - spacing
        let numberOfColumns = min(maxColumns, Int(contentWidth / minimumColumnWidth))
        return contentWidth / CGFloat(numberOfColumns) - spacing
    }
    
    private func calculateRowHeight(columnWidth: CGFloat) -> CGFloat {
        
        // Calculate height based on the view size
        let contentAspectRatio = collectionView.bounds.width / collectionView.bounds.height
        let heightToFit = (columnWidth / contentAspectRatio) + TabViewCell.Constants.cellHeaderHeight
        
        // Try to display at least `preferredMinNumberOfRows`
        let preferredMaxHeight = collectionView.bounds.height / Constants.preferredMinNumberOfRows
        let preferredHeight = min(preferredMaxHeight, heightToFit)
        
        return min(Constants.cellMaxHeight,
                   max(Constants.cellMinHeight, preferredHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if tabSwitcherSettings.isGridViewEnabled {
            let columnWidth = calculateColumnWidth(minimumColumnWidth: 150, maxColumns: 4)
            let rowHeight = calculateRowHeight(columnWidth: columnWidth)
            return CGSize(width: floor(columnWidth),
                          height: floor(rowHeight))
        } else {
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let spacing = layout?.sectionInset.left ?? 0.0
            
            let width = min(664, collectionView.bounds.size.width - 2 * spacing)
            
            return CGSize(width: width, height: 70)
        }
    }
    
}

extension TabSwitcherViewController: TabObserver {
    
    func didChange(tab: Tab) {
        // Reloading when updates are processed will result in a crash
        guard !isProcessingUpdates, canUpdateCollection else {
            return
        }

        collectionView.performBatchUpdates({}, completion: { [weak self] completed in
            guard completed, let self = self else { return }
            if let index = self.tabsModel.indexOf(tab: tab), index < self.collectionView.numberOfItems(inSection: 0) {
                self.collectionView.reconfigureItems(at: [IndexPath(row: index, section: 0)])
            }
        })
    }
}

extension TabSwitcherViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        
        refreshDisplayModeButton()
        
        topBarView.tintColor = theme.barTintColor

        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
                
        collectionView.reloadData()
    }
}

extension TabSwitcherViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView.cellForItem(at: indexPath),
              let snapshot = cell.createImageSnapshot() else { return [] }
        return [.init(itemProvider: .init(object: snapshot))]
    }

}

extension TabSwitcherViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: any UIDropSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {

        guard let destination = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let source = item.sourceIndexPath
        else {
            // This can happen if the menu is shown and the user then drags to an invalid location
            return
        }

        collectionView.performBatchUpdates {
            tabsModel.moveTab(from: source.row, to: destination.row)
            currentSelection = tabsModel.currentIndex
            collectionView.deleteItems(at: [source])
            collectionView.insertItems(at: [destination])
        } completion: { _ in
            if self.isEditing {
                collectionView.reloadData()
                collectionView.selectItem(at: destination, animated: true, scrollPosition: [])
            } else {
                collectionView.reloadItems(at: [IndexPath(row: self.currentSelection ?? 0, section: 0)])
            }
            self.delegate.tabSwitcherDidReorderTabs(tabSwitcher: self)
        }

        coordinator.drop(item.dragItem, toItemAt: destination)
    }

}
