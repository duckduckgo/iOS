//
//  EnableAutofillSettingsTableViewCell.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

@available(iOS 14.0, *)
class EnableAutofillSettingsTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray90
        label.text = "Save and Autofill Logins"
        return label
    }()
    
    private lazy var settingsSwitch: UISwitch = {
        let toggle = UISwitch(frame: CGRect.zero)
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        installSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(settingsSwitch)
        installConstraints()
    }
    
    private func installConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsSwitch.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 32
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: settingsSwitch.leadingAnchor, multiplier: 1),
            titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            
            settingsSwitch.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            settingsSwitch.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
