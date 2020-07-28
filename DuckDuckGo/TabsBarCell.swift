//
//  TabBarCell.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 27/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class TabsBarCell: UICollectionViewCell {
    
    static let appUrls = AppUrls()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    var onRemove: (() -> Void)?
    
    private let gradientLayer = CAGradientLayer()
    private var model: Tab?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // setup the basic gradient (WIP)
        label.layer.addSublayer(gradientLayer)
     
        if #available(iOS 13.4, *) {
            removeButton.isPointerInteractionEnabled = true
            removeButton.pointerStyleProvider = { button, effect, shape -> UIPointerStyle? in
                return .init(effect: .lift(.init(view: button)))
            }
        }
        
    }
    
    @IBAction func onRemovePressed() {
        onRemove?()
    }

    func update(model: Tab, isCurrent: Bool, withTheme theme: Theme) {
        accessibilityElements = [label as Any, removeButton as Any]
        
        self.model?.removeObserver(self)
        self.model = model
        model.addObserver(self)

        if isCurrent {
            // update gradient colour (WIP)
            topBackgroundView.backgroundColor = theme.barBackgroundColor
            bottomBackgroundView.backgroundColor = theme.barBackgroundColor
        } else {
            // update gradient colour (WIP)
            topBackgroundView.backgroundColor = .clear
            bottomBackgroundView.backgroundColor = .clear
        }

        removeButton.isHidden = !isCurrent
        
        applyModel(model)
    }
    
    private func applyModel(_ model: Tab) {
        
        if model.link == nil {
            label.text = UserText.homeTabTitle
            faviconImage.loadFavicon(forDomain: Self.appUrls.base.host, usingCache: .tabs)
            label.accessibilityLabel = UserText.openHomeTab
            removeButton.accessibilityLabel = UserText.closeHomeTab
        } else {
            label.text = model.link?.displayTitle ?? model.link?.url.host?.dropPrefix(prefix: "www.")
            faviconImage.loadFavicon(forDomain: model.link?.url.host, usingCache: .tabs)
            label.accessibilityLabel = UserText.openTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: model.link?.displayTitle ?? "", atAddress: model.link?.url.host ?? "")
        }

    }
    
}

extension TabsBarCell: TabObserver {
    func didChange(tab: Tab) {
        applyModel(tab)
    }
}
