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
import Common
import Network
import NetworkExtension
import NetworkProtection
import Subscription

final class NetworkProtectionDebugViewController: UITableViewController {
    private let titles = [
        Sections.featureVisibility: "Feature Visibility",
        Sections.clearData: "Clear Data",
        Sections.debugFeature: "Debug Features",
        Sections.debugCommand: "Debug Commands",
        Sections.simulateFailure: "Simulate Failure",
        Sections.registrationKey: "Registration Key",
        Sections.networkPath: "Network Path",
        Sections.connectionTest: "Connection Test",
        Sections.vpnConfiguration: "VPN Configuration",
        Sections.vpnMetadata: "VPN Metadata",
    ]

    enum Sections: Int, CaseIterable {
        case featureVisibility
        case clearData
        case debugFeature
        case debugCommand
        case simulateFailure
        case registrationKey
        case connectionTest
        case networkPath
        case vpnConfiguration
        case vpnMetadata
    }

    enum FeatureVisibilityRows: Int, CaseIterable {
        case toggleSelectedEnvironment
        case updateSubscriptionOverride
        case debugInfo
    }

    enum ClearDataRows: Int, CaseIterable {
        case removeVPNConfiguration
    }

    enum DebugFeatureRows: Int, CaseIterable {
        case toggleAlwaysOn
        case enforceRoutes
    }

    enum SimulateFailureRows: Int, CaseIterable {
        case tunnelFailure
        case controllerFailure
        case crashFatalError
        case crashMemory
        case connectionInterruption
    }

    enum RegistrationKeyRows: Int, CaseIterable {
        case expireNow
    }

    enum ExtensionDebugCommandRows: Int, CaseIterable {
        case triggerTestNotification
        case shutDown
        case showEntitlementMessaging
        case resetEntitlementMessaging
        case startSnooze
    }

    enum NetworkPathRows: Int, CaseIterable {
        case networkPath
    }

    enum ConnectionTestRows: Int, CaseIterable {
        case runConnectionTest
    }

    enum ConfigurationRows: Int, CaseIterable {
        case baseConfigurationData
        case fullProtocolConfigurationData
    }

    enum MetadataRows: Int, CaseIterable {
        case refreshMetadata
        case metadataContents
    }

    // MARK: Properties

    private let debugFeatures: NetworkProtectionDebugFeatures
    private let tokenStore: NetworkProtectionTokenStore
    private let pathMonitor = NWPathMonitor()

    private var currentNetworkPath: String?
    private var baseConfigurationData: String?
    private var fullProtocolConfigurationData: String?
    private var vpnMetadata: VPNMetadata?

    private struct ConnectionTestResult {
        let interface: String
        let version: String
        let success: Bool
        let errorDescription: String?
    }

    private var connectionTestResults: [ConnectionTestResult] = []
    private var connectionTestResultError: String?
    private let connectionTestQueue = DispatchQueue(label: "com.duckduckgo.ios.vpnDebugConnectionTestQueue")
    private let accountManager: AccountManager

    // MARK: Lifecycle

    required init?(coder: NSCoder,
                   tokenStore: NetworkProtectionTokenStore,
                   debugFeatures: NetworkProtectionDebugFeatures = NetworkProtectionDebugFeatures(),
                   accountManager: AccountManager) {
        
        self.debugFeatures = debugFeatures
        self.tokenStore = tokenStore
        self.accountManager = accountManager

        super.init(coder: coder)
    }

    required convenience init?(coder: NSCoder) {
        self.init(coder: coder, tokenStore: AppDependencyProvider.shared.networkProtectionKeychainTokenStore,
                  accountManager: AppDependencyProvider.shared.subscriptionManager.accountManager)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConfigurationData()
        startPathMonitor()

        Task {
            await self.refreshMetadata()
        }
    }

    // MARK: Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.font = .daxBodyRegular()
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .none

        switch Sections(rawValue: indexPath.section) {

        case .clearData:
            switch ClearDataRows(rawValue: indexPath.row) {
            case .removeVPNConfiguration:
                cell.textLabel?.text = "Remove VPN Configuration"
            case .none:
                break
            }

        case .debugFeature:
            configure(cell, forDebugFeatureAtRow: indexPath.row)

        case .debugCommand:
            configure(cell, forNotificationRow: indexPath.row)

        case .simulateFailure:
            configure(cell, forSimulateFailureAtRow: indexPath.row)

        case .registrationKey:
            configure(cell, forRegistrationKeyRow: indexPath.row)

        case .networkPath:
            configure(cell, forNetworkPathRow: indexPath.row)

        case .connectionTest:
            configure(cell, forConnectionTestRow: indexPath.row)

        case .vpnConfiguration:
            configure(cell, forConfigurationRow: indexPath.row)

        case .vpnMetadata:
            configure(cell, forMetadataRow: indexPath.row)

        case .featureVisibility:
            configure(cell, forVisibilityRow: indexPath.row)

        case .none:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .clearData: return ClearDataRows.allCases.count
        case .debugFeature: return DebugFeatureRows.allCases.count
        case .debugCommand: return ExtensionDebugCommandRows.allCases.count
        case .simulateFailure: return SimulateFailureRows.allCases.count
        case .registrationKey: return RegistrationKeyRows.allCases.count
        case .networkPath: return NetworkPathRows.allCases.count
        case .connectionTest: return ConnectionTestRows.allCases.count + connectionTestResults.count
        case .vpnConfiguration: return ConfigurationRows.allCases.count
        case .vpnMetadata: return MetadataRows.allCases.count
        case .featureVisibility: return FeatureVisibilityRows.allCases.count
        case .none: return 0

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .clearData:
            switch ClearDataRows(rawValue: indexPath.row) {
            case .removeVPNConfiguration: deleteVPNConfiguration()
            default: break
            }
        case .debugFeature:
            didSelectDebugFeature(at: indexPath)
        case .debugCommand:
            didSelectDebugCommand(at: indexPath)
        case .simulateFailure:
            didSelectSimulateFailure(at: indexPath)
        case .registrationKey:
            didSelectRegistrationKeyAction(at: indexPath)
        case .networkPath:
            break
        case .connectionTest:
            if indexPath.row == connectionTestResults.count {
                Task {
                    await runConnectionTest()
                }
            }
        case .vpnConfiguration:
            break
        case .vpnMetadata:
            didSelectVPNMetadataAction(at: indexPath)
        case .featureVisibility:
            didSelectFeatureVisibility(at: indexPath)
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
        case .connectionInterruption:
            cell.textLabel?.text = "Connection Interruption"
        case .none:
            break
        }
    }

    private func didSelectSimulateFailure(at indexPath: IndexPath) {
        switch SimulateFailureRows(rawValue: indexPath.row) {
        case .controllerFailure:
            NetworkProtectionTunnelController.shouldSimulateFailure = true
        case .tunnelFailure:
            triggerSimulation(.tunnelFailure)
        case .crashFatalError:
            triggerSimulation(.crashFatalError)
        case .crashMemory:
            triggerSimulation(.crashMemory)
        case .connectionInterruption:
            triggerSimulation(.connectionInterruption)
        case .none:
            break
        }
    }

    private func triggerSimulation(_ option: NetworkProtectionSimulationOption) {
        Task {
            await NetworkProtectionDebugUtilities().triggerSimulation(option)
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
        case .enforceRoutes:
            cell.textLabel?.text = "Enforce Routes"

            if !AppDependencyProvider.shared.vpnSettings.enforceRoutes {
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
        case .enforceRoutes:
            AppDependencyProvider.shared.vpnSettings.enforceRoutes.toggle()
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

    private func didSelectRegistrationKeyAction(at indexPath: IndexPath) {
        switch RegistrationKeyRows(rawValue: indexPath.row) {
        case .expireNow:
            Task {
                await NetworkProtectionDebugUtilities().expireRegistrationKeyNow()
            }
        case .none:
            break
        }
    }

    // MARK: VPN Extension Debug Commands

    private func configure(_ cell: UITableViewCell, forNotificationRow row: Int) {
        switch ExtensionDebugCommandRows(rawValue: row) {
        case .triggerTestNotification:
            cell.textLabel?.text = "Test Notification"
        case .shutDown:
            cell.textLabel?.text = "Disable VPN From Extension"
        case .showEntitlementMessaging:
            cell.textLabel?.text = "Show Entitlement Messaging"
        case .resetEntitlementMessaging:
            cell.textLabel?.text = "Reset Entitlement Messaging"
        case .startSnooze:
            cell.textLabel?.text = "Snooze For 30 Seconds"
        case .none:
            break
        }
    }

    private func didSelectDebugCommand(at indexPath: IndexPath) {
        switch ExtensionDebugCommandRows(rawValue: indexPath.row) {
        case .triggerTestNotification:
            Task {
                try await NetworkProtectionDebugUtilities().sendTestNotificationRequest()
            }
        case .shutDown:
            Task {
                await NetworkProtectionDebugUtilities().disableConnectOnDemandAndShutDown()
            }
        case .showEntitlementMessaging:
            UserDefaults.networkProtectionGroupDefaults.enableEntitlementMessaging()
        case .resetEntitlementMessaging:
            UserDefaults.networkProtectionGroupDefaults.resetEntitlementMessaging()
        case .startSnooze:
            Task {
                await NetworkProtectionDebugUtilities().startSnooze(duration: .seconds(30))
            }
        case .none:
            break
        }
    }

    // MARK: Network Path

    private func configure(_ cell: UITableViewCell, forNetworkPathRow row: Int) {
        cell.textLabel?.font = .monospacedSystemFont(ofSize: 13.0, weight: .regular)
        cell.textLabel?.text = currentNetworkPath ?? "Loading path..."
    }

    private func startPathMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            var pathDescription: String = """
            Status: \(path.status)
            Interfaces: \(path.availableInterfaces)
            Gateways: \(path.gateways)
            Is Expensive: \(path.isExpensive)
            Is Constrained: \(path.isConstrained)
            Supports DNS: \(path.supportsDNS)
            Supports IPv4: \(path.supportsIPv4)
            Supports IPv6: \(path.supportsIPv6)
            """

            if path.status == .unsatisfied {
                pathDescription.append("\nUnsatisfied Reason: \(path.unsatisfiedReason)")
            }

            self?.currentNetworkPath = pathDescription
            self?.tableView.reloadData()
        }

        pathMonitor.start(queue: .main)
    }

    // MARK: Connection Test

    private func configure(_ cell: UITableViewCell, forConnectionTestRow row: Int) {
        if row == connectionTestResults.count {
            cell.textLabel?.text = "Run Connection Test"
        } else {
            let result = self.connectionTestResults[row]

            if result.success {
                cell.textLabel?.text = "✅ \(result.interface) IP\(result.version)"
            } else {
                cell.textLabel?.text = "❌ \(result.interface) IP\(result.version), error: \(result.errorDescription ?? "None")"
            }
        }
    }

    @MainActor
    private func runConnectionTest() async {
        let interfaces = pathMonitor.currentPath.availableInterfaces

        guard !interfaces.isEmpty else {
            self.connectionTestResultError = "No interfaces available"
            return
        }

        var results = [ConnectionTestResult]()

        for interface in interfaces {
            let ipv4Result = await testConnection(interface: interface, version: .v4)
            let ipv6Result = await testConnection(interface: interface, version: .v6)

            results.append(ipv4Result)
            results.append(ipv6Result)
        }

        self.connectionTestResults = results
        self.tableView.reloadData()
    }

    private func testConnection(interface: NWInterface, version: NWProtocolIP.Options.Version) async -> ConnectionTestResult {
        let interfaceString = interface.debugDescription
        let versionString = String(describing: version)

        let endpoint = NWEndpoint.hostPort(host: .name("apple.com", nil), port: .https)
        let parameters = NWParameters.tcp
        parameters.requiredInterface = interface

        // swiftlint:disable force_cast
        let ip = parameters.defaultProtocolStack.internetProtocol! as! NWProtocolIP.Options
        ip.version = version
        // swiftlint:enable force_cast

        let connection = NWConnection(to: endpoint, using: parameters)
        let stateUpdateStream = connection.stateUpdateStream
        connection.start(queue: self.connectionTestQueue)

        defer {
            connection.cancel()
        }

        do {
            return try await withTimeout(.seconds(5)) {
                for await state in stateUpdateStream {
                    if case .ready = state {
                        return ConnectionTestResult(
                            interface: connection.endpoint.interface?.debugDescription ?? interfaceString,
                            version: versionString,
                            success: true,
                            errorDescription: nil
                        )
                    }

                    if case .waiting(let error) = state {
                        return ConnectionTestResult(
                            interface: interface.debugDescription,
                            version: versionString,
                            success: false,
                            errorDescription: error.localizedDescription
                        )
                    }
                }

                let currentConnectionState = connection.state
                return ConnectionTestResult(
                    interface: interfaceString,
                    version: versionString,
                    success: false,
                    errorDescription: String(describing: currentConnectionState)
                )
            }
        } catch {
            return ConnectionTestResult(interface: interfaceString, version: versionString, success: false, errorDescription: "Timeout reached")
        }

    }

    // MARK: Configuration

    private func configure(_ cell: UITableViewCell, forConfigurationRow row: Int) {
        cell.textLabel?.font = .monospacedSystemFont(ofSize: 13.0, weight: .regular)

        switch ConfigurationRows(rawValue: row) {
        case .baseConfigurationData:
            cell.textLabel?.text = baseConfigurationData ?? "Loading base configuration..."
        case .fullProtocolConfigurationData:
            cell.textLabel?.text = fullProtocolConfigurationData ?? "Loading protocol configuration..."
        case .none:
            assertionFailure("Couldn't map configuration row")
        }
    }

    private func loadConfigurationData() {
        Task { @MainActor in
            do {
                let tunnels = try await NETunnelProviderManager.loadAllFromPreferences()

                guard let tunnel = tunnels.first else {
                    self.baseConfigurationData = "No configurations found"
                    self.fullProtocolConfigurationData = ""
                    return
                }

                guard let protocolConfiguration = tunnel.protocolConfiguration else {
                    self.baseConfigurationData = "No protocol configuration found"
                    self.fullProtocolConfigurationData = ""
                    return
                }

                let configurationDescriptionString = String(describing: tunnel)
                    .replacingOccurrences(of: "    ", with: "  ")

                let protocolConfigurationString = String(describing: protocolConfiguration)
                    .replacingOccurrences(of: "    ", with: "")
                    .dropping(prefix: "\n")

                self.baseConfigurationData = "CONFIGURATION OVERVIEW:\n\n" + configurationDescriptionString
                self.fullProtocolConfigurationData = "FULL PROTOCOL CONFIGURATION:\n\n" + protocolConfigurationString
            } catch {
                self.baseConfigurationData = "Failed to load configuration: \(error.localizedDescription)"
                self.fullProtocolConfigurationData = ""
            }

            self.tableView.reloadData()
        }
    }

    // MARK: - VPN Metadata

    private func configure(_ cell: UITableViewCell, forMetadataRow row: Int) {
        cell.textLabel?.font = .systemFont(ofSize: 17)

        switch MetadataRows(rawValue: row) {
        case .refreshMetadata:
            cell.textLabel?.text = "Refresh Metadata"
        case .metadataContents:
            cell.textLabel?.font = .monospacedSystemFont(ofSize: 13.0, weight: .regular)
            cell.textLabel?.text = vpnMetadata?.toPrettyPrintedJSON() ?? "No Metadata"
        case .none:
            assertionFailure("Couldn't map configuration row")
        }
    }

    private func didSelectVPNMetadataAction(at indexPath: IndexPath) {
        switch MetadataRows(rawValue: indexPath.row) {
        case .refreshMetadata:
            Task {
                await refreshMetadata()
            }
        case .metadataContents:
            break
        case .none:
            break
        }
    }

    // MARK: Feature Visibility

    private func configure(_ cell: UITableViewCell, forVisibilityRow row: Int) {
        switch FeatureVisibilityRows(rawValue: row) {
        case .toggleSelectedEnvironment:
            let settings = AppDependencyProvider.shared.vpnSettings
            if settings.selectedEnvironment == .production {
                cell.textLabel?.text = "Selected Environment: PRODUCTION"
            } else {
                cell.textLabel?.text = "Selected Environment: STAGING"
            }
        case .updateSubscriptionOverride:
            let defaults = UserDefaults.networkProtectionGroupDefaults
            if let subscriptionOverrideEnabled = defaults.subscriptionOverrideEnabled {
                cell.textLabel?.text = subscriptionOverrideEnabled ? "Subscription Override: ENABLED" : "Subscription Override: DISABLED"
            } else {
                cell.textLabel?.text = "Subscription Override: N/A"
            }
        case .debugInfo:
            let vpnVisibility = AppDependencyProvider.shared.vpnFeatureVisibility

            cell.textLabel?.font = .monospacedSystemFont(ofSize: 13.0, weight: .regular)
            cell.textLabel?.text = """
Endpoint: \(AppDependencyProvider.shared.vpnSettings.selectedEnvironment.endpointURL.absoluteString)

shouldShowVPNShortcut: \(vpnVisibility.shouldShowVPNShortcut() ? "YES" : "NO")
"""
        case .none:
            break
        }
    }

    @MainActor
    private func refreshMetadata() async {
        let collector = DefaultVPNMetadataCollector(
            statusObserver: AppDependencyProvider.shared.connectionObserver,
            serverInfoObserver: AppDependencyProvider.shared.serverInfoObserver
        )
        self.vpnMetadata = await collector.collectMetadata()
        self.tableView.reloadData()
    }
    
    private func showSubscriptionEnvAlert() {
            let alertController = UIAlertController(title: "Use Subscription Environment", message: nil, preferredStyle: .alert)

            alertController.message = "Go to Debug > Subscription > Environment to change the environment."
        
            // Add a "Cancel" action
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(cancelAction)

            // Present the alert
            present(alertController, animated: true, completion: nil)
            
    }

    private func didSelectFeatureVisibility(at indexPath: IndexPath) {
        switch FeatureVisibilityRows(rawValue: indexPath.row) {
        case .toggleSelectedEnvironment:
            showSubscriptionEnvAlert()
        case .updateSubscriptionOverride:
            let defaults = UserDefaults.networkProtectionGroupDefaults
            if let subscriptionOverrideEnabled = defaults.subscriptionOverrideEnabled {
                if subscriptionOverrideEnabled {
                    defaults.subscriptionOverrideEnabled = false
                    accountManager.signOut()
                } else {
                    defaults.resetsubscriptionOverrideEnabled()
                }
            } else {
                defaults.subscriptionOverrideEnabled = true
            }
            tableView.reloadData()
        case .debugInfo, .none:
            break
        }
    }

    // MARK: Selection Actions

    private func deleteVPNConfiguration() {
        Task {
            await AppDependencyProvider.shared.networkProtectionTunnelController.stop()
            await AppDependencyProvider.shared.networkProtectionTunnelController.removeVPN(reason: .debugMenu)
        }
    }
}

extension NWConnection {

    var stateUpdateStream: AsyncStream<State> {
        let (stream, continuation) = AsyncStream.makeStream(of: State.self)

        class ConnectionLifeTimeTracker {
            let continuation: AsyncStream<State>.Continuation
            init(continuation: AsyncStream<State>.Continuation) {
                self.continuation = continuation
            }
            deinit {
                continuation.finish()
            }
        }
        let connectionLifeTimeTracker = ConnectionLifeTimeTracker(continuation: continuation)

        self.stateUpdateHandler = { state in
            withExtendedLifetime(connectionLifeTimeTracker) {
                _=continuation.yield(state)

                switch state {
                case .cancelled, .failed:
                    continuation.finish()
                default: break
                }
            }
        }

        return stream
    }

}
