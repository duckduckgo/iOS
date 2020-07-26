//
//  TabsBarViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 25/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

protocol TabsBarDelegate: NSObjectProtocol {

    func tabsBarRequestingTabCount(_ tabsBarViewController: TabsBarViewController) -> Int
    func tabsBarRequestingTab(_ tabsBarViewController: TabsBarViewController, atIndex: Int) -> Tab?
    func tabsBarSelectingTab(_ tabsBarViewController: TabsBarViewController, atIndex: Int)

}

class TabsBarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var addTabButton: UIButton!
    @IBOutlet weak var tabSwitcherContainer: UIView!

    weak var delegate: TabsBarDelegate?

    let tabSwitcherButton = TabSwitcherButton()
    let flowLayout = UICollectionViewFlowLayout()

    var tabsCount: Int {
        return delegate?.tabsBarRequestingTabCount(self) ?? 0
    }

    var maxItems: Int {
        return Int(collectionView.frame.size.width / 110)
    }

    var numberOfItems: Int {
        return min(tabsCount, maxItems)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)

        tabSwitcherContainer.addSubview(tabSwitcherButton)

        collectionView.collectionViewLayout = flowLayout
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemWidth = collectionView.frame.size.width / CGFloat(numberOfItems)
        flowLayout.itemSize = CGSize(width: itemWidth, height: 40)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabSwitcherButton.layoutSubviews()
    }

    func refresh() {
        collectionView.reloadData()
        tabSwitcherButton.tabCount = delegate?.tabsBarRequestingTabCount(self) ?? 0
    }

}

extension TabsBarViewController: UICollectionViewDelegate {

}

extension TabsBarViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("***", #function, numberOfItems, tabsCount, maxItems)
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath)
    }

}

extension TabsBarViewController: Themable {

    func decorate(with theme: Theme) {
        view.backgroundColor = theme.padBackgroundColor
        view.tintColor = theme.barTintColor
        collectionView.backgroundColor = theme.padBackgroundColor
        tabSwitcherContainer.backgroundColor = theme.padBackgroundColor
        tabSwitcherButton.decorate(with: theme)
    }

}

extension MainViewController: TabsBarDelegate {

    func tabsBarRequestingTabCount(_ tabsBarViewController: TabsBarViewController) -> Int {
        return self.tabManager?.count ?? 0
    }

    func tabsBarSelectingTab(_ tabsBarViewController: TabsBarViewController, atIndex: Int) {
    }

    func tabsBarRequestingTab(_ tabsBarViewController: TabsBarViewController, atIndex: Int) -> Tab? {
        return nil
    }

}
