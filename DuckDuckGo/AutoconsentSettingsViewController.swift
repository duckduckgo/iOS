//
//  AutoconsentSettingsViewController.swift
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
import Core

// To remove after Settings experiment
final class AutoconsentSettingsViewController: UITableViewController {
    
    @IBOutlet private var labels: [UILabel]!
    
    @IBOutlet private weak var autoconsentToggle: UISwitch!
    @IBOutlet private weak var infoText: UILabel!
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
        
    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "AutoconsentSettingsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decorate()

        autoconsentToggle.isOn = appSettings.autoconsentEnabled
        
        let fontSize = FontSettings.fontSizeForHeaderView
        let text = NSAttributedString(string: UserText.autoconsentInfoText, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ])
        infoText.attributedText = text
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Pixel.fire(pixel: .settingsAutoconsentShown)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    @IBAction private func onAutoconsentValueChanged(_ sender: Any) {
        appSettings.autoconsentEnabled = autoconsentToggle.isOn
        Pixel.fire(pixel: autoconsentToggle.isOn ? .settingsAutoconsentOn : .settingsAutoconsentOff)

        if appSettings.autoconsentEnabled {
            Pixel.fire(pixel: .settingsAutoconsentOn)
        } else {
            Pixel.fire(pixel: .settingsAutoconsentOff)
        }
    }
    
}

extension AutoconsentSettingsViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        
        infoText.textColor = theme.tableHeaderTextColor
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        autoconsentToggle.onTintColor = theme.buttonTintColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
