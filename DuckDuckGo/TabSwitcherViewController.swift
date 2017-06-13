//
//  TabSwitcherViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core
import WebKit

class TabSwitcherViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var animationContainer: UIView!
    
    weak var delegate: TabSwitcherDelegate!
    private var initialIndex: Int?
    
    static func loadFromStoryboard(delegate: TabSwitcherDelegate, scrollTo index: Int?) -> TabSwitcherViewController {
        let controller = UIStoryboard(name: "TabSwitcher", bundle: nil).instantiateInitialViewController() as! TabSwitcherViewController
        controller.delegate = delegate
        controller.initialIndex = index
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToInitialTab()
    }
    
    private func scrollToInitialTab() {
        guard let index = initialIndex else { return }
        guard index < collectionView.numberOfItems(inSection: 0) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        collectionView.reloadData()
    }
    
    private func refreshTitle() {
        let count = delegate.tabDetails.count
        titleView.text = count == 0 ? UserText.tabSwitcherTitleNoTabs : UserText.tabSwitcherTitleHasTabs
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        delegate.tabSwitcherDidRequestNewTab(tabSwitcher: self)
        dismiss()
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func onClearAllPressed(_ sender: UIButton) {
        WKWebView.clearCache {
            Logger.log(text: "Cache cleared")
        }
        animateFire {
            self.delegate.tabSwitcherDidRequestClearAll(tabSwitcher: self)
            self.collectionView.reloadData()
            self.refreshTitle()
        }
    }
    
    private func animateFire(withCompletion completion: @escaping () -> Swift.Void) {
        let nativeSize = #imageLiteral(resourceName: "FireLarge").size
        let fireView = UIImageView(image: #imageLiteral(resourceName: "FireLargeStretchable"))
        animationContainer.isHidden = false
        animationContainer.addSubview(fireView)
        fireView.frame.size = CGSize(width: nativeSize.width, height: nativeSize.height+animationContainer.frame.size.height)
        fireView.transform.ty = animationContainer.frame.size.height
        UIView.animate(withDuration: 2, animations: {
            fireView.transform.ty = -nativeSize.height
        }) { _ in
            completion()
            fireView.removeFromSuperview()
            self.animationContainer.isHidden = true
        }
    }
    
    func onSelected(tabAt index: Int) {
        delegate.tabSwitcher(self, didSelectTabAt: index)
        dismiss()
    }
    
    func onDeleted(tabAt index: Int) {
        delegate.tabSwitcher(self, didRemoveTabAt: index)
        collectionView.reloadData()
        refreshTitle()
    }
    
    fileprivate func dismiss() {
        if delegate.tabDetails.isEmpty {
            delegate.tabSwitcherDidRequestClearAll(tabSwitcher: self)
        }
        dismiss(animated: true, completion: nil)
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
        return CGSize(width: collectionView.bounds.size.width, height: 70)
    }

}
