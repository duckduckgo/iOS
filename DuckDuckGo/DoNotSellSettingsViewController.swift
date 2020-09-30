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
        infoTextView.font = UIFont.appFont(ofSize: 14.0)
        disclaimerTextView.font = UIFont.appFont(ofSize: 14.0)
        
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
        let tempStr = NSMutableAttributedString(string: UserText.doNotSellDisclaimerPrefix,
                                                attributes: [
                                                    NSAttributedString.Key.font: UIFont.appFont(ofSize: 14),
                                                    NSAttributedString.Key.foregroundColor: theme.ddgTextTintColor
                                                ])
        tempStr.append(NSAttributedString(string: UserText.doNotSellDisclaimerBold,
                                          attributes: [
                                            NSAttributedString.Key.font: UIFont.boldAppFont(ofSize: 14),
                                            NSAttributedString.Key.foregroundColor: theme.ddgTextTintColor
                                          ]))
        tempStr.append(NSAttributedString(string: UserText.doNotSellDisclaimerSuffix,
                                          attributes: [
                                            NSAttributedString.Key.font: UIFont.appFont(ofSize: 14),
                                            NSAttributedString.Key.foregroundColor: theme.ddgTextTintColor
                                          ]))
        let range = NSRange(location: disclaimerTextView.text.count - learnMoreStr.count, length: learnMoreStr.count)
        tempStr.addAttribute(.link, value: "ddgQuickLink://duckduckgo.com/global-privacy-control-learn-more", range: range)
        tempStr.addAttribute(NSAttributedString.Key.foregroundColor, value: theme.ddgTextTintColor, range: range)
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.boldAppFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: theme.ddgTextTintColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        disclaimerTextView.attributedText = tempStr
        disclaimerTextView.linkTextAttributes = linkAttributes
    }
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        infoTextView.textColor = theme.ddgTextTintColor
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
