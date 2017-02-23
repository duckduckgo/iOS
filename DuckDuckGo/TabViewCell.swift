//
//  TabViewCell.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 21/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class TabViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "Tab"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var removeButton: UIButton!
}
