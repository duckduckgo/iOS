//
//  BrowsingMenuEntryViewCell.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class BrowsingMenuEntryViewCell: UITableViewCell {
    
    @IBOutlet weak var entryImage: UIImageView!
    @IBOutlet weak var entryLabel: UILabel!
    
    func configure(image: UIImage, label: String, theme: Theme) {
        entryImage.image = image
        entryLabel.setAttributedTextString(label)
        
        entryImage.tintColor = theme.browsingMenuIconsColor
        entryLabel.textColor = theme.browsingMenuTextColor
        contentView.backgroundColor = theme.browsingMenuBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
