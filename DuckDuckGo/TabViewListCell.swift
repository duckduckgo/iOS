//
//  TabViewListCell.swift
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

class TabViewListCell: TabViewCell {

    struct Constants {
        
        static let selectedBorderWidth: CGFloat = 2.0
        static let unselectedBorderWidth: CGFloat = 0.0
        static let selectedAlpha: CGFloat = 1.0
        static let unselectedAlpha: CGFloat = 0.92
        static let swipeToDeleteAlpha: CGFloat = 0.5
        
    }
    
    static let reuseIdentifier = "TabViewListCell"

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var unread: UIView!

    override func update(withTab tab: Tab,
                         preview: UIImage?,
                         reorderRecognizer: UIGestureRecognizer?) {
        accessibilityElements = [ title as Any, removeButton as Any ]
        
        self.tab = tab
        self.collectionReorderRecognizer = reorderRecognizer
        
        if !isDeleting {
            isHidden = false
        }
        isCurrent = delegate?.isCurrent(tab: tab) ?? false
        decorate(with: ThemeManager.shared.currentTheme)

        if let link = tab.link {
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: link.displayTitle, atAddress: link.url.host ?? "")
            title.accessibilityLabel = UserText.openTab(withTitle: link.displayTitle, atAddress: link.url.host ?? "")
            title.text = tab.link?.displayTitle
        }
        
        unread.isHidden = tab.viewed

        if tab.link == nil {
            let linkText = UserText.homeTabSearchAndFavorites
            title.text = UserText.homeTabTitle
            link.text = linkText
            favicon.image = UIImage(named: "Logo")
            unread.isHidden = true
            title.isHidden = !tab.viewed
            favicon.isHidden = !tab.viewed
            removeButton.isHidden = !tab.viewed
            link.isHidden = !tab.viewed
        } else {
            removeButton.isHidden = false
            link.text = tab.link?.url.absoluteString ?? ""
            favicon.loadFavicon(forDomain: tab.link?.url.host, usingCache: .tabs)
        }
    }
    
    override func decorate(with theme: Theme) {
        super.decorate(with: theme)
        
        background.layer.borderWidth = isCurrent ? Constants.selectedBorderWidth : Constants.unselectedBorderWidth
        background.layer.borderColor = theme.tabSwitcherCellBorderColor.cgColor
        background.alpha = isCurrent ? Constants.selectedAlpha : Constants.unselectedAlpha
        
        background.backgroundColor = theme.tabSwitcherCellBackgroundColor
        title.textColor = theme.tabSwitcherCellTextColor
        link.textColor = theme.tabSwitcherCellSecondaryTextColor
    }
}
