//
//  TabViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class TabViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: TabViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blur()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.reloadData()
    }
    
    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        delegate?.createTab()
        dismiss()
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func onCloseAllPressed(_ sender: UIBarButtonItem) {
        delegate.clearAllTabs()
        dismiss()
    }
    
    func onSelected(tabAt index: Int) {
        delegate.select(tabAt: index)
        dismiss()
    }
    
    func onDeleted(tabAt index: Int) {
        delegate.remove(tabAt: index)
        collectionView.reloadData()
    }
    
    fileprivate func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension TabViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.tabDetails.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let link = delegate.tabDetails[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabViewCell.reuseIdentifier, for: indexPath) as! TabViewCell
        cell.title.text = link.title
        cell.link.text = link.url.absoluteString
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(onRemoveTapped(sender:)), for: .touchUpInside)
        cell.removeButton.isHidden = (delegate.tabDetails.count == 1)
        return cell
    }
    
    func onRemoveTapped(sender: UIView) {
        let index = sender.tag
        onDeleted(tabAt: index)
    }
}

extension TabViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected(tabAt: indexPath.row)
    }
    
}

extension TabViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 60)
    }
}
