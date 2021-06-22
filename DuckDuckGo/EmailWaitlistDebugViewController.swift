//
//  EmailWaitlistDebugViewController.swift
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

final class EmailWaitlistDebugViewController: UITableViewController {

    private let titles = [
        Rows.waitlistTimestamp: "Timestamp",
        Rows.waitlistToken: "Token",
        Rows.waitlistInviteCode: "Invite Code"
    ]

    enum Rows: Int, CaseIterable {

        case waitlistTimestamp
        case waitlistToken
        case waitlistInviteCode

    }

    private let emailManager = EmailManager()
    private let storage = EmailKeychainManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let clearDataItem = UIBarButtonItem(image: UIImage(systemName: "trash")!,
                                             style: .done,
                                             target: self,
                                             action: #selector(presentClearDataPrompt(_:)))
        clearDataItem.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearDataItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = Rows(rawValue: indexPath.row)!

        cell.textLabel?.text = titles[row]

        switch row {
        case .waitlistTimestamp:
            if let timestamp = storage.getWaitlistTimestamp() {
                cell.detailTextLabel?.text = String(timestamp)
            } else {
                cell.detailTextLabel?.text = "None"
            }

        case .waitlistToken:
            cell.detailTextLabel?.text = storage.getWaitlistToken() ?? "None"

        case .waitlistInviteCode:
            cell.detailTextLabel?.text = storage.getWaitlistInviteCode() ?? "None"
        }

        return cell
    }

    @objc
    private func presentClearDataPrompt(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Clear Waitlist Data?", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.clearDataAndReload()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func clearDataAndReload() {
        storage.deleteWaitlistState()
        tableView.reloadData()
    }
}
