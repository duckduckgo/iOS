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
        applyTheme(ThemeManager.shared.currentTheme)
        
        autoconsentToggle.isOn = appSettings.autoconsentEnabled
        
        let fontSize = FontSettings.fontSizeForHeaderView
        let text = NSAttributedString(string: UserText.autoconsentInfoText, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ])
        infoText.attributedText = text
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    @IBAction private func onAutoconsentValueChanged(_ sender: Any) {
        appSettings.autoconsentEnabled = autoconsentToggle.isOn
        Pixel.fire(pixel: autoconsentToggle.isOn ? .settingsAutoconsentOn : .settingsAutoconsentOff)
    }
    
}

extension AutoconsentSettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        
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
