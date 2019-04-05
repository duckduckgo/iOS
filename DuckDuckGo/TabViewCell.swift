//
//  TabViewCell.swift
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
import Kingfisher

protocol TabViewCellDelegate: class {

    func deleteTab(tab: Tab)

    func isCurrent(tab: Tab) -> Bool
    
}

class TabViewCell: UICollectionViewCell {

    struct Constants {
        
        static let selectedBorderWidth: CGFloat = 2.0
        static let unselectedBorderWidth: CGFloat = 0.0
        static let selectedAlpha: CGFloat = 1.0
        static let unselectedAlpha: CGFloat = 0.92
        
    }
    
    static let reuseIdentifier = "TabCell"

    weak var delegate: TabViewCellDelegate?
    weak var tab: Tab?
    var isCurrent = false

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var unread: UIView!

    func update(withTab tab: Tab) {
        accessibilityElements = [ title, link, removeButton, unread ]
        
        removeTabObserver()
        tab.addObserver(self)
        self.tab = tab
        
        isHidden = false
        isCurrent = delegate?.isCurrent(tab: tab) ?? false
        
        background.layer.borderWidth = isCurrent ? Constants.selectedBorderWidth : Constants.unselectedBorderWidth
        background.layer.borderColor = UIColor.cornflowerBlue.cgColor
        background.alpha = isCurrent ? Constants.selectedAlpha : Constants.unselectedAlpha

        if let link = tab.link {
            removeButton.accessibilityLabel = UserText.closeTab(withTitle: link.displayTitle ?? "", atAddress: link.url.host ?? "")
            title.accessibilityLabel = UserText.openTab(withTitle: link.displayTitle ?? "", atAddress: link.url.host ?? "")
            title.text = tab.link?.displayTitle
        }
        
        unread.isHidden = tab.viewed

        link.text = tab.link?.url.absoluteString ?? ""
        configureFavicon(forDomain: tab.link?.url.host)
    }

    private func removeTabObserver() {
        tab?.removeObserver(self)
    }
    
    @IBAction func deleteTab() {

        guard let tab = tab else { return }
        self.delegate?.deleteTab(tab: tab)

        UIView.animate(withDuration: 0.3, animations: {
            self.transform.tx = -self.superview!.frame.width * 1.5
        }, completion: { _ in
            self.transform.tx = 0
        })

    }

    private func configureFavicon(forDomain domain: String?) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        favicon.image = placeholder

        if let domain = domain {
            let faviconUrl = AppUrls().faviconUrl(forDomain: domain)
            favicon.kf.setImage(with: faviconUrl,
                                  placeholder: placeholder,
                                  options: [.downloader(NotFoundCachingDownloader())],
                                  progressBlock: nil,
                                  completionHandler: nil)
        }
    }
}

extension TabViewCell: TabObserver {
    
    func didChange(tab: Tab) {
        update(withTab: tab)
    }
    
}
