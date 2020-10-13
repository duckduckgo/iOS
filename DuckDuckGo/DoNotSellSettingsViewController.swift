//
//  DoNotSellSettingsViewController.swift
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
import Core

class DoNotSellSettingsViewController: UITableViewController {

    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var doNotSellToggle: UISwitch!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var disclaimerTextView: UITextView!
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
    
    let learnMoreStr = "Learn More"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doNotSellToggle.isOn = appSettings.sendDoNotSell
        
        infoTextView.text = UserText.doNotSellInfoText
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        infoTextView.attributedText = NSAttributedString(string: UserText.doNotSellInfoText,
                                                         attributes: [
                                                            NSAttributedString.Key.kern: -0.08,
                                                            NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
                                                         ])
        
        infoTextView.backgroundColor = .clear
        disclaimerTextView.backgroundColor = .clear
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    @IBAction func onDoNotSellValueChanged(_ sender: Any) {
        appSettings.sendDoNotSell = doNotSellToggle.isOn
        Pixel.fire(pixel: doNotSellToggle.isOn ? .settingsDoNotSellOn : .settingsDoNotSellOff)
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.doNotSellStatusChange, object: nil)
    }
    
}

extension DoNotSellSettingsViewController: Themable {
    
    /// Apply attributes for NSAtrtributedStrings for copy text
    func applyAtributes(theme: Theme) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        let tempStr = NSMutableAttributedString(string: UserText.doNotSellDisclaimerBold,
                                                attributes: [
                                                    NSAttributedString.Key.kern: -0.08,
                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13),
                                                    NSAttributedString.Key.foregroundColor: theme.tableHeaderTextColor
                                                ])
        tempStr.append(NSAttributedString(string: UserText.doNotSellDisclaimerSuffix,
                                          attributes: [
                                              NSAttributedString.Key.kern: -0.08,
                                              NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                              NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                              NSAttributedString.Key.foregroundColor: theme.tableHeaderTextColor
                                          ]))
        tempStr.append(NSAttributedString(string: UserText.doNotSellLearnMore,
                                          attributes: [
                                            NSAttributedString.Key.link: "ddgQuickLink://duckduckgo.com/global-privacy-control-learn-more"
                                          ]))
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.kern: -0.08,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
            NSAttributedString.Key.foregroundColor: theme.searchBarTextColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        disclaimerTextView.attributedText = tempStr
        disclaimerTextView.linkTextAttributes = linkAttributes
    }
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        infoTextView.textColor = theme.tableHeaderTextColor
        applyAtributes(theme: theme)

        doNotSellToggle.onTintColor = theme.buttonTintColor
        
        headerView.backgroundColor = theme.backgroundColor
        footerView.backgroundColor = theme.backgroundColor

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()

    }
    
}

extension DoNotSellSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }
}
