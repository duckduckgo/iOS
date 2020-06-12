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
import Core
import WebKit
import os.log

class TabSwitcherViewController: UIViewController {
    
    struct Constants {
        static let prefferedMinNumberOfRows: CGFloat = 3.5

        static let cellMinHeight: CGFloat = 140.0
        static let cellMaxHeight: CGFloat = 209.0
    }

    typealias BookmarkAllResult = (newBookmarksCount: Int, existingBookmarksCount: Int)
    
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var bookmarkAllButton: UIButton!
    
    @IBOutlet weak var fireButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    
    weak var homePageSettingsDelegate: HomePageSettingsDelegate?
    weak var delegate: TabSwitcherDelegate!
    weak var tabsModel: TabsModel!
    weak var previewsSource: TabPreviewsSource!
    
    weak var reorderGestureRecognizer: UIGestureRecognizer?
    
    override var canBecomeFirstResponder: Bool { return true }
    
    var currentSelection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTitle()
        setupBackgroundView()
        currentSelection = tabsModel.currentIndex
        applyTheme(ThemeManager.shared.currentTheme)
        becomeFirstResponder()
    }
    
    func setupBackgroundView() {
        let view = UIView(frame: collectionView.frame)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
        collectionView.backgroundView = view
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.tabSwitcherDidAppear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.tabSwitcherDidDisappear(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nav = segue.destination as? UINavigationController,
            let controller = nav.topViewController as? SettingsViewController {
            controller.homePageSettingsDelegate = homePageSettingsDelegate
        }
        
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
    
    fileprivate func displayBookmarkAllStatusToast(with results: BookmarkAllResult, openTabsCount: Int) {
        if openTabsCount == results.newBookmarksCount + results.existingBookmarksCount {
            view.showBottomToast(UserText.bookmarkAllTabsSaved)
        } else {
            let failedToSaveCount = openTabsCount - results.newBookmarksCount - results.existingBookmarksCount
            os_log("Failed to save %d tabs", log: generalLog, type: .debug, failedToSaveCount)
            view.showBottomToast(UserText.bookmarkAllTabsFailedToSave)
        }
    }
    
    fileprivate func bookmarkAll(_ tabs: [Tab] ) -> BookmarkAllResult {
        
        let bookmarksManager = BookmarksManager()
        var newBookmarksCount: Int = 0
        var existingBookmarksCount: Int = 0
        
        tabs.forEach { tab in
            if let link = tab.link {
                if bookmarksManager.contains(url: link.url) {
                    existingBookmarksCount += 1
                } else {
                    bookmarksManager.save(bookmark: link)
                    newBookmarksCount += 1
                }
            } else {
                os_log("no valid link found for tab %s", log: generalLog, type: .debug, String(describing: tab))
            }
        }
        
        return (newBookmarksCount: newBookmarksCount, existingBookmarksCount: existingBookmarksCount)
    }
    
    @IBAction func onBookmarkAllOpenTabsPressed(_ sender: UIButton) {
        
        guard tabsModel.tabs.count > 0 else {
            view.showBottomToast(UserText.bookmarkAllTabsNotFound)
            return
        }
        
        let alert = UIAlertController(title: UserText.alertBookmarkAllTitle,
                                      message: UserText.alertBookmarkAllMessage,
                                      preferredStyle: .alert)
        alert.overrideUserInterfaceStyle()
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        alert.addAction(title: UserText.actionBookmark, style: .default) {
            let savedState = self.bookmarkAll(self.tabsModel.tabs)
            self.displayBookmarkAllStatusToast(with: savedState, openTabsCount: self.tabsModel.tabs.count)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onSettingsPressed(_ sender: UIButton) {
        // Segue performed from storyboard
        Pixel.fire(pixel: .settingsOpenedFromTabsSwitcher)
    }

    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    func markCurrentAsViewedAndDismiss() {
        if let current = currentSelection {
            let tab = tabsModel.get(tabAt: current)
            tab.viewed = true
            tabsModel.save()
            delegate?.tabSwitcher(self, didSelectTab: tab)
        }
        dismiss()
    }

    @IBAction func onFirePressed() {
        Pixel.fire(pixel: .forgetAllPressedTabSwitching)
        
        let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
            self?.forgetAll()
        })
        self.present(controller: alert, fromView: self.toolbar)
        
    }

    private func forgetAll() {
        self.delegate.tabSwitcherDidRequestForgetAll(tabSwitcher: self)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension TabSwitcherViewController: TabViewCellDelegate {

    func deleteTab(tab: Tab) {
        guard let index = tabsModel.indexOf(tab: tab) else { return }
        let isLastTab = tabsModel.count == 1
        if isLastTab {
            delegate.tabSwitcher(self, didRemoveTab: tab)
            currentSelection = tabsModel.currentIndex
            refreshTitle()
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates({
                delegate.tabSwitcher(self, didRemoveTab: tab)
                currentSelection = tabsModel.currentIndex
                collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            }, completion: { _ in
                guard let current = self.currentSelection else { return }
                self.refreshTitle()
                self.collectionView.reloadItems(at: [IndexPath(row: current, section: 0)])
            })
        }
    }
    
    func isCurrent(tab: Tab) -> Bool {
        return currentSelection == tabsModel.indexOf(tab: tab)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabViewCell.reuseIdentifier, for: indexPath) as? TabViewCell else {
            fatalError("Failed to dequeue cell \(TabViewCell.reuseIdentifier) as TablViewCell")
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
        let heightToFit = (columnWidth / contentAspectRatio) + TabViewCell.Constants.cellHeaderHeight
        
        // Try to display at least `prefferedMinNumberOfRows`
        let prefferedMaxHeight = collectionView.bounds.height / Constants.prefferedMinNumberOfRows
        let prefferedHeight = min(prefferedMaxHeight, heightToFit)
        
        return min(Constants.cellMaxHeight,
                   max(Constants.cellMinHeight, prefferedHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let columnWidth = calculateColumnWidth(minimumColumnWidth: 150, maxColumns: 4)
        let rowHeight = calculateRowHeight(columnWidth: columnWidth)
        return CGSize(width: floor(columnWidth),
                      height: floor(rowHeight))
    }
    
}

extension TabSwitcherViewController: TabObserver {
    
    func didChange(tab: Tab) {
        if let index = tabsModel.indexOf(tab: tab) {
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
}

extension TabSwitcherViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        titleView.textColor = theme.barTintColor
        settingsButton.tintColor = theme.barTintColor
        bookmarkAllButton.tintColor = theme.barTintColor
        
        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
        
        collectionView.reloadData()
    }
}
