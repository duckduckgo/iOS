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

import Foundation
import Common
import Configuration
import Combine
import Core
import Networking
import NetworkExtension
import NetworkProtection
import os.log
import Subscription
import WidgetKit
import WireGuard
import BrowserServicesKit

// Initial implementation for initial Network Protection tests. Will be fleshed out with https://app.asana.com/0/1203137811378537/1204630829332227/f
final class NetworkProtectionPacketTunnelProvider: PacketTunnelProvider {

    private static var vpnLogger = VPNLogger()
    private static let persistentPixel: PersistentPixelFiring = PersistentPixel()
    private var cancellables = Set<AnyCancellable>()
    private let accountManager: AccountManager

    private let configurationStore = ConfigurationStore()
    private let configurationManager: ConfigurationManager

    // MARK: - PacketTunnelProvider.Event reporting

    private static var packetTunnelProviderEvents: EventMapping<PacketTunnelProvider.Event> = .init { event, _, _, _ in
        let defaults = UserDefaults.networkProtectionGroupDefaults

        switch event {
        case .userBecameActive:
            DailyPixel.fire(pixel: .networkProtectionActiveUser,
                            withAdditionalParameters: [PixelParameters.vpnCohort: UniquePixel.cohort(from: defaults.vpnFirstEnabled)],
                            includedParameters: [.appVersion, .atb])

            persistentPixel.sendQueuedPixels { error in
                Logger.networkProtection.error("Failed to send queued pixels, with error: \(error)")
            }
        case .connectionTesterStatusChange(let status, let server):
            vpnLogger.log(status, server: server)

            switch status {
            case .failed(let duration):
                let pixel: Pixel.Event = {
                    switch duration {
                    case .immediate:
                        return .networkProtectionConnectionTesterFailureDetected
                    case .extended:
                        return .networkProtectionConnectionTesterExtendedFailureDetected
                    }
                }()

                DailyPixel.fireDailyAndCount(pixel: pixel,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             withAdditionalParameters: [PixelParameters.server: server],
                                             includedParameters: [.appVersion, .atb])
            case .recovered(let duration, let failureCount):
                let pixel: Pixel.Event = {
                    switch duration {
                    case .immediate:
                        return .networkProtectionConnectionTesterFailureRecovered(failureCount: failureCount)
                    case .extended:
                        return .networkProtectionConnectionTesterExtendedFailureRecovered(failureCount: failureCount)
                    }
                }()

                DailyPixel.fireDailyAndCount(pixel: pixel,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             withAdditionalParameters: [
                                                PixelParameters.count: String(failureCount),
                                                PixelParameters.server: server
                                             ],
                                             includedParameters: [.appVersion, .atb])
            }
        case .reportConnectionAttempt(attempt: let attempt):
            vpnLogger.log(attempt)

            switch attempt {
            case .connecting:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptConnecting,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             includedParameters: [.appVersion, .atb])
            case .success:
                let versionStore = NetworkProtectionLastVersionRunStore(userDefaults: .networkProtectionGroupDefaults)
                versionStore.lastExtensionVersionRun = AppVersion.shared.versionAndBuildNumber

                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptSuccess,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             includedParameters: [.appVersion, .atb])
            case .failure:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnableAttemptFailure,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             includedParameters: [.appVersion, .atb])
            }
        case .reportTunnelFailure(result: let result):
            vpnLogger.log(result)

            switch result {
            case .failureDetected:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelFailureDetected,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             includedParameters: [.appVersion, .atb])
            case .failureRecovered:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelFailureRecovered,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             includedParameters: [.appVersion, .atb])
            case .networkPathChanged(let newPath):
                defaults.updateNetworkPath(with: newPath)
            }
        case .reportLatency(result: let result):
            vpnLogger.log(result)

            switch result {
            case .error:
                DailyPixel.fire(pixel: .networkProtectionLatencyError, includedParameters: [.appVersion, .atb])
            case .quality(let quality):
                guard quality != .unknown else { return }
                DailyPixel.fireDailyAndCount(
                    pixel: .networkProtectionLatency(quality: quality.rawValue),
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    includedParameters: [.appVersion, .atb]
                )
            }
        case .rekeyAttempt(let step):
            vpnLogger.log(step, named: "Rekey")

            switch step {
            case .begin:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionRekeyAttempt,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .failure(let error):
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionRekeyFailure,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: error,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .success:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionRekeyCompleted,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            }
        case .tunnelStartAttempt(let step):
            vpnLogger.log(step, named: "Tunnel Start")

            switch step {
            case .begin:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelStartAttempt,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .failure(let error):
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelStartFailure,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: error,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .success:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelStartSuccess,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            }
        case .tunnelStopAttempt(let step):
            vpnLogger.log(step, named: "Tunnel Stop")

            switch step {
            case .begin:
                Pixel.fire(pixel: .networkProtectionTunnelStopAttempt)
            case .failure(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStopFailure,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             error: error)
            case .success:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStopSuccess,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            }
        case .tunnelUpdateAttempt(let step):
            vpnLogger.log(step, named: "Tunnel Update")

            switch step {
            case .begin:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelUpdateAttempt,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .failure(let error):
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelUpdateFailure,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: error,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .success:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionTunnelUpdateSuccess,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            }
        case .tunnelWakeAttempt(let step):
            vpnLogger.log(step, named: "Tunnel Wake")

            switch step {
            case .begin:
                Pixel.fire(pixel: .networkProtectionTunnelWakeAttempt)
            case .failure(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelWakeFailure,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             error: error)
            case .success:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelWakeSuccess,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            }
        case .failureRecoveryAttempt(let step):
            vpnLogger.log(step)

            switch step {
            case .started:
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionFailureRecoveryStarted,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            case .completed(.healthy):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionFailureRecoveryCompletedHealthy,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            case .completed(.unhealthy):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionFailureRecoveryCompletedUnhealthy,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            case .failed(let error):
                DailyPixel.fireDailyAndCount(pixel: .networkProtectionFailureRecoveryFailed,
                                             pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                             error: error)
            }
        case .serverMigrationAttempt(let step):
            vpnLogger.log(step, named: "Server Migration")

            switch step {
            case .begin:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionServerMigrationAttempt,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .failure(let error):
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionServerMigrationAttemptFailure,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: error,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            case .success:
                persistentPixel.fireDailyAndCount(
                    pixel: .networkProtectionServerMigrationAttemptSuccess,
                    pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                    error: nil,
                    withAdditionalParameters: [:],
                    includedParameters: [.appVersion]) { _ in }
            }
        case .tunnelStartOnDemandWithoutAccessToken:
            vpnLogger.logStartingWithoutAuthToken()
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionTunnelStartAttemptOnDemandWithoutAccessToken,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
        }
    }

    // MARK: - Error Reporting

    private static func networkProtectionDebugEvents(controllerErrorStore: NetworkProtectionTunnelErrorStore) -> EventMapping<NetworkProtectionError> {
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
            case .startWireGuardBackend(let error):
                pixelEvent = .networkProtectionWireguardErrorCannotStartWireguardBackend
                pixelError = error
            case .setWireguardConfig(let error):
                pixelEvent = .networkProtectionWireguardErrorCannotSetWireguardConfig
                pixelError = error
            case .noAuthTokenFound:
                pixelEvent = .networkProtectionNoAccessTokenFoundError
            case .vpnAccessRevoked:
                return
            case .unhandledError(function: let function, line: let line, error: let error):
                pixelEvent = .networkProtectionUnhandledError
                params[PixelParameters.function] = function
                params[PixelParameters.line] = String(line)
                pixelError = error
            case .failedToFetchLocationList:
                return
            case .failedToParseLocationListResponse:
                return
            case .failedToFetchServerStatus(let error):
                pixelEvent = .networkProtectionClientFailedToFetchServerStatus
                pixelError = error
            case .failedToParseServerStatusResponse(let error):
                pixelEvent = .networkProtectionClientFailedToParseServerStatusResponse
                pixelError = error
            }
            DailyPixel.fireDailyAndCount(pixel: pixelEvent,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                         error: pixelError,
                                         withAdditionalParameters: params)
        }
    }

    public override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        switch reason {
        case .appUpdate, .userInitiated:
            break
        default:
            DailyPixel.fireDailyAndCount(
                pixel: .networkProtectionDisconnected,
                pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                withAdditionalParameters: [PixelParameters.reason: String(reason.rawValue)]
            )
        }
        super.stopTunnel(with: reason, completionHandler: completionHandler)
    }

    @objc init() {
#if DEBUG
        Pixel.isDryRun = true
#endif

        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)

        let settings = VPNSettings(defaults: .networkProtectionGroupDefaults)

        Configuration.setURLProvider(VPNAgentConfigurationURLProvider())
        configurationManager = ConfigurationManager(store: configurationStore)
        configurationManager.start()
        let privacyConfigurationManager = VPNPrivacyConfigurationManager.shared
        // Load cached config (if any)
        privacyConfigurationManager.reload(etag: configurationStore.loadEtag(for: .privacyConfiguration), data: configurationStore.loadData(for: .privacyConfiguration))

        // Align Subscription environment to the VPN environment
        var subscriptionEnvironment = SubscriptionEnvironment.default
        switch settings.selectedEnvironment {
        case .production:
            subscriptionEnvironment.serviceEnvironment = .production
        case .staging:
            subscriptionEnvironment.serviceEnvironment = .staging
        }

        // MARK: - Configure Subscription
        let entitlementsCache = UserDefaultsCache<[Entitlement]>(userDefaults: UserDefaults.standard,
                                                                 key: UserDefaultsCacheKey.subscriptionEntitlements,
                                                                 settings: UserDefaultsCacheSettings(defaultExpirationInterval: .minutes(20)))

        let subscriptionAppGroup = Bundle.main.appGroup(bundle: .subs)
        let accessTokenStorage = SubscriptionTokenKeychainStorage(keychainType: .dataProtection(.named(subscriptionAppGroup)))
        let subscriptionService = DefaultSubscriptionEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let authService = DefaultAuthEndpointService(currentServiceEnvironment: subscriptionEnvironment.serviceEnvironment)
        let accountManager = DefaultAccountManager(accessTokenStorage: accessTokenStorage,
                                                   entitlementsCache: entitlementsCache,
                                                   subscriptionEndpointService: subscriptionService,
                                                   authEndpointService: authService)
        self.accountManager = accountManager
        let featureVisibility = NetworkProtectionVisibilityForTunnelProvider(accountManager: accountManager)
        let accessTokenProvider: () -> String? = {
            if featureVisibility.shouldMonitorEntitlement() {
                return { accountManager.accessToken }
            }
            return { nil }
        }()
        let tokenStore = NetworkProtectionKeychainTokenStore(accessTokenProvider: accessTokenProvider)

        let errorStore = NetworkProtectionTunnelErrorStore()
        let notificationsPresenter = NetworkProtectionUNNotificationPresenter()

        let notificationsPresenterDecorator = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: settings,
            defaults: .networkProtectionGroupDefaults,
            wrappee: notificationsPresenter
        )
        notificationsPresenter.requestAuthorization()
        super.init(notificationsPresenter: notificationsPresenterDecorator,
                   tunnelHealthStore: NetworkProtectionTunnelHealthStore(),
                   controllerErrorStore: errorStore,
                   snoozeTimingStore: NetworkProtectionSnoozeTimingStore(userDefaults: .networkProtectionGroupDefaults),
                   wireGuardInterface: DefaultWireGuardInterface(),
                   keychainType: .dataProtection(.unspecified),
                   tokenHandler: tokenStore,
                   debugEvents: Self.networkProtectionDebugEvents(controllerErrorStore: errorStore),
                   providerEvents: Self.packetTunnelProviderEvents,
                   settings: settings,
                   defaults: .networkProtectionGroupDefaults,
                   entitlementCheck: { return await Self.entitlementCheck(accountManager: accountManager) })

        accountManager.delegate = self
        startMonitoringMemoryPressureEvents()
        observeServerChanges()
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckDuckGoUserAgent)
    }

    deinit {
        memoryPressureSource?.cancel()
        memoryPressureSource = nil
    }

    private var memoryPressureSource: DispatchSourceMemoryPressure?
    private let memoryPressureQueue = DispatchQueue(label: "com.duckduckgo.mobile.ios.NetworkExtension.memoryPressure")

    private func startMonitoringMemoryPressureEvents() {
        let source = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: memoryPressureQueue)

        source.setEventHandler { [weak source] in
            guard let source else { return }

            let event = source.data

            if event.contains(.warning) {
                Logger.networkProtectionMemory.warning("Received memory pressure warning")
                DailyPixel.fire(pixel: .networkProtectionMemoryWarning)
            } else if event.contains(.critical) {
                Logger.networkProtectionMemory.warning("Received memory pressure critical warning")
                DailyPixel.fire(pixel: .networkProtectionMemoryCritical)
            }
        }

        self.memoryPressureSource = source
        source.activate()
    }

    private func observeServerChanges() {
        lastSelectedServerInfoPublisher.sink { server in
            let location = server?.attributes.city ?? "Unknown Location"
            UserDefaults.networkProtectionGroupDefaults.set(location, forKey: NetworkProtectionUserDefaultKeys.lastSelectedServerCity)
        }
        .store(in: &cancellables)
    }

    private let activationDateStore = DefaultVPNActivationDateStore()

    public override func handleConnectionStatusChange(old: ConnectionStatus, new: ConnectionStatus) {
        super.handleConnectionStatusChange(old: old, new: new)

        activationDateStore.setActivationDateIfNecessary()
        activationDateStore.updateLastActiveDate()

        VPNReloadStatusWidgets()
    }

    private static func entitlementCheck(accountManager: AccountManager) async -> Result<Bool, Error> {
        
        guard NetworkProtectionVisibilityForTunnelProvider(accountManager: accountManager).shouldMonitorEntitlement() else {
            return .success(true)
        }

        let result = await accountManager.hasEntitlement(forProductName: .networkProtection)
        switch result {
        case .success(let hasEntitlement):
            return .success(hasEntitlement)
        case .failure(let error):
            return .failure(error)
        }
    }
}

final class DefaultWireGuardInterface: WireGuardInterface {
    func turnOn(settings: UnsafePointer<CChar>, handle: Int32) -> Int32 {
        wgTurnOn(settings, handle)
    }
    
    func turnOff(handle: Int32) {
        wgTurnOff(handle)
    }
    
    func getConfig(handle: Int32) -> UnsafeMutablePointer<CChar>? {
        return wgGetConfig(handle)
    }
    
    func setConfig(handle: Int32, config: String) -> Int64 {
        return wgSetConfig(handle, config)
    }
    
    func bumpSockets(handle: Int32) {
        wgBumpSockets(handle)
    }
    
    func disableSomeRoamingForBrokenMobileSemantics(handle: Int32) {
        wgDisableSomeRoamingForBrokenMobileSemantics(handle)
    }
    
    func setLogger(context: UnsafeMutableRawPointer?, logFunction: (@convention(c) (UnsafeMutableRawPointer?, Int32, UnsafePointer<CChar>?) -> Void)?) {
        wgSetLogger(context, logFunction)
    }
}

extension NetworkProtectionPacketTunnelProvider: AccountManagerKeychainAccessDelegate {

    public func accountManagerKeychainAccessFailed(accessType: AccountKeychainAccessType, error: AccountKeychainAccessError) {
        let parameters = [
            PixelParameters.privacyProKeychainAccessType: accessType.rawValue,
            PixelParameters.privacyProKeychainError: error.errorDescription,
            PixelParameters.source: "vpn"
        ]

        DailyPixel.fireDailyAndCount(pixel: .privacyProKeychainAccessError,
                                     pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                     withAdditionalParameters: parameters)
    }
}
