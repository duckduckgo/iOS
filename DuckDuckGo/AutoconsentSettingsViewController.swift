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

class AutoconsentSettingsViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var autoconsentToggle: UISwitch!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var infoTextView: UITextView!
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoconsentToggle.isOn = appSettings.autoconsentEnabled
        infoTextView.backgroundColor = .clear
        
        applyTheme(ThemeManager.shared.currentTheme)
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
    
    @IBAction func onAutoconsentValueChanged(_ sender: Any) {
        appSettings.autoconsentEnabled = autoconsentToggle.isOn
        appSettings.autoconsentPromptShown = true
        
#warning("do we want to fire pixels on change?")
//        Pixel.fire(pixel: doNotSellToggle.isOn ? .settingsDoNotSellOn : .settingsDoNotSellOff)
    }
    
}

extension AutoconsentSettingsViewController: Themable {
    
    /// Apply attributes for NSAtrtributedStrings for copy text
    func applyAttributes(theme: Theme) {
#warning("style the settings sub-screen header according to designs")
//        let fontSize = SettingsViewController.fontSizeForHeaderView
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineHeightMultiple = 1.16
//        let tempStr = NSMutableAttributedString(string: UserText.doNotSellInfoText + " ",
//                                                attributes: [
//                                                    NSAttributedString.Key.kern: -0.08,
//                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
//                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
//                                                    NSAttributedString.Key.foregroundColor: theme.tableHeaderTextColor
//                                                ])
//        tempStr.append(NSAttributedString(string: UserText.doNotSellLearnMore,
//                                          attributes: [
//                                            NSAttributedString.Key.link: "ddgQuickLink://help.duckduckgo.com/duckduckgo-help-pages/privacy/gpc/",
//                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
//                                          ]))
//        let linkAttributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.kern: -0.08,
//            NSAttributedString.Key.paragraphStyle: paragraphStyle,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
//            NSAttributedString.Key.foregroundColor: theme.searchBarTextColor,
//            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
//        ]
//
//        infoTextView.attributedText = tempStr
//        infoTextView.linkTextAttributes = linkAttributes
    }
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        infoTextView.textColor = theme.tableHeaderTextColor
        applyAttributes(theme: theme)

        autoconsentToggle.onTintColor = theme.buttonTintColor
        
        headerView.backgroundColor = theme.backgroundColor

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
