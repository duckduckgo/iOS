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

class TabSwitcherViewController: UIViewController {

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

    fileprivate var hasSeenFooter = false
    
    override var canBecomeFirstResponder: Bool { return true }
    
    var currentSelection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTitle()
        currentSelection = tabsModel.currentIndex
        applyTheme(ThemeManager.shared.currentTheme)
        becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToInitialTab()
        delegate?.tabSwitcherDidAppear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.tabSwitcherDidDisappear(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nav = segue.destination as? UINavigationController,
            let controller = nav.topViewController as? SettingsViewController {
            controller.homePageSettingsDelegate = homePageSettingsDelegate
        }
        
    }
    
    private func scrollToInitialTab() {
        guard let index = tabsModel.currentIndex else { return }
        guard index < collectionView.numberOfItems(inSection: 0) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    private func refreshTitle() {
        titleView.text = UserText.numberOfTabs(tabsModel.count)
    }
    
    fileprivate func displayBookmarkAllStatusToast(with results: BookmarkAllResult, openTabsCount: Int) {
        if openTabsCount == results.newBookmarksCount + results.existingBookmarksCount {
            view.showBottomToast(UserText.bookmarkAllTabsSaved)
        } else {
            let failedToSaveCount = openTabsCount - results.newBookmarksCount - results.existingBookmarksCount
            Logger.log(text: "Failed to save \(failedToSaveCount) tabs")
            view.showBottomToast(UserText.bookmarkAllTabsFailedToSave)
        }
    }
    
    fileprivate func bookmarkAll(_ tabs: [Tab] ) -> BookmarkAllResult {
        
        let bookmarksManager = BookmarksManager()
        var newBookmarksCount: Int = 0
        var existingBookmarksCount: Int = 0
        
        for aTab in tabs {
            if let link = aTab.link {
                if bookmarksManager.contains(url: link.url) {
                    existingBookmarksCount += 1
                } else {
                    bookmarksManager.save(bookmark: link)
                    newBookmarksCount += 1
                }
            } else {
                Logger.log(text: "no valid link found for tab \(aTab)")
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
        Pixel.fire(pixel: .settingsOpened)
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
        
        present(controller: alert, fromView: toolbar)
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
        delegate.tabSwitcher(self, didRemoveTab: tab)
        currentSelection = tabsModel.currentIndex
        refreshTitle()
        collectionView.reloadData()
    }
    
    func isCurrent(tab: Tab) -> Bool {
        return currentSelection == tabsModel.indexOf(tab: tab)
    }

}

extension TabSwitcherViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabsModel.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tab = tabsModel.get(tabAt: indexPath.row)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabViewCell.reuseIdentifier, for: indexPath) as? TabViewCell else {
            fatalError("Failed to dequeue cell \(TabViewCell.reuseIdentifier) as TablViewCell")
        }
        cell.delegate = self
        cell.update(withTab: tab)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseIdentifier = TabsFooter.reuseIdentifier
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: reuseIdentifier,
                                                                         for: indexPath) as? TabsFooter else {
            fatalError("Failed to dequeue footer \(TabsFooter.reuseIdentifier) as TabsFooter")
        }
        view.decorate(with: ThemeManager.shared.currentTheme)
        return view
    }

}

extension TabSwitcherViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelection = indexPath.row
        markCurrentAsViewedAndDismiss()
    }
}

extension TabSwitcherViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 70)
    }

}

extension TabSwitcherViewController: Themable {
    
    func decorate(with theme: Theme) {
        titleView.textColor = theme.tintOnBlurColor
        settingsButton.tintColor = theme.tintOnBlurColor
        bookmarkAllButton.tintColor = theme.tintOnBlurColor
        
        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
    }
}
