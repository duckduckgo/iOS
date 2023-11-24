//
//  AutofillNeverSavedTableViewCell.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

class AutofillNeverSavedTableViewCell: UITableViewCell {

    var theme: Theme? {
        didSet {
            updateTheme()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .preferredFont(forTextStyle: .callout)
        label.text = UserText.autofillNeverSavedSettings
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        installSubviews()
        installConstraints()
    }

    private func installSubviews() {
        contentView.addSubview(titleLabel)
    }

    private func installConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let margins = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }

    private func updateTheme() {
        guard let theme = theme else {
            return
        }

        titleLabel.textColor = theme.autofillDefaultTitleTextColor
        contentView.backgroundColor = UIColor(designSystemColor: .surface)
    }
}
