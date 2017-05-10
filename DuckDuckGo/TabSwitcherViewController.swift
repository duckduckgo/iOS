//
//  TabSwitcherViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class TabSwitcherViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: TabSwitcherDelegate!
    
    static func loadFromStoryboard(delegate: TabSwitcherDelegate) -> TabSwitcherViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabSwitcherViewController") as! TabSwitcherViewController
        controller.delegate = delegate
        return controller
    }
    
    override func viewWillLayoutSubviews() {
        collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onAddPressed(_ sender: UIButton) {
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func onCloseAllPressed(_ sender: UIButton) {
        delegate.tabSwitcherDidRequestClearAll(tabSwitcher: self)
        dismiss()
    }
    
    func onSelected(tabAt index: Int) {
        delegate.tabSwitcher(self, didSelectTabAt: index)
        dismiss()
    }
    
    func onDeleted(tabAt index: Int) {
        delegate.tabSwitcher(self, didRemoveTabAt: index)
        collectionView.reloadData()
    }
    
    fileprivate func dismiss() {
        if delegate.tabDetails.isEmpty {
            delegate.tabSwitcherDidRequestClearAll(tabSwitcher: self)
        }
        dismiss(animated: false, completion: nil)
    }
}

extension TabSwitcherViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.tabDetails.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let link = delegate.tabDetails[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabViewCell.reuseIdentifier, for: indexPath) as! TabViewCell
        cell.update(withLink: link)
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(onRemoveTapped(sender:)), for: .touchUpInside)
        return cell
    }
    
    func onRemoveTapped(sender: UIView) {
        let index = sender.tag
        onDeleted(tabAt: index)
    }
}

extension TabSwitcherViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected(tabAt: indexPath.row)
    }
    
}

extension TabSwitcherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 60)
    }
}
