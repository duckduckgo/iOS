//
//  TabViewCell.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 21/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core
import Kingfisher

class TabViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TabCell"
    
    @IBOutlet weak var favicon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    func update(withLink tabLink: Link) {
        title.text = tabLink.title ?? ""
        link.text = tabLink.url.absoluteString
        configureFavicon(tabLink.favicon)
    }
    
    private func configureFavicon(_ faviconUrl: URL?) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        favicon.image = placeholder
        if let favicon = favicon {
            favicon.kf.setImage(with: faviconUrl, placeholder: placeholder)
        }
    }
}
