//
//  AutofillDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Core
import Common
import PrivacyDashboard

class AutofillDebugViewController: UITableViewController {

    enum Row: Int {
        case toggleAutofillDebugScript = 201
        case resetEmailProtectionInContextSignUp = 202
        case resetDaysSinceInstalledTo0 = 203
        case resetAutofillData = 204
        case addAutofillData = 205
        case resetAutofillBrokenReports = 206
    }

    let defaults = AppUserDefaults()

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.tag == Row.toggleAutofillDebugScript.rawValue {
            cell.accessoryType = defaults.autofillDebugScriptEnabled ? .checkmark : .none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.tag == Row.toggleAutofillDebugScript.rawValue {
                defaults.autofillDebugScriptEnabled.toggle()
                cell.accessoryType = defaults.autofillDebugScriptEnabled ? .checkmark : .none
                NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.autofillDebugScriptToggled))
            } else if cell.tag == Row.resetAutofillData.rawValue {
                let secureVault = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
                try? secureVault?.deleteAllWebsiteCredentials()
                let autofillPixelReporter = AutofillPixelReporter(
                        userDefaults: .standard,
                        autofillEnabled: AppUserDefaults().autofillCredentialsEnabled,
                        eventMapping: EventMapping<AutofillPixelEvent> { _, _, _, _ in })
                autofillPixelReporter.resetStoreDefaults()
                ActionMessageView.present(message: "Autofill Data reset")
            } else if cell.tag == Row.addAutofillData.rawValue {
                promptForNumberOfLoginsToAdd()
            } else if cell.tag == Row.resetEmailProtectionInContextSignUp.rawValue {
                EmailManager().resetEmailProtectionInContextPrompt()
                tableView.deselectRow(at: indexPath, animated: true)
            } else if cell.tag == Row.resetDaysSinceInstalledTo0.rawValue {
                StatisticsUserDefaults().installDate = Date()
                tableView.deselectRow(at: indexPath, animated: true)
            } else if cell.tag == Row.resetAutofillBrokenReports.rawValue {
                tableView.deselectRow(at: indexPath, animated: true)
                let reporter = BrokenSiteReporter(pixelHandler: { _ in }, keyValueStoring: UserDefaults.standard, storageConfiguration: .autofillConfig)
                let expiryDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
                _ = reporter.persistencyManager.removeExpiredItems(currentDate: expiryDate)
                ActionMessageView.present(message: "Autofill Broken Reports reset")
            }
        }
    }

    private func promptForNumberOfLoginsToAdd() {
        let alertController = UIAlertController(title: "Enter number of Logins to add", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Number"
            textField.keyboardType = .numberPad
        }

        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned alertController] _ in
            let textField = alertController.textFields![0]
            if let numberString = textField.text, let number = Int(numberString) {
                self.addLogins(number)
            }
        }
        alertController.addAction(submitAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    private func addLogins(_ count: Int) {
        let secureVault = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())

        for i in 1...count {
            let account = SecureVaultModels.WebsiteAccount(title: "", username: "Dax \(i)", domain: "https://fill.dev", notes: "")
            let credentials = SecureVaultModels.WebsiteCredentials(account: account, password: "password".data(using: .utf8))
            do {
                _ = try secureVault?.storeWebsiteCredentials(credentials)
            } catch let error {
                os_log(.debug, "Error inserting credential \(error.localizedDescription)")
            }

        }

        ActionMessageView.present(message: "Autofill Data added")
    }

}
