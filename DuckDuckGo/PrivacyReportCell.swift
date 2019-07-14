//
//  PrivacyReportCell.swift
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

class PrivacyReportCell: UICollectionViewCell {

    @IBOutlet weak var roundedBackground: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        decorate(with: ThemeManager.shared.currentTheme)
    }

}

extension PrivacyReportCell: Themable {
    
    func decorate(with theme: Theme) {
        roundedBackground.backgroundColor = .white
        title.textColor = theme.tableCellTextColor
        date.textColor = theme.tableCellAccessoryTextColor
    }
}
