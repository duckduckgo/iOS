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

    @IBOutlet var margins: [NSLayoutConstraint]!
    @IBOutlet weak var autocompleteToggle: UISwitch!
    @IBOutlet weak var authenticationToggle: UISwitch!
    @IBOutlet weak var versionText: UILabel!

    private lazy var versionProvider: AppVersion = AppVersion()
    fileprivate lazy var privacyStore = PrivacyUserDefaults()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()

    static func loadFromStoryboard() -> UIViewController {
        return UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMargins()
        configureDisableAutocompleteToggle()
        configureSecurityToggles()
        configureVersionText()
    }

    private func configureMargins() {
        guard #available(iOS 11, *) else { return }
        for margin in margins {
            margin.constant = 0
        }
    }

    private func configureDisableAutocompleteToggle() {
        autocompleteToggle.isOn = appSettings.autocomplete
    }

    private func configureSecurityToggles() {
        authenticationToggle.isOn = privacyStore.authenticationEnabled
    }

    private func configureVersionText() {
        versionText.text = versionProvider.localized
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

    @IBAction func onAuthenticationToggled(_ sender: UISwitch) {
        privacyStore.authenticationEnabled = sender.isOn
    }

    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onAutocompleteToggled(_ sender: UISwitch) {
        appSettings.autocomplete = sender.isOn
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
