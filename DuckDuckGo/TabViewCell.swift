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
    
    static let reuseIdentifier = "TabCell"
    
    weak var delegate: TabViewCellDelegate?
    weak var tab: Tab?
    
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    func update(withTab tab: Tab) {
        self.tab = tab
        isHidden = false
        title.text = tab.link?.title ?? ""
        link.text = tab.link?.url.absoluteString ?? ""
        configureFavicon(tab.link?.favicon)
    }
    
    @IBAction func deleteTab() {
        
        guard let tab = tab else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform.tx = -self.superview!.frame.width * 1.5
        }, completion: { completed in
            self.isHidden = true
            self.delegate?.deleteTab(tab: tab)
        })
        
    }
    
    private func configureFavicon(_ faviconUrl: URL?) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        favicon.image = placeholder
        if let favicon = favicon {
            favicon.kf.setImage(with: faviconUrl, placeholder: placeholder)
        }
    }
}
