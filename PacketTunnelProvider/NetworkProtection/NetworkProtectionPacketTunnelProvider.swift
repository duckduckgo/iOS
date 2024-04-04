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

#if SUBSCRIPTION
import Subscription
#endif

// swiftlint:disable type_body_length

// Initial implementation for initial Network Protection tests. Will be fleshed out with https://app.asana.com/0/1203137811378537/1204630829332227/f
final class NetworkProtectionPacketTunnelProvider: PacketTunnelProvider {

    private var cancellables = Set<AnyCancellable>()

    // MARK: - PacketTunnelProvider.Event reporting

    private static var packetTunnelProviderEvents: EventMapping<PacketTunnelProvider.Event> = .init { event, _, _, _ in
        let defaults = UserDefaults.networkProtectionGroupDefaults

        switch event {
        case .userBecameActive:
            DailyPixel.fire(pixel: .networkProtectionActiveUser,
                            withAdditionalParameters: [PixelParameters.vpnCohort: UniquePixel.cohort(from: defaults.vpnFirstEnabled)])
        case .reportConnectionAttempt(attempt: let attempt):
            switch attempt {
            case .connecting:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptConnecting)
            case .success:
                let versionStore = NetworkProtectionLastVersionRunStore(userDefaults: .networkProtectionGroupDefaults)
                versionStore.lastExtensionVersionRun = AppVersion.shared.versionAndBuildNumber

                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptSuccess)
            case .failure:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptFailure)
            }
        case .reportTunnelFailure(result: let result):
            switch result {
            case .failureDetected:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelFailureDetected)
            case .failureRecovered:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelFailureRecovered)
            case .networkPathChanged(let newPath):
                defaults.updateNetworkPath(with: newPath)
            }
        case .reportLatency(result: let result):
            switch result {
            case .error:
                DailyPixel.fire(pixel: .networkProtectionLatencyError)
            case .quality(let quality):
                guard quality != .unknown else { return }
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionLatency(quality: quality))
            }
        case .rekeyAttempt(let step):
            switch step {
            case .begin:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionRekeyAttempt)
            case .failure(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionRekeyFailure, error: error)
            case .success:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionRekeyCompleted)
            }
        case .tunnelStartAttempt(let step):
            switch step {
            case .begin:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStartAttempt)
            case .failure(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStartFailure, error: error)
            case .success:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStartSuccess)
            }
        case .tunnelUpdateAttempt(let step):
            switch step {
            case .begin:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelUpdateAttempt)
            case .failure(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelUpdateFailure, error: error)
            case .success:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelUpdateSuccess)
            }
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
            case .keychainUpdateError(let field, let status):
                pixelEvent = .networkProtectionKeychainUpdateError
                params[PixelParameters.keychainFieldName] = field
                params[PixelParameters.keychainErrorCode] = String(status)
            case .keychainDeleteError(let status): // TODO: Check whether field needed here
                pixelEvent = .networkProtectionKeychainDeleteError
                params[PixelParameters.keychainErrorCode] = String(status)
            case .wireGuardCannotLocateTunnelFileDescriptor:
                pixelEvent = .networkProtectionWireguardErrorCannotLocateTunnelFileDescriptor
            case .wireGuardInvalidState(reason: let reason):
                pixelEvent = .networkProtectionWireguardErrorInvalidState
                params[PixelParameters.reason] = reason
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
            case .vpnAccessRevoked:
                return
            case .unhandledError(function: let function, line: let line, error: let error):
                pixelEvent = .networkProtectionUnhandledError
                params[PixelParameters.function] = function
                params[PixelParameters.line] = String(line)
                pixelError = error
            case .failedToRetrieveAuthToken:
                return
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
        let featureVisibility = NetworkProtectionVisibilityForTunnelProvider()
        let isSubscriptionEnabled = featureVisibility.isPrivacyProLaunched()
        let accessTokenProvider: () -> String? = {
#if SUBSCRIPTION
            if featureVisibility.shouldMonitorEntitlement() {
                return { AccountManager().accessToken }
            }
#endif
            return { nil }
        }()
        let tokenStore = NetworkProtectionKeychainTokenStore(
            keychainType: .dataProtection(.unspecified),
            errorEvents: nil,
            isSubscriptionEnabled: isSubscriptionEnabled,
            accessTokenProvider: accessTokenProvider
        )

        let errorStore = NetworkProtectionTunnelErrorStore()
        let notificationsPresenter = NetworkProtectionUNNotificationPresenter()
        let settings = VPNSettings(defaults: .networkProtectionGroupDefaults)
        let notificationsPresenterDecorator = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: settings,
            defaults: .networkProtectionGroupDefaults,
            wrappee: notificationsPresenter
        )
        notificationsPresenter.requestAuthorization()
        super.init(notificationsPresenter: notificationsPresenterDecorator,
                   tunnelHealthStore: NetworkProtectionTunnelHealthStore(),
                   controllerErrorStore: errorStore,
                   keychainType: .dataProtection(.unspecified),
                   tokenStore: tokenStore,
                   debugEvents: Self.networkProtectionDebugEvents(controllerErrorStore: errorStore),
                   providerEvents: Self.packetTunnelProviderEvents,
                   settings: settings,
                   defaults: .networkProtectionGroupDefaults,
                   isSubscriptionEnabled: isSubscriptionEnabled,
                   entitlementCheck: Self.entitlementCheck)
        startMonitoringMemoryPressureEvents()
        observeServerChanges()
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

    public override func handleConnectionStatusChange(old: ConnectionStatus, new: ConnectionStatus) {
        super.handleConnectionStatusChange(old: old, new: new)

        activationDateStore.setActivationDateIfNecessary()
        activationDateStore.updateLastActiveDate()
    }

    private static func entitlementCheck() async -> Result<Bool, Error> {
#if SUBSCRIPTION
        guard NetworkProtectionVisibilityForTunnelProvider().shouldMonitorEntitlement() else {
            return .success(true)
        }

        if VPNSettings(defaults: .networkProtectionGroupDefaults).selectedEnvironment == .staging {
            SubscriptionPurchaseEnvironment.currentServiceEnvironment = .staging
        }

        let result = await AccountManager(subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs))
            .hasEntitlement(for: .networkProtection)
        switch result {
        case .success(let hasEntitlement):
            return .success(hasEntitlement)
        case .failure(let error):
            return .failure(error)
        }
#else
        return .success(true)
#endif
    }
}

// swiftlint:enable type_body_length

#endif
