//
//  SettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import MessageUI
import Core
import Device

class SettingsViewController: UITableViewController {

    @IBOutlet weak var authenticationToggle: UISwitch!
    @IBOutlet weak var versionText: UILabel!

    private lazy var versionProvider = Version()
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    
    private struct TableIndex {
        static let sendFeedback = IndexPath(item: 1, section: 2)
    }
    
    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuthenticationToggle()
        configureVersionText()
    }
    
    private func configureAuthenticationToggle() {
        authenticationToggle.isOn = privacyStore.authenticationEnabled
    }
    
    private func configureVersionText() {
        versionText.text = versionProvider.localized()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == TableIndex.sendFeedback {
            sendFeedback()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.silver
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.silver
        }
    }
    
    private func sendFeedback() {
        let appVersion = versionProvider.localized() ?? ""
        let device = UIDevice.current.deviceType.displayName
        let osName = UIDevice.current.systemName
        let osVersion = UIDevice.current.systemVersion
        
        let feedback = FeedbackEmail(appVersion: appVersion, device: device, osName: osName, osVersion: osVersion)
        guard let mail = MFMailComposeViewController.create() else { return }
        mail.mailComposeDelegate = self
        mail.setToRecipients([feedback.mailTo])
        mail.setSubject(feedback.subject)
        mail.setMessageBody(feedback.body, isHTML: false)
        present(mail, animated: true, completion: nil)
    }

    @IBAction func onAuthenticationToggled(_ sender: UISwitch) {
        privacyStore.authenticationEnabled = sender.isOn
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension MFMailComposeViewController {
    static func create() -> MFMailComposeViewController? {
        return MFMailComposeViewController()
    }
}


