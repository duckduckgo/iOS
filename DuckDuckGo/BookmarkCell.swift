//
//  BookmarkCell.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 16/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core
import Kingfisher

class BookmarkCell: UITableViewCell {
    
    static let reuseIdentifier = "BookmarkCell"
    
    @IBOutlet weak var linkImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    private(set) var bookmark: Link?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        showsReorderControl = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        linkImage.isHidden = editing
        super.setEditing(editing, animated: animated)
    }
    
    func update(withBookmark bookmark: Link) {
        self.bookmark = bookmark
        title.text = bookmark.title
        configureFavicon(bookmark.favicon)
    }
    
    private func configureFavicon(_ favicon: URL?) {
        let placeholder = #imageLiteral(resourceName: "GlobeSmall")
        linkImage.image = placeholder
        if let favicon = favicon {
            linkImage.kf.setImage(with: favicon, placeholder: placeholder)
        }
    }
}
