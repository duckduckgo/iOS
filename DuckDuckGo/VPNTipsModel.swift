//
//  VPNTipsModel.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Combine
import Common
import Core
import NetworkProtection
import os.log
import TipKit

public final class VPNTipsModel: ObservableObject {

    static let imageSize = CGSize(width: 32, height: 32)

    @Published
    private(set) var connectionStatus: ConnectionStatus {
        didSet {
            guard #available(iOS 18.0, *) else {
                return
            }

            handleConnectionStatusChanged(oldValue: oldValue, newValue: connectionStatus)
        }
    }

    private var isTipFeatureEnabled: Bool
    private let vpnSettings: VPNSettings
    private var cancellables = Set<AnyCancellable>()

    public init(isTipFeatureEnabled: Bool,
                statusObserver: ConnectionStatusObserver,
                vpnSettings: VPNSettings) {

        self.connectionStatus = statusObserver.recentValue
        self.isTipFeatureEnabled = isTipFeatureEnabled
        self.vpnSettings = vpnSettings

        if #available(iOS 18.0, *) {
            handleConnectionStatusChanged(oldValue: connectionStatus, newValue: connectionStatus)

            subscribeToConnectionStatusChanges(statusObserver)
        }
    }

    deinit {
        geoswitchingStatusUpdateTask?.cancel()
        geoswitchingStatusUpdateTask = nil
    }

    var canShowTips: Bool {
        isTipFeatureEnabled
    }

    // MARK: - Subscriptions

    @available(iOS 18.0, *)
    private func subscribeToConnectionStatusChanges(_ statusObserver: ConnectionStatusObserver) {
        statusObserver.publisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectionStatus, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    // MARK: - Tips

    let geoswitchingTip = VPNGeoswitchingTip()
    let snoozeTip = VPNSnoozeTip()
    let widgetTip = VPNAddWidgetTip()

    var geoswitchingStatusUpdateTask: Task<Void, Never>?

    // MARK: - Tip Action handling

    @available(iOS 18.0, *)
    func snoozeTipActionHandler(_ action: Tip.Action) {
        if action.id == VPNSnoozeTip.ActionIdentifiers.learnMore.rawValue {
            vpnSettings.connectOnLogin = true

            snoozeTip.invalidate(reason: .actionPerformed)
        }
    }

    // MARK: - Handle Refreshing

    @available(iOS 18.0, *)
    private func handleConnectionStatusChanged(oldValue: ConnectionStatus, newValue: ConnectionStatus) {
        switch newValue {
        case .connected:
            if case oldValue = .connecting {
                handleTipDistanceConditionsCheckpoint()
            }

            VPNAddWidgetTip.vpnEnabled = true
            VPNGeoswitchingTip.vpnEnabledOnce = true
            VPNSnoozeTip.vpnEnabled = true
        default:
            if case oldValue = .disconnecting {
                handleTipDistanceConditionsCheckpoint()
            }

            VPNAddWidgetTip.vpnEnabled = false
            VPNSnoozeTip.vpnEnabled = false
        }
    }

    @available(iOS 18.0, *)
    private func handleTipDistanceConditionsCheckpoint() {
        if case .invalidated = geoswitchingTip.status {
            VPNAddWidgetTip.isDistancedFromPreviousTip = true
        }

        if case .invalidated = widgetTip.status {
            VPNSnoozeTip.isDistancedFromPreviousTip = true
        }
    }

    // MARK: - UI Events

    @available(iOS 18.0, *)
    func handleGeoswitchingTipInvalidated(_ reason: Tip.InvalidationReason) {
        switch reason {
        case .actionPerformed:
            Pixel.fire(pixel: .networkProtectionGeoswitchingTipActioned,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        default:
            Pixel.fire(pixel: .networkProtectionGeoswitchingTipDismissed,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }
    }

    @available(iOS 18.0, *)
    func handleSnoozeTipInvalidated(_ reason: Tip.InvalidationReason) {
        switch reason {
        case .actionPerformed:
            Pixel.fire(pixel: .networkProtectionSnoozeTipActioned,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        default:
            Pixel.fire(pixel: .networkProtectionSnoozeTipDismissed,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }
    }

    @available(iOS 18.0, *)
    func handleWidgetTipInvalidated(_ reason: Tip.InvalidationReason) {
        switch reason {
        case .actionPerformed:
            Pixel.fire(pixel: .networkProtectionWidgetTipActioned,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        default:
            Pixel.fire(pixel: .networkProtectionWidgetTipDismissed,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }
    }

    // MARK: - User Actions

    @available(iOS 18.0, *)
    func handleUserOpenedWidgetLearnMore() {
        widgetTip.invalidate(reason: .actionPerformed)
    }

    @available(iOS 18.0, *)
    func handleUserOpenedLocations() {
        geoswitchingTip.invalidate(reason: .actionPerformed)
    }

    @available(iOS 18.0, *)
    func handleUserSnoozedVPN() {
        snoozeTip.invalidate(reason: .actionPerformed)
    }

    // MARK: - Status View UI Events

    @available(iOS 18.0, *)
    func handleStatusViewAppear() {
        handleTipDistanceConditionsCheckpoint()
    }

    @available(iOS 18.0, *)
    func handleStatusViewDisappear() {

        if case .available = geoswitchingTip.status {
            Pixel.fire(pixel: .networkProtectionGeoswitchingTipIgnored,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }

        if case .available = snoozeTip.status {
            Pixel.fire(pixel: .networkProtectionSnoozeTipIgnored,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }

        if case .available = widgetTip.status {
            Pixel.fire(pixel: .networkProtectionWidgetTipIgnored,
                       withAdditionalParameters: [:],
                       includedParameters: [.appVersion])
        }
    }

    @available(iOS 18.0, *)
    func handleGeoswitchingTipShown() {
        Pixel.fire(pixel: .networkProtectionGeoswitchingTipShown,
                   withAdditionalParameters: [:],
                   includedParameters: [.appVersion])
    }

    @available(iOS 18.0, *)
    func handleSnoozeTipShown() {
        Pixel.fire(pixel: .networkProtectionSnoozeTipShown,
                   withAdditionalParameters: [:],
                   includedParameters: [.appVersion])
    }

    @available(iOS 18.0, *)
    func handleWidgetTipShown() {
        Pixel.fire(pixel: .networkProtectionWidgetTipShown,
                   withAdditionalParameters: [:],
                   includedParameters: [.appVersion])
    }
}
