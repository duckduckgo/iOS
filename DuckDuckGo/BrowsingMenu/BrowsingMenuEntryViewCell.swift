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
import Core

class BrowsingMenuEntryViewCell: UITableViewCell {
    
    @IBOutlet weak var entryImage: UIImageView!
    @IBOutlet weak var entryLabel: UILabel!
    
    func configure(image: UIImage, label: String, accessibilityLabel: String?, theme: Theme) {
        entryImage.image = image
        entryLabel.setAttributedTextString(label)
        entryLabel.accessibilityLabel = accessibilityLabel
        
        entryImage.tintColor = theme.browsingMenuIconsColor
        entryLabel.textColor = theme.browsingMenuTextColor
        backgroundColor = theme.browsingMenuBackgroundColor
        setHighlightedStateBackgroundColor(theme.browsingMenuHighlightColor)
    }
    
    static func preferredWidth(for text: String) -> CGFloat {
        
        let size = (text as NSString).boundingRect(with: CGSize(width: 1000, height: 20),
                                                   options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                   attributes: [.font: UIFont.appFont(ofSize: 16)],
                                                   context: nil)
        
        return size.width + 69 // Left Margin + Icon width + Spacing + Right Margin
    }
}
