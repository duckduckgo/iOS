//
//  NetworkProtectionDebugViewController.swift
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
import NetworkProtection

final class NetworkProtectionDebugViewController: UITableViewController {
    private let titles = [
        Sections.keychain: "Keychain",
        Sections.simulateFailure: "Simulate Failure"
    ]

    enum Sections: Int, CaseIterable {

        case keychain
        case simulateFailure

    }

    enum KeychainRows: Int, CaseIterable {

        case clearAuthToken

    }

    enum SimulateFailureRows: Int, CaseIterable {

        case tunnelFailure
        case controllerFailure

    }

    private let tokenStore: NetworkProtectionTokenStore

    init?(coder: NSCoder,
          tokenStore: NetworkProtectionTokenStore) {

        self.tokenStore = tokenStore

        super.init(coder: coder)
    }

    required convenience init?(coder: NSCoder) {
        self.init(coder: coder, tokenStore: NetworkProtectionKeychainTokenStore())
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.detailTextLabel?.text = nil

        switch Sections(rawValue: indexPath.section) {

        case .keychain:
            switch KeychainRows(rawValue: indexPath.row) {
            case .clearAuthToken:
                cell.textLabel?.text = "Clear auth token"
            case .none:
                break
            }

        case .simulateFailure:
            switch SimulateFailureRows(rawValue: indexPath.row) {
            case .controllerFailure:
                cell.textLabel?.text = "Enable NetP > Controller Failure"
            case .tunnelFailure:
                cell.textLabel?.text = "Enable NetP > Tunnel Failure"
            case .none:
                break
            }
        case.none:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .keychain: return KeychainRows.allCases.count
        case .simulateFailure: return SimulateFailureRows.allCases.count
        case .none: return 0

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .keychain:
            switch KeychainRows(rawValue: indexPath.row) {
            case .clearAuthToken: clearAuthToken()
            default: break
            }
        case .simulateFailure:
            switch SimulateFailureRows(rawValue: indexPath.row) {
            case .controllerFailure: simulateControllerFailure()
            case .tunnelFailure: simulaterTunnelFailure()
            case .none: return
            }
        case .none:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Selection Actions

    private func clearAuthToken() {
        try? tokenStore.deleteToken()
    }

    private func simulateControllerFailure() {
        NetworkProtectionTunnelController.simulationOptions.setEnabled(true, option: .controllerFailure)
    }

    private func simulaterTunnelFailure() {
        NetworkProtectionTunnelController.simulationOptions.setEnabled(true, option: .tunnelFailure)
    }
}
