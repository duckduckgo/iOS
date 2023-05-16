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
import DesignResourcesKit

protocol EnableAutofillSettingsTableViewCellDelegate: AnyObject {
    func enableAutofillSettingsTableViewCell(_ cell: EnableAutofillSettingsTableViewCell, didChangeSettings value: Bool)
}

class EnableAutofillSettingsTableViewCell: UITableViewCell {
    weak var delegate: EnableAutofillSettingsTableViewCellDelegate?
    var theme: Theme? {
        didSet {
            updateTheme()
        }
    }
    var isToggleOn: Bool {
        get {
            toggleSwitch.isOn
        }
        set {
            toggleSwitch.isOn = newValue
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .gray90
        label.text = UserText.autofillEnableSettings
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch(frame: CGRect.zero)
        toggle.addTarget(self, action: #selector(onToggleValueChanged(_:)), for: .valueChanged)
        return toggle
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
        selectionStyle = .none
    }
    
    private func installSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
    }
    
    private func updateTheme() {
        guard let theme = theme else {
            return
        }

        toggleSwitch.onTintColor = theme.buttonTintColor
        titleLabel.textColor = theme.autofillDefaultTitleTextColor
        contentView.backgroundColor = UIColor(designSystemColor: .surface)
    }
    
    private func installConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    @objc private func onToggleValueChanged(_ toggle: UISwitch) {
        delegate?.enableAutofillSettingsTableViewCell(self, didChangeSettings: toggle.isOn)
    }
}
