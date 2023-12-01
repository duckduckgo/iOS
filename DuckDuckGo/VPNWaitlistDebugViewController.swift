//
//  VPNWaitlistDebugViewController.swift
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

#if NETWORK_PROTECTION

import UIKit
import Core
import BackgroundTasks
import Waitlist

final class VPNWaitlistDebugViewController: UITableViewController {

    enum Sections: Int, CaseIterable {

        case waitlistInformation
        case debuggingActions

    }

    private let waitlistInformationTitles = [
        WaitlistInformationRows.waitlistTimestamp: "Timestamp",
        WaitlistInformationRows.waitlistToken: "Token",
        WaitlistInformationRows.waitlistInviteCode: "Invite Code",
        WaitlistInformationRows.termsAccepted: "T&C Accepted",
        WaitlistInformationRows.backgroundTask: "Earliest Refresh Date"
    ]

    enum WaitlistInformationRows: Int, CaseIterable {

        case waitlistTimestamp
        case waitlistToken
        case waitlistInviteCode
        case termsAccepted
        case backgroundTask

    }

    private let debuggingActionTitles = [
        DebuggingActionRows.resetTermsAndConditionsAcceptance: "Reset T&C Acceptance",
        DebuggingActionRows.scheduleWaitlistNotification: "Fire Waitlist Notification in 3 seconds",
        DebuggingActionRows.setMockInviteCode: "Set Mock Invite Code",
        DebuggingActionRows.deleteInviteCode: "Delete Invite Code"
    ]

    enum DebuggingActionRows: Int, CaseIterable {

        case resetTermsAndConditionsAcceptance
        case scheduleWaitlistNotification
        case setMockInviteCode
        case deleteInviteCode

    }

    private let storage = WaitlistKeychainStore(waitlistIdentifier: VPNWaitlist.identifier)

    private var backgroundTaskExecutionDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let clearDataItem = UIBarButtonItem(image: UIImage(systemName: "trash")!,
                                             style: .done,
                                             target: self,
                                             action: #selector(presentClearDataPrompt(_:)))
        clearDataItem.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearDataItem

        BGTaskScheduler.shared.getPendingTaskRequests { tasks in
            if let task = tasks.first(where: { $0.identifier == VPNWaitlist.backgroundRefreshTaskIdentifier }) {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .medium

                self.backgroundTaskExecutionDate = formatter.string(from: task.earliestBeginDate!)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .waitlistInformation: return WaitlistInformationRows.allCases.count
        case .debuggingActions: return DebuggingActionRows.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections(rawValue: indexPath.section)!

        switch section {
        case .waitlistInformation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            let row = WaitlistInformationRows(rawValue: indexPath.row)!
            cell.textLabel?.text = waitlistInformationTitles[row]

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

            case .termsAccepted:
                if NetworkProtectionTermsAndConditionsUserDefaultsStore().networkProtectionWaitlistTermsAndConditionsAccepted {
                    cell.detailTextLabel?.text = "Yes"
                } else {
                    cell.detailTextLabel?.text = "No"
                }

            case .backgroundTask:
                cell.detailTextLabel?.text = backgroundTaskExecutionDate ?? "None"
            }

            return cell

        case .debuggingActions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
            let row = DebuggingActionRows(rawValue: indexPath.row)!
            cell.textLabel?.text = debuggingActionTitles[row]

            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Sections(rawValue: indexPath.section)!

        switch section {
        case .waitlistInformation: break
        case .debuggingActions:
            let row = DebuggingActionRows(rawValue: indexPath.row)!

            switch row {
            case .resetTermsAndConditionsAcceptance:
                var termsAndConditionsStore = NetworkProtectionTermsAndConditionsUserDefaultsStore()
                termsAndConditionsStore.networkProtectionWaitlistTermsAndConditionsAccepted = false
            case .scheduleWaitlistNotification:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.storage.store(inviteCode: "ABCD1234")
                    VPNWaitlist.shared.sendInviteCodeAvailableNotification()
                }
            case .setMockInviteCode:
                storage.store(inviteCode: "ABCD1234")
            case .deleteInviteCode:
                storage.delete(field: .inviteCode)
                tableView.reloadData()
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

    @objc
    private func presentClearDataPrompt(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Clear Waitlist Data?", message: nil, preferredStyle: .actionSheet)

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.barButtonItem = (sender as? UIBarButtonItem)
        }

        alert.addAction(UIAlertAction(title: "Clear Data", style: .destructive, handler: { _ in
            self.clearDataAndReload()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func clearDataAndReload() {
        storage.deleteWaitlistState()
        var termsAndConditionsStore = NetworkProtectionTermsAndConditionsUserDefaultsStore()
        termsAndConditionsStore.networkProtectionWaitlistTermsAndConditionsAccepted = false

        tableView.reloadData()
    }
}

#endif
