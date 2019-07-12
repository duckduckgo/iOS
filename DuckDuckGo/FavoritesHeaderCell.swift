//
//  FavoritesHeaderCell.swift
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

class FavoritesHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var trailingMargin: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        decorate(with: ThemeManager.shared.currentTheme)
    }

    func adjust(to margin: CGFloat) {
        leadingMargin.constant = margin
        trailingMargin.constant = margin
    }
}

extension FavoritesHeaderCell: Themable {
    func decorate(with theme: Theme) {
        headerLabel.textColor = .charcoalGrey
    }
}
