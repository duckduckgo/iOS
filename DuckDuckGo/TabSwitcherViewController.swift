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

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
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
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var displayModeButton: UIButton!
    @IBOutlet weak var bookmarkAllButton: UIButton!
    
    @IBOutlet weak var fireButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    
    @IBOutlet weak var topFireButton: UIButton!
    @IBOutlet weak var topPlusButton: UIButton!
    @IBOutlet weak var topDoneButton: UIButton!

    @IBOutlet var displayModeTrailingConstraint: NSLayoutConstraint!

    weak var delegate: TabSwitcherDelegate!
    weak var tabsModel: TabsModel!
    weak var previewsSource: TabPreviewsSource!
    
    private var bookmarksDatabase: CoreDataDatabase
    private let syncService: DDGSyncing
    
    weak var reorderGestureRecognizer: UIGestureRecognizer?
    
    override var canBecomeFirstResponder: Bool { return true }
    
    var currentSelection: Int?
    
    private var tabSwitcherSettings: TabSwitcherSettings = DefaultTabSwitcherSettings()
    private var isProcessingUpdates = false
    private var canUpdateCollection = true

    let favicons = Favicons.shared
    
    required init?(coder: NSCoder,
                   bookmarksDatabase: CoreDataDatabase,
                   syncService: DDGSyncing) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTitle()
        setupBackgroundView()
        currentSelection = tabsModel.currentIndex
        applyTheme(ThemeManager.shared.currentTheme)
        becomeFirstResponder()
        
        if !tabSwitcherSettings.hasSeenNewLayout {
            Pixel.fire(pixel: .tabSwitcherNewLayoutSeen)
            tabSwitcherSettings.hasSeenNewLayout = true
        }
        
        displayModeButton.isPointerInteractionEnabled = true
        bookmarkAllButton.isPointerInteractionEnabled = true
        topFireButton.isPointerInteractionEnabled = true
        topPlusButton.isPointerInteractionEnabled = true
        topDoneButton.isPointerInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbar.isHidden = AppWidthObserver.shared.isLargeWidth
        displayModeTrailingConstraint.isActive = !AppWidthObserver.shared.isLargeWidth
        topFireButton.isHidden = !AppWidthObserver.shared.isLargeWidth
        topDoneButton.isHidden = !AppWidthObserver.shared.isLargeWidth
        topPlusButton.isHidden = !AppWidthObserver.shared.isLargeWidth
    }
    
    private func setupBackgroundView() {
        let view = UIView(frame: collectionView.frame)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
        collectionView.backgroundView = view
    }
    
    private func refreshDisplayModeButton(theme: Theme = ThemeManager.shared.currentTheme) {
        switch theme.currentImageSet {
        case .dark:
            if tabSwitcherSettings.isGridViewEnabled {
                displayModeButton.setImage(UIImage(named: "tabsToggleGrid-Dark"), for: .normal)
            } else {
                displayModeButton.setImage(UIImage(named: "tabsToggleList-Dark"), for: .normal)
            }
        case .light:
            if tabSwitcherSettings.isGridViewEnabled {
                displayModeButton.setImage(UIImage(named: "tabsToggleGrid-Light"), for: .normal)
            } else {
                displayModeButton.setImage(UIImage(named: "tabsToggleList-Light"), for: .normal)
            }
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            DaxDialogs.shared.fireButtonPulseStarted()
            guard let window = view.window else { return }
            
            let fireButtonView: UIView?
            if !topFireButton.isHidden {
                fireButtonView = topFireButton
            } else {
                fireButtonView = fireButton.value(forKey: "view") as? UIView
            }
            guard let view = fireButtonView else { return }
            
            if !ViewHighlighter.highlightedViews.contains(where: { $0.view == view }) {
                ViewHighlighter.hideAll()
                ViewHighlighter.showIn(window, focussedOnView: view)
            }
        }
    }
    
    func prepareForPresentation() {
        view.layoutIfNeeded()
        self.scrollToInitialTab()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        ViewHighlighter.hideAll()
        
        if let controller = segue.destination as? ActionSheetDaxDialogViewController {
            let spec = sender as? DaxDialogs.ActionSheetSpec
            controller.spec = spec
            controller.delegate = self
        }

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
        titleView.text = UserText.numberOfTabs(tabsModel.count)
    }
    
    fileprivate func displayBookmarkAllStatusMessage(with results: BookmarkAllResult, openTabsCount: Int) {
        if results.newCount == openTabsCount {
            ActionMessageView.present(message: UserText.bookmarkAllTabsSaved)
        } else {
            let failedToSaveCount = openTabsCount - results.newCount - results.existingCount
            os_log("Failed to save %d tabs", log: .generalLog, type: .debug, failedToSaveCount)
            ActionMessageView.present(message: UserText.bookmarkAllTabsFailedToSave)
        }
    }
   
    @IBAction func onBookmarkAllOpenTabsPressed(_ sender: UIButton) {
         
        let alert = UIAlertController(title: UserText.alertBookmarkAllTitle,
                                      message: UserText.alertBookmarkAllMessage,
                                      preferredStyle: .alert)
        alert.overrideUserInterfaceStyle()
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        alert.addAction(title: UserText.actionBookmark, style: .default) {
            let model = MenuBookmarksViewModel(bookmarksDatabase: self.bookmarksDatabase, syncService: self.syncService)
            model.favoritesDisplayMode = AppDependencyProvider.shared.appSettings.favoritesDisplayMode
            let result = self.bookmarkAll(viewModel: model)
            self.displayBookmarkAllStatusMessage(with: result, openTabsCount: self.tabsModel.tabs.count)
        }
        
        present(alert, animated: true, completion: nil)
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
    
    @IBAction func onDisplayModeButtonPressed(_ sender: UIButton) {
        tabSwitcherSettings.isGridViewEnabled = !tabSwitcherSettings.isGridViewEnabled
        
        if tabSwitcherSettings.isGridViewEnabled {
            Pixel.fire(pixel: .tabSwitcherGridEnabled)
        } else {
            Pixel.fire(pixel: .tabSwitcherListEnabled)
        }
        
        refreshDisplayModeButton()
        
        UIView.transition(with: view,
                          duration: 0.3,
                          options: .transitionCrossDissolve, animations: {
                            self.collectionView.reloadData()
        }, completion: nil)
    }

    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
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
        Pixel.fire(pixel: .forgetAllPressedTabSwitching)
        
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            let spec = DaxDialogs.shared.fireButtonEducationMessage()
            performSegue(withIdentifier: "ActionSheetDaxDialog", sender: spec)
        } else {
            let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
                self?.forgetAll()
            })
            
            if let anchor = sender as? UIView {
                self.present(controller: alert, fromView: anchor)
            } else {
                self.present(controller: alert, fromView: toolbar)
            }
        }
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

        if let index = tabsModel.indexOf(tab: tab), index < collectionView.numberOfItems(inSection: 0) {
            if #available(iOS 15.0, *) {
                collectionView.reconfigureItems(at: [IndexPath(row: index, section: 0)])
            } else {
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
}

extension TabSwitcherViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        refreshDisplayModeButton(theme: theme)
        
        titleView.textColor = theme.barTintColor
        bookmarkAllButton.tintColor = theme.barTintColor
        topDoneButton.tintColor = theme.barTintColor
        topPlusButton.tintColor = theme.barTintColor
        topFireButton.tintColor = theme.barTintColor
        
        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
                
        collectionView.reloadData()
    }
}
// swiftlint:enable file_length
