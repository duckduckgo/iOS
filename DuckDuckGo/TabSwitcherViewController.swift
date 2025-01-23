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

    @IBOutlet weak var topBarContainerView: UIView!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var fireButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!

    weak var delegate: TabSwitcherDelegate!
    weak var tabsModel: TabsModel!
    weak var previewsSource: TabPreviewsSource!

    private var bookmarksDatabase: CoreDataDatabase
    private let syncService: DDGSyncing

    weak var reorderGestureRecognizer: UIGestureRecognizer?

    override var canBecomeFirstResponder: Bool { return true }

    var currentSelection: Int?

    private var tabSwitcherSettings: TabSwitcherSettings = DefaultTabSwitcherSettings()
    private(set) var isProcessingUpdates = false
    private var canUpdateCollection = true

    let favicons = Favicons.shared
    let topBarModel = TabSwitcherTopBarModel()

    let featureFlagger: FeatureFlagger

    required init?(coder: NSCoder,
                   bookmarksDatabase: CoreDataDatabase,
                   syncService: DDGSyncing,
                   featureFlagger: FeatureFlagger) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.featureFlagger = featureFlagger
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    fileprivate func createTopBar() {
        topBarModel.delegate = self
        let hosting = UIHostingController(rootView: TabSwitcherTopBarView(model: topBarModel))
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.view.frame = .init(origin: .zero, size: topBarContainerView.frame.size)
        hosting.view.backgroundColor = nil
        topBarContainerView.addSubview(hosting.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createTopBar()

        refreshTitle()
        setupBackgroundView()
        currentSelection = tabsModel.currentIndex
        decorate()
        becomeFirstResponder()

        if !tabSwitcherSettings.hasSeenNewLayout {
            Pixel.fire(pixel: .tabSwitcherNewLayoutSeen)
            tabSwitcherSettings.hasSeenNewLayout = true
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if featureFlagger.isFeatureOn(.tabManagerMultiSelection) {
            if AppWidthObserver.shared.isLargeWidth {
                topBarModel.uiModel = .multiSelectLarge
            } else {
                topBarModel.uiModel = .multiSelectNormal
            }
        } else {
            if AppWidthObserver.shared.isLargeWidth {
                topBarModel.uiModel = .singleSelectLarge
            } else {
                topBarModel.uiModel = .singleSelectNormal
            }
        }

        toolbar.isHidden = AppWidthObserver.shared.isLargeWidth
   }

    private func setupBackgroundView() {
        let view = UIView(frame: collectionView.frame)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
        collectionView.backgroundView = view
    }

    private func refreshDisplayModeButton() {
        topBarModel.tabsStyle = tabSwitcherSettings.isGridViewEnabled ? .grid : .list
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if reorderGestureRecognizer == nil {
            let recognizer = UILongPressGestureRecognizer(target: self,
                                                          action: #selector(handleLongPress(gesture:)))
            collectionView.addGestureRecognizer(recognizer)
            reorderGestureRecognizer = recognizer
        }
    }

    func prepareForPresentation() {
        view.layoutIfNeeded()
        self.scrollToInitialTab()
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        dismiss()
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

    private func refreshTitle() {
        topBarModel.title = UserText.numberOfTabs(tabsModel.count)
    }

    fileprivate func displayBookmarkAllStatusMessage(with results: BookmarkAllResult, openTabsCount: Int) {
        if results.newCount == openTabsCount {
            ActionMessageView.present(message: UserText.bookmarkAllTabsSaved)
        } else {
            let failedToSaveCount = openTabsCount - results.newCount - results.existingCount
            Logger.general.debug("Failed to save \(failedToSaveCount) tabs")
            ActionMessageView.present(message: UserText.bookmarkAllTabsFailedToSave)
        }
    }

    private func bookmarkAll(viewModel: MenuBookmarksInteracting) -> BookmarkAllResult {
        let tabs = self.tabsModel.tabs
        var newCount = 0
        tabs.forEach { tab in
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
        dismiss()
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
        burn()
    }

    private func forgetAll() {
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
            } else if let fireButtonFrame = topBarModel.fireButtonFrame {
                let point = Point(x: Int(fireButtonFrame.midX),
                                  y: Int(fireButtonFrame.midY))
                self.present(controller: alert, fromView: topBarContainerView, atPoint: point)
            }
        }

        Pixel.fire(pixel: .forgetAllPressedTabSwitching)
        ViewHighlighter.hideAll()
        presentForgetDataAlert()
    }

    func startEditing() {
        // This will come in future PR.
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
    }

    func closeAllTabs() {
        delegate?.tabSwitcherDidRequestCloseAll(tabSwitcher: self)
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
        
        let cellIdentifier = tabSwitcherSettings.isGridViewEnabled ? TabViewGridCell.reuseIdentifier : TabViewListCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TabViewCell else {
            fatalError("Failed to dequeue cell \(cellIdentifier) as TabViewCell")
        }
        cell.delegate = self
        cell.isDeleting = false
        
        if indexPath.row < tabsModel.count {
            let tab = tabsModel.get(tabAt: indexPath.row)
            tab.addObserver(self)
            cell.update(withTab: tab,
                        preview: previewsSource.preview(for: tab),
                        reorderRecognizer: reorderGestureRecognizer)
        }
        
        return cell
    }
}

extension TabSwitcherViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Pixel.fire(pixel: .tabSwitcherSwitchTabs)
        currentSelection = indexPath.row
        markCurrentAsViewedAndDismiss()
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
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tabsModel.moveTab(from: sourceIndexPath.row, to: destinationIndexPath.row)
        currentSelection = tabsModel.currentIndex
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
        let heightToFit = (columnWidth / contentAspectRatio) + TabViewGridCell.Constants.cellHeaderHeight
        
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
        
        topBarContainerView.tintColor = theme.barTintColor

        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
                
        collectionView.reloadData()
    }
}
