//
//  VPNMetadataCollector.swift
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

import Foundation
import BrowserServicesKit
import Core
import Common
import NetworkProtection
import NetworkExtension
import Network

struct VPNMetadata: Encodable {

    struct AppInfo: Encodable {
        let appVersion: String
        let lastVersionRun: String
        let isInternalUser: Bool
    }

    struct DeviceInfo: Encodable {
        let osVersion: String
        let lowPowerModeEnabled: Bool
    }

    struct NetworkInfo: Encodable {
        let currentPath: String
        let lastPathChangeDate: String
        let lastPathChange: String
        let secondsSincePathChange: String
    }

    struct VPNState: Encodable {
        let connectionState: String
        let lastDisconnectError: String
        let connectedServer: String
        let connectedServerIP: String
    }

    struct VPNSettingsState: Encodable {
        let connectOnLoginEnabled: Bool
        let includeAllNetworksEnabled: Bool
        let enforceRoutesEnabled: Bool
        let excludeLocalNetworksEnabled: Bool
        let notifyStatusChangesEnabled: Bool
        let selectedServer: String
    }

    let appInfo: AppInfo
    let deviceInfo: DeviceInfo
    let networkInfo: NetworkInfo
    let vpnState: VPNState
    let vpnSettingsState: VPNSettingsState

    func toPrettyPrintedJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard let encodedMetadata = try? encoder.encode(self) else {
            assertionFailure("Failed to encode metadata")
            return nil
        }

        return String(data: encodedMetadata, encoding: .utf8)
    }

    func toBase64() -> String {
        let encoder = JSONEncoder()

        do {
            let encodedMetadata = try encoder.encode(self)
            return encodedMetadata.base64EncodedString()
        } catch {
            return "Failed to encode metadata to JSON, error message: \(error.localizedDescription)"
        }
    }
}

protocol VPNMetadataCollector {
    func collectMetadata() async -> VPNMetadata
}

final class DefaultVPNMetadataCollector: VPNMetadataCollector {
    private let statusObserver: ConnectionStatusObserver
    private let serverInfoObserver: ConnectionServerInfoObserver
    private let settings: VPNSettings

    init(statusObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession(),
         serverInfoObserver: ConnectionServerInfoObserver = ConnectionServerInfoObserverThroughSession(),
         settings: VPNSettings = .init(defaults: .networkProtectionGroupDefaults)) {
        self.statusObserver = statusObserver
        self.serverInfoObserver = serverInfoObserver
        self.settings = settings
    }

    func collectMetadata() async -> VPNMetadata {
        let appInfoMetadata = collectAppInfoMetadata()
        let deviceInfoMetadata = collectDeviceInfoMetadata()
        let networkInfoMetadata = await collectNetworkInformation()
        let vpnState = await collectVPNState()
        let vpnSettingsState = collectVPNSettingsState()

        return VPNMetadata(
            appInfo: appInfoMetadata,
            deviceInfo: deviceInfoMetadata,
            networkInfo: networkInfoMetadata,
            vpnState: vpnState,
            vpnSettingsState: vpnSettingsState
        )
    }

    // MARK: - Metadata Collection

    private func collectAppInfoMetadata() -> VPNMetadata.AppInfo {
        let appVersion = AppVersion.shared.versionNumber
        let versionStore = NetworkProtectionLastVersionRunStore()
        let isInternalUser = AppDependencyProvider.shared.internalUserDecider.isInternalUser

        return .init(appVersion: appVersion, lastVersionRun: versionStore.lastVersionRun ?? "Unknown", isInternalUser: isInternalUser)
    }
    
    private func collectDeviceInfoMetadata() -> VPNMetadata.DeviceInfo {
        .init(osVersion: AppVersion.shared.osVersion, lowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled)
    }
    
    func collectNetworkInformation() async -> VPNMetadata.NetworkInfo {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "VPNMetadataCollector.NWPathMonitor.paths"))

        var path: Network.NWPath?
        let startTime = CFAbsoluteTimeGetCurrent()

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let networkPathChange = settings.networkPathChange

        let lastPathChange = String(describing: networkPathChange)
        var lastPathChangeDate = "unknown"
        var secondsSincePathChange = "unknown"

        if let changeDate = networkPathChange?.date {
            lastPathChangeDate = dateFormatter.string(from: changeDate)
            secondsSincePathChange = String(Date().timeIntervalSince(changeDate))
        }

        while true {
            if !monitor.currentPath.availableInterfaces.isEmpty {
                path = monitor.currentPath
                monitor.cancel()

                return .init(currentPath: path.debugDescription,
                             lastPathChangeDate: lastPathChangeDate,
                             lastPathChange: lastPathChange,
                             secondsSincePathChange: secondsSincePathChange)
            }

            // Wait up to 3 seconds to fetch the path.
            let currentExecutionTime = CFAbsoluteTimeGetCurrent() - startTime
            if currentExecutionTime >= 3.0 {
                return .init(currentPath: "Timed out fetching path",
                             lastPathChangeDate: lastPathChangeDate,
                             lastPathChange: lastPathChange,
                             secondsSincePathChange: secondsSincePathChange)
            }
        }
    }

    @MainActor
    func collectVPNState() async -> VPNMetadata.VPNState {
        let connectionState = String(describing: statusObserver.recentValue)
        let connectedServer = serverInfoObserver.recentValue.serverLocation ?? "none"
        let connectedServerIP = serverInfoObserver.recentValue.serverAddress ?? "none"

        return .init(connectionState: connectionState,
                     lastDisconnectError: await lastDisconnectError(),
                     connectedServer: connectedServer,
                     connectedServerIP: connectedServerIP)
    }

    public func lastDisconnectError() async -> String {
        if #available(iOS 16, *) {
            guard let tunnelManager = try? await NETunnelProviderManager.loadAllFromPreferences().first else {
                return "none"
            }

            return await withCheckedContinuation { continuation in
                tunnelManager.connection.fetchLastDisconnectError { error in
                    let message = {
                        if let error = error as? NSError {
                            if error.domain == NEVPNConnectionErrorDomain, let code = NEDNSSettingsManagerError(rawValue: error.code) {
                                switch code {
                                case .configurationCannotBeRemoved:
                                    return "configurationCannotBeRemoved"
                                case .configurationDisabled:
                                    return "configurationDisabled"
                                case .configurationInvalid:
                                    return "configurationInvalid"
                                case .configurationStale:
                                    return "configurationStale"
                                default:
                                    return error.localizedDescription
                                }
                            } else {
                                return error.localizedDescription
                            }
                        }

                        return "none"
                    }()

                    continuation.resume(returning: message)
                }
            }
        }

        return "none"
    }

    func collectVPNSettingsState() -> VPNMetadata.VPNSettingsState {
        return .init(
            connectOnLoginEnabled: settings.connectOnLogin,
            includeAllNetworksEnabled: settings.includeAllNetworks,
            enforceRoutesEnabled: settings.enforceRoutes,
            excludeLocalNetworksEnabled: settings.excludeLocalNetworks,
            notifyStatusChangesEnabled: settings.notifyStatusChanges,
            selectedServer: settings.selectedServer.stringValue ?? "automatic"
        )
    }
}
