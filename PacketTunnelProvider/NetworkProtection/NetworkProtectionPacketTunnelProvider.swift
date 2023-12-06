//
//  NetworkProtectionPacketTunnelProvider.swift
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

import Foundation
import Common
import Combine
import Core
import Networking
import NetworkExtension
import NetworkProtection

// Initial implementation for initial Network Protection tests. Will be fleshed out with https://app.asana.com/0/1203137811378537/1204630829332227/f
final class NetworkProtectionPacketTunnelProvider: PacketTunnelProvider {

    private var cancellables = Set<AnyCancellable>()

    // MARK: - PacketTunnelProvider.Event reporting

    private static var packetTunnelProviderEvents: EventMapping<PacketTunnelProvider.Event> = .init { event, _, _, _ in
        switch event {
        case .userBecameActive:
            DailyPixel.fire(pixel: .networkProtectionActiveUser)
        case .reportLatency(ms: let ms, server: let server, networkType: let networkType):
            let params = [
                PixelParameters.latency: String(ms),
                PixelParameters.server: server,
                PixelParameters.networkType: networkType.rawValue
            ]
            Pixel.fire(pixel: .networkProtectionLatency, withAdditionalParameters: params)
        case .rekeyCompleted:
            Pixel.fire(pixel: .networkProtectionRekeyCompleted)
        }
    }

    // MARK: - Error Reporting

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func networkProtectionDebugEvents(controllerErrorStore: NetworkProtectionTunnelErrorStore) -> EventMapping<NetworkProtectionError>? {
        return EventMapping { event, _, _, _ in
            let pixelEvent: Pixel.Event
            var pixelError: Error?
            var params: [String: String] = [:]

#if DEBUG
            // Makes sure we see the error in the yellow NetP alert.
            controllerErrorStore.lastErrorMessage = "[Debug] Error event: \(event.localizedDescription)"
#endif
            switch event {
            case .noServerRegistrationInfo:
                pixelEvent = .networkProtectionTunnelConfigurationNoServerRegistrationInfo
            case .couldNotSelectClosestServer:
                pixelEvent = .networkProtectionTunnelConfigurationCouldNotSelectClosestServer
            case .couldNotGetPeerPublicKey:
                pixelEvent = .networkProtectionTunnelConfigurationCouldNotGetPeerPublicKey
            case .couldNotGetPeerHostName:
                pixelEvent = .networkProtectionTunnelConfigurationCouldNotGetPeerHostName
            case .couldNotGetInterfaceAddressRange:
                pixelEvent = .networkProtectionTunnelConfigurationCouldNotGetInterfaceAddressRange
            case .failedToFetchServerList(let eventError):
                pixelEvent = .networkProtectionClientFailedToFetchServerList
                pixelError = eventError
            case .failedToParseServerListResponse:
                pixelEvent = .networkProtectionClientFailedToParseServerListResponse
            case .failedToEncodeRegisterKeyRequest:
                pixelEvent = .networkProtectionClientFailedToEncodeRegisterKeyRequest
            case .failedToFetchRegisteredServers(let eventError):
                pixelEvent = .networkProtectionClientFailedToFetchRegisteredServers
                pixelError = eventError
            case .failedToParseRegisteredServersResponse:
                pixelEvent = .networkProtectionClientFailedToParseRegisteredServersResponse
            case .failedToEncodeRedeemRequest, .invalidInviteCode, .failedToRedeemInviteCode, .failedToParseRedeemResponse:
                pixelEvent = .networkProtectionUnhandledError
                // Should never be sent from the extension
            case .invalidAuthToken:
                pixelEvent = .networkProtectionClientInvalidAuthToken
            case .serverListInconsistency:
                return
            case .failedToEncodeServerList:
                pixelEvent = .networkProtectionServerListStoreFailedToEncodeServerList
            case .failedToDecodeServerList:
                pixelEvent = .networkProtectionServerListStoreFailedToDecodeServerList
            case .failedToWriteServerList(let eventError):
                pixelEvent = .networkProtectionServerListStoreFailedToWriteServerList
                pixelError = eventError
            case .noServerListFound:
                return
            case .couldNotCreateServerListDirectory:
                return
            case .failedToReadServerList(let eventError):
                pixelEvent = .networkProtectionServerListStoreFailedToReadServerList
                pixelError = eventError
            case .failedToCastKeychainValueToData(let field):
                pixelEvent = .networkProtectionKeychainErrorFailedToCastKeychainValueToData
                params[PixelParameters.keychainFieldName] = field
            case .keychainReadError(let field, let status):
                pixelEvent = .networkProtectionKeychainReadError
                params[PixelParameters.keychainFieldName] = field
                params[PixelParameters.keychainErrorCode] = String(status)
            case .keychainWriteError(let field, let status):
                pixelEvent = .networkProtectionKeychainWriteError
                params[PixelParameters.keychainFieldName] = field
                params[PixelParameters.keychainErrorCode] = String(status)
            case .keychainDeleteError(let status): // TODO: Check whether field needed here
                pixelEvent = .networkProtectionKeychainDeleteError
                params[PixelParameters.keychainErrorCode] = String(status)
            case .wireGuardCannotLocateTunnelFileDescriptor:
                pixelEvent = .networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor
            case .wireGuardInvalidState:
                pixelEvent = .networkProtectionWireguardErrorInvalidState
            case .wireGuardDnsResolution:
                pixelEvent = .networkProtectionWireguardErrorFailedDNSResolution
            case .wireGuardSetNetworkSettings(let error):
                pixelEvent = .networkProtectionWireguardErrorCannotSetNetworkSettings
                pixelError = error
            case .startWireGuardBackend(let code):
                pixelEvent = .networkProtectionWireguardErrorCannotStartWireguardBackend
                params[PixelParameters.wireguardErrorCode] = String(code)
            case .noAuthTokenFound:
                pixelEvent = .networkProtectionNoAuthTokenFoundError
            case .unhandledError(function: let function, line: let line, error: let error):
                pixelEvent = .networkProtectionUnhandledError
                params[PixelParameters.function] = function
                params[PixelParameters.line] = String(line)
                pixelError = error
            case .failedToFetchLocationList:
                return
            case .failedToParseLocationListResponse:
                return
            }
            DailyPixel.fireDailyAndCount(pixel: pixelEvent, error: pixelError, withAdditionalParameters: params)
        }
    }

    public override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        super.startTunnel(options: options) { error in
            if error != nil {
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionFailedToStartTunnel, error: error)
            }
            completionHandler(error)
        }
    }

    public override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        switch reason {
        case .appUpdate, .userInitiated:
            break
        default:
            DailyPixel.fireDailyAndCount(
                pixel: .networkProtectionDisconnected,
                withAdditionalParameters: [PixelParameters.reason: String(reason.rawValue)]
            )
        }
        super.stopTunnel(with: reason, completionHandler: completionHandler)
    }

    @objc init() {
        let tokenStore = NetworkProtectionKeychainTokenStore(keychainType: .dataProtection(.unspecified),
                                                             errorEvents: nil)
        let errorStore = NetworkProtectionTunnelErrorStore()
        let notificationsPresenter = NetworkProtectionUNNotificationPresenter()
        let settings = VPNSettings(defaults: .networkProtectionGroupDefaults)
        let nofificationsPresenterDecorator = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: settings,
            wrappee: notificationsPresenter
        )
        notificationsPresenter.requestAuthorization()
        super.init(notificationsPresenter: nofificationsPresenterDecorator,
                   tunnelHealthStore: NetworkProtectionTunnelHealthStore(),
                   controllerErrorStore: errorStore,
                   keychainType: .dataProtection(.unspecified),
                   tokenStore: tokenStore,
                   debugEvents: Self.networkProtectionDebugEvents(controllerErrorStore: errorStore),
                   providerEvents: Self.packetTunnelProviderEvents,
                   settings: settings)
        startMonitoringMemoryPressureEvents()
        observeServerChanges()
        observeStatusChanges()
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)
    }

    private func startMonitoringMemoryPressureEvents() {
        let source = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: nil)

        let queue = DispatchQueue.init(label: "com.duckduckgo.mobile.ios.alpha.NetworkExtension.memoryPressure")
        queue.async {
            source.setEventHandler {
                let event: DispatchSource.MemoryPressureEvent  = source.mask
                print(event)
                switch event {
                case DispatchSource.MemoryPressureEvent.normal:
                    break
                case DispatchSource.MemoryPressureEvent.warning:
                    DailyPixel.fire(pixel: .networkProtectionMemoryWarning)
                case DispatchSource.MemoryPressureEvent.critical:
                    DailyPixel.fire(pixel: .networkProtectionMemoryCritical)
                default:
                    break
                }

            }
            source.resume()
        }
    }

    private func observeServerChanges() {
        lastSelectedServerInfoPublisher.sink { server in
            let location = server?.serverLocation ?? "Unknown Location"
            UserDefaults.networkProtectionGroupDefaults.set(location, forKey: NetworkProtectionUserDefaultKeys.lastSelectedServer)
        }
        .store(in: &cancellables)
    }

    private let activationDateStore = DefaultVPNWaitlistActivationDateStore()

    private func observeStatusChanges() {
        connectionStatusPublisher.sink { [weak self] status in
            if case .connected = status {
                self?.activationDateStore.setActivationDateIfNecessary()
            }
        }
        .store(in: &cancellables)
    }

}

#endif
