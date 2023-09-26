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

#if !NETWORK_PROTECTION

final class NetworkProtectionDebugViewController: UITableViewController {
    // Just an empty VC
}

#else

import NetworkProtection

final class NetworkProtectionDebugViewController: UITableViewController {
    private let titles = [
        Sections.keychain: "Keychain",
        Sections.debugFeature: "Debug Features",
        Sections.simulateFailure: "Simulate Failure",
        Sections.registrationKey: "Registration Key"

    ]

    enum Sections: Int, CaseIterable {

        case keychain
        case debugFeature
        case simulateFailure
        case registrationKey

    }

    enum KeychainRows: Int, CaseIterable {

        case clearAuthToken

    }

    enum DebugFeatureRows: Int, CaseIterable {
        case toggleAlwaysOn
    }

    enum SimulateFailureRows: Int, CaseIterable {

        case tunnelFailure
        case controllerFailure
        case crashFatalError
        case crashMemory

    }

    enum RegistrationKeyRows: Int, CaseIterable {

        case expireNow

    }

    private let debugFeatures: NetworkProtectionDebugFeatures
    private let tokenStore: NetworkProtectionTokenStore

    init?(coder: NSCoder,
          tokenStore: NetworkProtectionTokenStore,
          debugFeatures: NetworkProtectionDebugFeatures = NetworkProtectionDebugFeatures()) {

        self.debugFeatures = debugFeatures
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

        case .debugFeature:
            configure(cell, forDebugFeatureAtRow: indexPath.row)

        case .simulateFailure:
            configure(cell, forSimulateFailureAtRow: indexPath.row)

        case .registrationKey:
            configure(cell, forRegistrationKeyRow: indexPath.row)

        case.none:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .keychain: return KeychainRows.allCases.count
        case .debugFeature: return DebugFeatureRows.allCases.count
        case .simulateFailure: return SimulateFailureRows.allCases.count
        case .registrationKey: return RegistrationKeyRows.allCases.count
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
        case .debugFeature:
            didSelectDebugFeature(at: indexPath)
        case .simulateFailure:
            didSelectSimulateFailure(at: indexPath)
        case .registrationKey:
            didSelectRegistationKeyAction(at: indexPath)
        case .none:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Simulate Failures

    private func configure(_ cell: UITableViewCell, forSimulateFailureAtRow row: Int) {
        switch SimulateFailureRows(rawValue: row) {
        case .controllerFailure:
            cell.textLabel?.text = "Enable NetP > Controller Failure"
        case .tunnelFailure:
            cell.textLabel?.text = "Enable NetP > Tunnel Failure"
        case .crashFatalError:
            cell.textLabel?.text = "Tunnel: Crash (Fatal Error)"
        case .crashMemory:
            cell.textLabel?.text = "Tunnel: Crash (CPU/Memory)"
        case .none:
            break
        }
    }

    private func didSelectSimulateFailure(at indexPath: IndexPath) {
        switch SimulateFailureRows(rawValue: indexPath.row) {
        case .controllerFailure: simulateFailure(option: .controllerFailure)
        case .tunnelFailure: simulateFailure(option: .tunnelFailure)
        case .crashFatalError: simulateFailure(option: .crashFatalError)
        case .crashMemory: simulateFailure(option: .crashMemory)
        case .none: return
        }
    }

    // MARK: Debug Features

    private func configure(_ cell: UITableViewCell, forDebugFeatureAtRow row: Int) {
        switch DebugFeatureRows(rawValue: row) {
        case .toggleAlwaysOn:
            cell.textLabel?.text = "Always On"

            if debugFeatures.alwaysOnDisabled {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        default:
            break
        }
    }

    private func didSelectDebugFeature(at indexPath: IndexPath) {
        switch DebugFeatureRows(rawValue: indexPath.row) {
        case .toggleAlwaysOn:
            debugFeatures.alwaysOnDisabled.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
        default:
            break
        }
    }

    // MARK: Registration Key

    private func configure(_ cell: UITableViewCell, forRegistrationKeyRow row: Int) {
        switch RegistrationKeyRows(rawValue: row) {
        case .expireNow:
            cell.textLabel?.text = "Expire Now"
        case .none:
            break
        }
    }

    private func didSelectRegistationKeyAction(at indexPath: IndexPath) {
        switch RegistrationKeyRows(rawValue: indexPath.row) {
        case .expireNow:
            Task {
                await NetworkProtectionDebugUtilities().expireRegistrationKeyNow()
            }
        case .none:
            break
        }
    }

    // MARK: Selection Actions

    private func clearAuthToken() {
        try? tokenStore.deleteToken()
    }

    private func simulateControllerFailure() {
        NetworkProtectionTunnelController.enabledSimulationOption = .controllerFailure
    }

    private func simulaterTunnelFailure() {
        NetworkProtectionTunnelController.enabledSimulationOption = .crashFatalError
    }

    private func simulateFailure(option: NetworkProtectionSimulationOption) {
        NetworkProtectionTunnelController.enabledSimulationOption = .crashMemory
    }
}

#endif
