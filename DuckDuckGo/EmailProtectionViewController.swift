//
//  EmailProtectionViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

final class EmailProtectionViewController: UITableViewController {

    @IBOutlet weak var emailAccessoryText: UILabel!
    @IBOutlet weak var disableCellLabel: UILabel!

    private lazy var emailManager = EmailManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureEmail()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let footer = tableView.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            footer.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableFooterView = footer
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
        disableCellLabel.textColor = theme.destructiveColor

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 0 {
            presentSignOutPrompt()
        }
    }

    private func configureEmail() {
        if emailManager.isSignedIn {
            emailAccessoryText.text = emailManager.userEmail
        } else {
            emailAccessoryText.text = UserText.emailSettingsOff
        }
    }

    private func presentSignOutPrompt() {
        let alertController = UIAlertController(title: UserText.emailSignOutAlertTitle,
                                                message: UserText.emailSignOutAlertDescription,
                                                preferredStyle: .alert)

        alertController.addAction(title: UserText.emailSignOutAlertCancel, style: .cancel)
        alertController.addAction(title: UserText.emailSignOutAlertRemove, style: .default, handler: { [weak self] in
            guard let self = self else { return }

            self.emailManager.signOut()
            self.navigationController?.popViewController(animated: true)
        })

        present(alertController, animated: true)
    }

}
