//
//  NoSuggestionsTableViewCell.swift
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
import DesignResourcesKit

class NoSuggestionsTableViewCell: UITableViewCell {

    static let reuseIdentifier = "NoSuggestionsTableViewCell"

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let theme = ThemeManager.shared.currentTheme

        label.font = UIFont.appFont(ofSize: 16)
        label.textColor = theme.tableCellTextColor

        typeImageView.image = UIImage(named: "Find-Search-24")

        accessibilityValue = UserText.voiceoverSuggestionTypeSearch
        tintColor = theme.autocompleteCellAccessoryColor
        backgroundColor = UIColor(designSystemColor: .surface)
    }

    func update(with query: String) {
        label.text = query
    }
}
