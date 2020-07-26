//
//  TabsBarViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 25/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

protocol TabsBarDelegate: NSObjectProtocol {

    func tabsBarDidSelectTab(_ tabsBarViewController: TabsBarViewController, atIndex: Int)

}

class TabsBarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var addTabButton: UIButton!
    @IBOutlet weak var tabSwitcherContainer: UIView!

    var tabManager: TabManager? {
        didSet {
            refresh()
        }
    }

    weak var delegate: TabsBarDelegate?

    let tabSwitcherButton = TabSwitcherButton()
    let flowLayout = UICollectionViewFlowLayout()

    var tabsCount: Int {
        return tabManager?.count ?? 0
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

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabSwitcherButton.layoutSubviews()
        refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func refresh() {
        let availableWidth = collectionView.frame.size.width
        var itemWidth = availableWidth / CGFloat(numberOfItems)
        if itemWidth < 110 {
            itemWidth = 110
        } else if itemWidth > 400 {
            itemWidth = 400
        }

        flowLayout.itemSize = CGSize(width: itemWidth, height: 40)
        flowLayout.minimumInteritemSpacing = 0.0

        collectionView.reloadData()
        tabSwitcherButton.tabCount = tabsCount
    }

}

extension TabsBarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tabsBarDidSelectTab(self, atIndex: indexPath.row)
    }

}

extension TabsBarViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("***", #function, numberOfItems, tabsCount, maxItems)
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath)

        if indexPath.row == tabManager?.model.currentIndex ?? 0 {
            cell.contentView.backgroundColor = .white
        } else {
            cell.contentView.backgroundColor = .clear
        }

        return cell
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

    func tabsBarDidSelectTab(_ tabsBarViewController: TabsBarViewController, atIndex index: Int) {
        select(tabAt: index)
    }

}
