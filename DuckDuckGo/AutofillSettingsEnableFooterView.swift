//
//  AutofillSettingsEnableFooterView.swift
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

class AutofillSettingsEnableFooterView: UIView {

    private enum Constants {
        static let topPadding: CGFloat = 8
        static let defaultPadding: CGFloat = 16
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installSubviews()
        installConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var title: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(designSystemColor: .textSecondary)
        label.text = UserText.autofillEmptyViewSubtitle

        return label
    }()

    private func installSubviews() {
        addSubview(title)
    }

    private func installConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topPadding),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.defaultPadding),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.defaultPadding),
            title.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Constants.defaultPadding)
        ])
    }
}
