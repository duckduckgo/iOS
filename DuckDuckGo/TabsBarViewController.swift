//
//  TabsBarViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 25/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

protocol TabsBarDelegate: NSObjectProtocol {
    
    func tabsBar(_ controller: TabsBarViewController, didSelectTabAtIndex index: Int)
    func tabsBar(_ controller: TabsBarViewController, didRemoveTabAtIndex index: Int)
    func tabsBar(_ controller: TabsBarViewController, didRequestMoveTabFromIndex fromIndex: Int, toIndex: Int)
    func tabsBarDidRequestNewTab(_ controller: TabsBarViewController)
    func tabsBarDidRequestForgetAll(_ controller: TabsBarViewController)
    func tabsBarDidRequestTabSwitcher(_ controller: TabsBarViewController)

}

class TabsBarViewController: UIViewController {

    struct Constants {
        
        static let minItemWidth: CGFloat = 68

    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var addTabButton: UIButton!
    @IBOutlet weak var tabSwitcherContainer: UIView!

    weak var delegate: TabsBarDelegate?
    weak var tabsModel: TabsModel?

    private let tabSwitcherButton = TabSwitcherButton()
    private let longPressTabGesture = UILongPressGestureRecognizer()

    var tabsCount: Int {
        return tabsModel?.count ?? 0
    }
    
    var currentIndex: Int {
        return tabsModel?.currentIndex ?? 0
    }

    var maxItems: Int {
        return Int(collectionView.frame.size.width / Constants.minItemWidth)
    }

    var numberOfItems: Int {
        return tabsCount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("***", #function)

        applyTheme(ThemeManager.shared.currentTheme)

        tabSwitcherButton.delegate = self
        tabSwitcherContainer.addSubview(tabSwitcherButton)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureGestures()
        
        enableInteractionsWithPointer()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabSwitcherButton.layoutSubviews()
        refresh()
    }

    @IBAction func onFireButtonPressed() {
        
        let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
            guard let self = self else { return }
            self.delegate?.tabsBarDidRequestForgetAll(self)
        })
        self.present(controller: alert, fromView: fireButton)

    }

    @IBAction func onNewTabPressed() {
        requestNewTab()
    }

    func refresh() {
        let availableWidth = collectionView.frame.size.width
        let maxVisibleItems = min(maxItems, numberOfItems)
        
        var itemWidth = availableWidth / CGFloat(maxVisibleItems)
        itemWidth = max(itemWidth, Constants.minItemWidth)
        itemWidth = min(itemWidth, availableWidth / 2)

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: itemWidth, height: view.frame.size.height)
        }

        collectionView.reloadData()
        tabSwitcherButton.tabCount = tabsCount
    }

    func backgroundTabAdded() {
        tabSwitcherButton.incrementAnimated()
        refresh()
    }
    
    private func configureGestures() {
        print("***", #function, collectionView.gestureRecognizers as Any)
        longPressTabGesture.addTarget(self, action: #selector(handleLongPressTabGesture))
        longPressTabGesture.minimumPressDuration = 0.1
        collectionView.addGestureRecognizer(longPressTabGesture)
    }
    
    var pressedCell: TabsBarCell?
    
    @objc func handleLongPressTabGesture(gesture: UILongPressGestureRecognizer) {
        // print("***", #function, gesture)
        switch gesture.state {
        case .began:
            guard let path = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            delegate?.tabsBar(self, didSelectTabAtIndex: path.row)

        case .changed:
            guard let path = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            if pressedCell == nil, let cell = collectionView.cellForItem(at: path) as? TabsBarCell {
                cell.isPressed = true
                pressedCell = cell
                collectionView.beginInteractiveMovementForItem(at: path)
            }
            let location = CGPoint(x: gesture.location(in: collectionView).x, y: collectionView.center.y)
            collectionView.updateInteractiveMovementTargetPosition(location)
            
        case .ended:
            collectionView.endInteractiveMovement()
            releasePressedCell()

        default:
            collectionView.cancelInteractiveMovement()
            releasePressedCell()
        }
    }

    private func releasePressedCell() {
        pressedCell?.isPressed = false
        pressedCell = nil
    }
    
    private func enableInteractionsWithPointer() {
        guard #available(iOS 13.4, *), DefaultVariantManager().isSupported(feature: .iPadImprovements) else { return }
        fireButton.isPointerInteractionEnabled = true
        addTabButton.isPointerInteractionEnabled = true
        tabSwitcherButton.pointerView.frame.size.width = 34
    }
    
    private func requestNewTab() {
        delegate?.tabsBarDidRequestNewTab(self)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: 0), at: .right, animated: true)
        }
    }

}

extension TabsBarViewController: TabSwitcherButtonDelegate {
    
    func showTabSwitcher(_ button: TabSwitcherButton) {
        delegate?.tabsBarDidRequestTabSwitcher(self)
    }
    
    func launchNewTab(_ button: TabSwitcherButton) {
        requestNewTab()
    }
        
}

extension TabsBarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tabsBar(self, didSelectTabAtIndex: indexPath.row)
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
        delegate?.tabsBar(self, didRequestMoveTabFromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
}

extension TabsBarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("***", #function, Date(), numberOfItems, tabsCount, maxItems)
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath) as? TabsBarCell else {
            fatalError("Unable to create TabBarCell")
        }
        
        guard let model = tabsModel?.get(tabAt: indexPath.row) else {
            fatalError("Failed to load tab at \(indexPath.row)")
        }
        
        let isCurrent = indexPath.row == currentIndex
        cell.update(model: model, isCurrent: isCurrent, withTheme: ThemeManager.shared.currentTheme)
        cell.onRemove = { [weak self] in
            guard let self = self else { return }
            self.delegate?.tabsBar(self, didRemoveTabAtIndex: indexPath.row)
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
  
    func tabsBar(_ controller: TabsBarViewController, didSelectTabAtIndex index: Int) {
        dismissOmniBar()
        select(tabAt: index)
    }
    
    func tabsBar(_ controller: TabsBarViewController, didRemoveTabAtIndex index: Int) {
        let tab = tabManager.model.get(tabAt: index)
        closeTab(tab)
    }
    
    func tabsBar(_ controller: TabsBarViewController, didRequestMoveTabFromIndex fromIndex: Int, toIndex: Int) {
        tabManager.model.moveTab(from: fromIndex, to: toIndex)
        select(tabAt: toIndex)
    }
    
    func tabsBarDidRequestNewTab(_ controller: TabsBarViewController) {
        newTab()
    }
    
    func tabsBarDidRequestForgetAll(_ controller: TabsBarViewController) {
        forgetAllWithAnimation()
    }
    
    func tabsBarDidRequestTabSwitcher(_ controller: TabsBarViewController) {
        showTabSwitcher()
    }
    
}
