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
    let flowLayout = TabsBarFlowLayout()

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
        
        enableInteractionsWithPointer()
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

    private func enableInteractionsWithPointer() {
        guard #available(iOS 13.4, *), DefaultVariantManager().isSupported(feature: .iPadImprovements) else { return }
        fireButton.isPointerInteractionEnabled = true
        addTabButton.isPointerInteractionEnabled = true
        tabSwitcherButton.pointerView.frame.size.width = 34
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath) as? TabBarCell else {
            fatalError("Unable to create TabBarCell")
        }
        
        guard let model = tabManager?.model.get(tabAt: indexPath.row) else {
            fatalError("Failed to load tab")
        }
        
        model.addObserver(self)
        
        let selected = indexPath.row == tabManager?.model.currentIndex ?? 0
        cell.update(model: model, isSelected: selected, withTheme: ThemeManager.shared.currentTheme)
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
        omniBar.resignFirstResponder()
        select(tabAt: index)
    }

}

class TabBarCell: UICollectionViewCell {
    
    static let appUrls = AppUrls()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var faviconImage: UIImageView!
    
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // setup the basic gradient
        label.layer.addSublayer(gradientLayer)
        
    }
    
    func update(model: Tab, isSelected: Bool, withTheme theme: Theme) {
                
        if isSelected {
            // update gradient colour
            contentView.backgroundColor = theme.barBackgroundColor
        } else {
            // update gradient colour
            contentView.backgroundColor = .clear
        }
        
        if model.link == nil {
            label.text = UserText.homeTabTitle
            faviconImage.loadFavicon(forDomain: Self.appUrls.base.host, usingCache: .tabs)
        } else {
            label.text = model.link?.displayTitle ?? model.link?.url.host?.dropPrefix(prefix: "www.")
            faviconImage.loadFavicon(forDomain: model.link?.url.host, usingCache: .tabs)
        }

        removeButton.isHidden = !isSelected
    }
    
}

extension TabsBarViewController: TabObserver {
    
    func didChange(tab: Tab) {
        collectionView.reloadData()
    }
    
}

class TabsBarFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var updatedAttributes = [UICollectionViewLayoutAttributes]()
        attributes.forEach({ (originalAttributes) in
            guard originalAttributes.representedElementKind == nil else {
                updatedAttributes.append(originalAttributes)
                return
            }

            if let updatedAttribute = layoutAttributesForItem(at: originalAttributes.indexPath) {
                updatedAttributes.append(updatedAttribute)
            }
        })

        return updatedAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }

        if indexPath.item == 0 {
            attributes.frame.origin.x = sectionInset.left
            return attributes
        }
        
        let previousAttributes = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))
        let previousFrame: CGRect = previousAttributes?.frame ?? CGRect()

        let x = previousFrame.origin.x + previousFrame.width + minimumInteritemSpacing
        attributes.frame = CGRect(x: x, y: attributes.frame.origin.y, width: attributes.frame.width, height: attributes.frame.height)
        return attributes
    }
}
