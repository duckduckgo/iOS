//
//  PrivacyProtectionHomeCell.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class PrivacyProtectionHomeCell: UICollectionViewCell {
    
    struct Contants {
        static let cellHeight: CGFloat = 73
    }
    
    @IBOutlet weak var protectionImage: UIImageView!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        decorate(with: ThemeManager.shared.currentTheme)
        
        separatorHeight.constant = 1 / UIScreen.main.scale
    }
}

extension PrivacyProtectionHomeCell: Themable {
    
    func decorate(with theme: Theme) {
        separator.backgroundColor = theme.homeRowBackgroundColor
        
        descriptionLabel.textColor = theme.homePrivacyCellTextColor
        detailLabel.textColor = theme.homePrivacyCellSecondaryTextColor
        
        disclosureIndicator.tintColor = theme.tableCellAccessoryColor
    }
}
