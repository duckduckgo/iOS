//
//  DoNotSellSettingsViewController.swift
//  DuckDuckGo
//
//  Created by Brad Slayter on 9/18/20.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class DoNotSellSettingsViewController: UITableViewController {

    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var doNotSellToggle: UISwitch!
    @IBOutlet weak var infoTextView: UITextView!
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
    
    let learnMoreStr = "Learn More"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doNotSellToggle.isOn = appSettings.sendDoNotSell
        
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
    
    func applyAtributes(theme: Theme) {
        let tempStr = NSMutableAttributedString(attributedString: infoTextView.attributedText)
        let range = NSRange(location: infoTextView.text.count - learnMoreStr.count, length: learnMoreStr.count)
        tempStr.setAttributes([:], range: range)
        tempStr.addAttribute(.link, value: "ddgQuickLink://global-privacy-control.glitch.me/", range: range)
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: theme.ddgTextTintColor,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: infoTextView.font!.pointSize + 4)
        ]
        infoTextView.attributedText = tempStr
        infoTextView.linkTextAttributes = linkAttributes
    }
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        applyAtributes(theme: theme)

        doNotSellToggle.onTintColor = theme.buttonTintColor

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
