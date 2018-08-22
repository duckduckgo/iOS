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

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var unread: UIView!

    func update(withTab tab: Tab, isCurrent: Bool) {
        self.tab = tab
        isHidden = false
        
        background.layer.borderWidth = isCurrent ? Constants.selectedBorderWidth : Constants.unselectedBorderWidth
        background.layer.borderColor = UIColor.skyBlue.cgColor
        background.alpha = isCurrent ? Constants.selectedAlpha : Constants.unselectedAlpha
        
        let titleText = (tab.link?.title ?? tab.link?.url.host?.dropPrefix(prefix: "www.") ?? "")
        title.text = titleText
        unread.isHidden = tab.viewed

        link.text = tab.link?.url.absoluteString ?? ""
        configureFavicon(forDomain: tab.link?.url.host)
    }

    @IBAction func deleteTab() {

        guard let tab = tab else { return }

        UIView.animate(withDuration: 0.3, animations: {
            self.transform.tx = -self.superview!.frame.width * 1.5
        }, completion: { _ in
            self.isHidden = true
            self.delegate?.deleteTab(tab: tab)
        })

    }

    private func configureFavicon(forDomain domain: String?) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        favicon.image = placeholder

        if let domain = domain {
            let faviconUrl = AppUrls().faviconUrl(forDomain: domain)
            favicon.kf.setImage(with: faviconUrl, placeholder: placeholder)
        }
    }
}
