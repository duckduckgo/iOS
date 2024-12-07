//
//  AppIconSettingsCell.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class AppIconSettingsCell: UICollectionViewCell {

    static let reuseIdentifier = "AppIconSettingsCell"

    var appIcon: AppIcon! {
        didSet {
            imageView.image = appIcon.mediumImage
            accessibilityLabel = appIcon.accessibilityName
        }
    }
    @IBOutlet weak var imageView: UIImageView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
        decorate()
    }

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2.0 : 0.0
        }
    }
}

extension AppIconSettingsCell {
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        layer.borderColor = theme.iconCellBorderColor.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            decorate()
        }
    }
}
