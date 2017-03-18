//
//  BookmarkCell.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 16/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit


class BookmarkCell: UITableViewCell {
    
    @IBOutlet weak var linkImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    static let reuseIdentifier = "BookmarkCell"
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        linkImage.isHidden = editing
        super.setEditing(editing, animated: animated)
    }
    
}
