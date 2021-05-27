//
//  BetaFeaturesViewController.swift
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

final class BetaFeaturesViewController: UITableViewController {

    enum Rows: Int, CaseIterable {
        case email
    }

    @IBOutlet weak var emailAccessoryText: UILabel!
    
    private lazy var emailManager = EmailManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureEmail()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.row {
        case Rows.email.rawValue:
            if emailManager.isSignedIn {
                pushEmailProtectionViewController()
            } else {
                pushEmailWaitlistViewController()
            }
        default: assertionFailure("\(#file): Attempted to navigate to unsupported index path: \(indexPath)")
        }
    }

    private func configureEmail() {
        if emailManager.isSignedIn {
            emailAccessoryText.text = UserText.emailSettingEnabled
        } else if emailManager.eligibleToJoinWaitlist {
            emailAccessoryText.text = UserText.emailSettingJoinWaitlist
        } else {
            emailAccessoryText.text = nil
        }
    }

    private func pushEmailProtectionViewController() {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: "EmailProtectionViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushEmailWaitlistViewController() {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: "EmailWaitlistViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }

}
