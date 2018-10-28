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

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var fireButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!

    weak var delegate: TabSwitcherDelegate!
    weak var tabsModel: TabsModel!

    fileprivate var hasSeenFooter = false

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToInitialTab()
    }

    private func scrollToInitialTab() {
        guard let index = tabsModel.currentIndex else { return }
        guard index < collectionView.numberOfItems(inSection: 0) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }

    private func refreshTitle() {
        let count = tabsModel.count
        titleView.text = count == 0 ? UserText.tabSwitcherTitleNoTabs : UserText.tabSwitcherTitleHasTabs
    }

    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if let current = tabsModel.currentIndex {
            tabsModel.get(tabAt: current).viewed = true
            tabsModel.save()
        }
        dismiss()
    }

    @IBAction func onFirePressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: UserText.actionForgetAll, style: .destructive) { [weak self] _ in
            self?.forgetAll()
        })
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: toolbar)
    }

    private func forgetAll() {
        self.delegate.tabSwitcherDidRequestForgetAll(tabSwitcher: self)
    }

    fileprivate func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension TabSwitcherViewController: TabViewCellDelegate {

    func deleteTab(tab: Tab) {
        let index = tabsModel.indexOf(tab: tab)

        delegate.tabSwitcher(self, didRemoveTab: tab)
        refreshTitle()

        if let index = index {
            collectionView.deleteItems(at: [ IndexPath(row: index, section: 0) ])
        } else {
            collectionView.reloadData()
        }
    }
    
    func isCurrent(tab: Tab) -> Bool {
        return tabsModel.currentIndex == tabsModel.indexOf(tab: tab)
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
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? TabsFooter else {
            fatalError("Failed to dequeue footer \(TabsFooter.reuseIdentifier) as TabsFooter")
        }
        view.applyTheme(ThemeManager.shared.currentTheme)
        return view
    }

}

extension TabSwitcherViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TabViewCell else {
            fatalError("Failed to load cell as TabViewCell")
        }
        guard let tab = cell.tab else { return }
        tab.viewed = true
        delegate.tabSwitcher(self, didSelectTab: tab)
        dismiss()
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
        
        toolbar.barTintColor = theme.barBackgroundColor
        toolbar.tintColor = theme.barTintColor
        
        collectionView.reloadData()
    }
}
