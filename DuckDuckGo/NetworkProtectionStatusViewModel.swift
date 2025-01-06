//
//  NetworkProtectionStatusViewModel.swift
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
import Combine
import NetworkProtection
import WidgetKit
import BrowserServicesKit
import Core
import Subscription
import TipKit

struct NetworkProtectionLocationStatusModel {
    enum LocationIcon {
        case defaultIcon
        case emoji(String)
    }

    let title: String
    let icon: LocationIcon
    let isNearest: Bool

    init(selectedLocation: VPNSettings.SelectedLocation) {
        switch selectedLocation {
        case .nearest:
            title = UserText.netPPreferredLocationNearest
            icon = .defaultIcon
            isNearest = true
        case .location(let location):
            let countryLabelsModel = NetworkProtectionVPNCountryLabelsModel(country: location.country, useFullCountryName: true)
            if let city = location.city {
                let formattedCityAndCountry = UserText.netPVPNSettingsLocationSubtitleFormattedCityAndCountry(
                    city: city,
                    country: countryLabelsModel.title
                )

                title = "\(countryLabelsModel.emoji) \(formattedCityAndCountry)"
            } else {
                title = "\(countryLabelsModel.emoji) \(countryLabelsModel.title)"
            }
            icon = .emoji(countryLabelsModel.emoji)
            isNearest = false
        }
    }

    static func formattedLocation(city: String, country: String) -> String {
        let countryLabelsModel = NetworkProtectionVPNCountryLabelsModel(country: country, useFullCountryName: true)
        let city = "\(countryLabelsModel.emoji) \(city)"

        return UserText.netPVPNSettingsLocationSubtitleFormattedCityAndCountry(city: city, country: countryLabelsModel.title)
    }
}

final class NetworkProtectionStatusViewModel: ObservableObject {

    enum Constants {
        static let defaultDownloadVolume = "0 KB"
        static let defaultUploadVolume = "0 KB"
    }

    private static var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static var snoozeRemainingDateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter
    }()

    private let featureFlagger = AppDependencyProvider.shared.featureFlagger
    private let tunnelController: (TunnelController & TunnelSessionProvider)
    private let statusObserver: ConnectionStatusObserver
    private let serverInfoObserver: ConnectionServerInfoObserver
    private let errorObserver: ConnectionErrorObserver
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Tips

    var canShowTips: Bool {
        featureFlagger.isFeatureOn(.networkProtectionUserTips)
    }

    /// Whether the "Add Widget" education sheet should be presented to the user.
    ///
    @Published
    var showAddWidgetEducationView: Bool = false

    let tipsModel: VPNTipsModel

    // MARK: Error

    struct ErrorItem {
        let title: String
        let message: String
    }

    @Published public var error: ErrorItem? {
        didSet {
            shouldShowError = error != nil
        }
    }
    @Published public var shouldShowError: Bool = false

    // MARK: Header

    @Published public var statusImageID: String
    @Published public var headerTitle: String

    // MARK: Toggle Item

    @Published public var isNetPEnabled = false {
        didSet {
            if #available(iOS 17.0, *) {
                if isNetPEnabled {
                    VPNGeoswitchingTip.vpnEnabledOnce = true
                }

                VPNSnoozeTip.vpnEnabled = isNetPEnabled
                VPNAddWidgetTip.vpnEnabled = isNetPEnabled
            }
        }
    }

    @Published public var isSnoozing = false {
        didSet {
            snoozeRequestPending = false
        }
    }

    @Published public var snoozeRequestPending = false
    @Published public var statusMessage: String
    @Published public var shouldDisableToggle: Bool = false

    // MARK: Location

    private let settings: VPNSettings
    @Published public var preferredLocation: NetworkProtectionLocationStatusModel

    // MARK: Connection Details

    @Published public var hasServerInfo: Bool = false
    @Published public var location: String?
    @Published public var ipAddress: String?
    @Published public var dnsSettings: NetworkProtectionDNSSettings

    @Published public var uploadTotal: String?
    @Published public var downloadTotal: String?
    private var throughputUpdateTimer: Timer?

    @Published public var animationsOn: Bool = false

    public let usesUnifiedFeedbackForm: Bool
    public let subscriptionManager: SubscriptionManager

    public init(tunnelController: (TunnelController & TunnelSessionProvider),
                settings: VPNSettings,
                statusObserver: ConnectionStatusObserver,
                serverInfoObserver: ConnectionServerInfoObserver,
                errorObserver: ConnectionErrorObserver = ConnectionErrorObserverThroughSession(),
                locationListRepository: NetworkProtectionLocationListRepository,
                usesUnifiedFeedbackForm: Bool,
                subscriptionManager: SubscriptionManager) {
        self.tunnelController = tunnelController
        self.settings = settings
        self.statusObserver = statusObserver
        self.serverInfoObserver = serverInfoObserver
        self.errorObserver = errorObserver
        self.usesUnifiedFeedbackForm = usesUnifiedFeedbackForm
        self.subscriptionManager = subscriptionManager

        statusMessage = Self.message(for: statusObserver.recentValue)
        self.headerTitle = Self.titleText(status: statusObserver.recentValue)
        self.statusImageID = Self.statusImageID(connected: statusObserver.recentValue.isConnected)

        self.preferredLocation = NetworkProtectionLocationStatusModel(selectedLocation: settings.selectedLocation)

        self.dnsSettings = settings.dnsSettings

        self.tipsModel = VPNTipsModel(
            isTipFeatureEnabled: featureFlagger.isFeatureOn(.networkProtectionUserTips),
            statusObserver: statusObserver,
            vpnSettings: settings)

        updateViewModel(withStatus: statusObserver.recentValue)

        setUpIsConnectedStatePublishers()
        setUpToggledStatePublisher()
        setUpStatusMessagePublishers()
        setUpDisableTogglePublisher()
        setUpServerInfoPublishers()
        setUpLocationPublishers()
        setUpDNSSettingsPublisher()
        setUpThroughputRefreshTimer()
        setUpErrorPublishers()

        // Prefetching this now for snappy load times on the locations screens
        Task {
            _ = try? await locationListRepository.fetchLocationList()
        }
    }

    private func setUpIsConnectedStatePublishers() {
        statusObserver.publisher.receive(on: DispatchQueue.main).sink { [weak self] status in
            self?.updateViewModel(withStatus: status)
        }
        .store(in: &cancellables)
    }

    private func setUpToggledStatePublisher() {
        statusObserver.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .connected:
                    self?.isNetPEnabled = true
                case .connecting:
                    self?.isNetPEnabled = true
                    self?.resetConnectionInformation()
                default:
                    self?.isNetPEnabled = false
                    self?.resetConnectionInformation()
                }
            }
            .store(in: &cancellables)

        statusObserver.publisher
            .map {
                switch $0 {
                case .snoozing:
                    return true
                default:
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .assign(to: \.isSnoozing, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpStatusMessagePublishers() {
        statusObserver.publisher
            .removeDuplicates()
            .flatMap(maxPublishers: .max(1)) { status in
                // As soon as the connection status changes, we should update the status message
                var statusUpdatePublishers = [Just(Self.message(for: status)).eraseToAnyPublisher()]
                switch status {
                case .connected(let connectedDate):
                    // In the case that the status is connected, we should then provide timed updates
                    // If we rely on the timed updates alone, there will be a delay to the initial update
                    statusUpdatePublishers.append(Self.timedConnectedStatusMessagePublisher(forConnectedDate: connectedDate))
                case .snoozing:
                    let timingStore = NetworkProtectionSnoozeTimingStore(userDefaults: .networkProtectionGroupDefaults)
                    guard let endDate = timingStore.activeTiming?.endDate else {
                        break
                    }

                    statusUpdatePublishers = [Just(Self.snoozeDurationRemainingMessage(for: endDate, currentDate: Date())).eraseToAnyPublisher()]
                    statusUpdatePublishers.append(Self.timedSnoozeDurationRemainingMessagePublisher(forSnoozeEndDate: endDate))
                default:
                    break
                }
                return statusUpdatePublishers.publisher
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: \.statusMessage, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpDisableTogglePublisher() {
        let isLoadingPublisher = statusObserver.publisher.map { $0.isLoading }

        isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.shouldDisableToggle, onWeaklyHeld: self)
            .store(in: &cancellables)

        // Set up a delayed publisher to fire just once that reenables the toggle
        // Each event cancels the previous delayed publisher
        $shouldDisableToggle
            .filter { $0 }
            .map { _ -> AnyPublisher<Bool, Never> in
                Just(false).delay(for: 2.0, scheduler: DispatchQueue.main).eraseToAnyPublisher()
            }
            .switchToLatest()
            .assign(to: \.shouldDisableToggle, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpServerInfoPublishers() {
        serverInfoObserver.publisher
            .map { serverInfo in
                guard let attributes = serverInfo.serverLocation else {
                    return nil
                }

                return NetworkProtectionLocationStatusModel.formattedLocation(
                    city: attributes.city,
                    country: attributes.country
                )
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.location, onWeaklyHeld: self)
            .store(in: &cancellables)

        serverInfoObserver.publisher
            .map(\.serverAddress)
            .receive(on: DispatchQueue.main)
            .assign(to: \.ipAddress, onWeaklyHeld: self)
            .store(in: &cancellables)

        serverInfoObserver.publisher
            .map {
                $0.serverAddress != nil || $0.serverLocation != nil
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasServerInfo, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func updateViewModel(withStatus connectionStatus: ConnectionStatus) {
        self.headerTitle = Self.titleText(status: connectionStatus)
        self.statusImageID = Self.statusImageID(connected: connectionStatus.isConnected)

        if !connectionStatus.isConnected {
            self.uploadTotal = nil
            self.downloadTotal = nil
            self.throughputUpdateTimer?.invalidate()
            self.throughputUpdateTimer = nil
        } else {
            self.setUpThroughputRefreshTimer()
        }

        switch connectionStatus {
        case .connected:
            self.isNetPEnabled = true
        case .connecting:
            self.isNetPEnabled = true
            self.resetConnectionInformation()
        default:
            self.isNetPEnabled = false
            self.resetConnectionInformation()
        }
    }

    private func setUpErrorPublishers() {
        guard AppDependencyProvider.shared.internalUserDecider.isInternalUser else {
            return
        }

        errorObserver.publisher
            .map { errorMessage in
                guard let errorMessage else {
                    return nil
                }

                return ErrorItem(title: "Failed to Connect", message: errorMessage)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.error, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpLocationPublishers() {
        settings.selectedLocationPublisher
            .receive(on: DispatchQueue.main)
            .map(NetworkProtectionLocationStatusModel.init(selectedLocation:))
            .assign(to: \.preferredLocation, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpDNSSettingsPublisher() {
        settings.dnsSettingsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.dnsSettings, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpThroughputRefreshTimer() {
        if let throughputUpdateTimer, throughputUpdateTimer.isValid {
            // Prevent the timer from being set up multiple times
            return
        }

        Task {
            // Refresh as soon as the timer is set up, rather than waiting for 1 second:
            await self.refreshDataVolumeTotals()
        }

        throughputUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            Task {
                await strongSelf.refreshDataVolumeTotals()
            }
        }
    }

    private func refreshDataVolumeTotals() async {
        guard let activeSession = await tunnelController.activeSession() else {
            return
        }

        let data: ExtensionMessageString? = try? await activeSession.sendProviderMessage(.getDataVolume)

        guard let data else {
            return
        }

        let bytes = data.value.components(separatedBy: ",")
        guard let receivedString = bytes.first, let sentString = bytes.last,
              let received = Int64(receivedString), let sent = Int64(sentString) else {
            return
        }

        await updateBandwidthCounts(sent: sent, received: received)
    }

    @MainActor
    private func updateBandwidthCounts(sent: Int64, received: Int64) {
        self.uploadTotal = byteCountFormatter.string(fromByteCount: sent)
        self.downloadTotal = byteCountFormatter.string(fromByteCount: received)
    }

    @MainActor
    func didToggleNetP(to enabled: Bool) async {
        shouldDisableToggle = true
        
        // This is to prevent weird looking animations on navigating to the screen.
        // It makes sense as animations should mostly only happen when a user has interacted.
        animationsOn = true
        if enabled {
            if isSnoozing {
                await cancelSnooze()
            } else {
                await enableNetP()
            }
        } else {
            await disableNetP()
        }

        VPNReloadStatusWidgets()
    }

    @MainActor
    private func enableNetP() async {
        await tunnelController.start()
    }

    @MainActor
    private func disableNetP() async {
        await tunnelController.stop()
    }

    @MainActor
    func startSnooze() async {
        guard !snoozeRequestPending, let activeSession = await tunnelController.activeSession() else {
            return
        }

        if #available(iOS 18.0, *) {
            tipsModel.handleUserSnoozedVPN()
        }

        let defaultDuration: TimeInterval = .minutes(20)
        snoozeRequestPending = true
        try? await activeSession.sendProviderMessage(.startSnooze(defaultDuration))
        DailyPixel.fire(pixel: .networkProtectionSnoozeEnabledFromStatusMenu)

        if #available(iOS 17.0, *) {
            await VPNSnoozeLiveActivityManager().start(endDate: Date().addingTimeInterval(defaultDuration))
        }
    }

    @MainActor
    func cancelSnooze() async {
        guard !snoozeRequestPending, let activeSession = await tunnelController.activeSession() else {
            return
        }

        snoozeRequestPending = true
        try? await activeSession.sendProviderMessage(.cancelSnooze)
        DailyPixel.fire(pixel: .networkProtectionSnoozeDisabledFromStatusMenu)

        if #available(iOS 17.0, *) {
            await VPNSnoozeLiveActivityManager().endSnoozeActivity()
        }
    }

    private class func titleText(status: ConnectionStatus) -> String {
        switch status {
        case .connected: return UserText.netPStatusHeaderTitleOn
        case .snoozing: return UserText.netPStatusHeaderTitleSnoozed
        case .notConfigured, .disconnected, .disconnecting, .connecting, .reasserting: return UserText.netPStatusHeaderTitleOff
        }
    }

    private class func statusImageID(connected isConnected: Bool) -> String {
        isConnected ? "VPN" : "VPNDisabled"
    }

    private static func timedConnectedStatusMessagePublisher(forConnectedDate connectedDate: Date) -> AnyPublisher<String, Never> {
        Timer.publish(every: .seconds(1), on: .main, in: .default)
            .autoconnect()
            .map {
                Self.connectedMessage(for: connectedDate, currentDate: $0)
            }
            .eraseToAnyPublisher()
    }

    private static func timedSnoozeDurationRemainingMessagePublisher(forSnoozeEndDate snoozeEndDate: Date) -> AnyPublisher<String, Never> {
        Timer.publish(every: .seconds(1), on: .main, in: .default)
            .autoconnect()
            .map {
                Self.snoozeDurationRemainingMessage(for: snoozeEndDate, currentDate: $0)
            }
            .eraseToAnyPublisher()
    }

    private static func message(for status: ConnectionStatus) -> String {
        switch status {
        case .disconnected, .notConfigured:
            return UserText.netPStatusDisconnected
        case .disconnecting:
            return UserText.netPStatusDisconnecting
        case .connected(connectedDate: let connectedDate):
            return connectedMessage(for: connectedDate)
        case .connecting, .reasserting:
            return UserText.netPStatusConnecting
        case .snoozing:
            return UserText.netPStatusPaused
        }
    }

    private static func connectedMessage(for connectedDate: Date, currentDate: Date = Date()) -> String {
        let timeLapsedInterval = currentDate.timeIntervalSince(connectedDate)
        let timeLapsed = Self.dateFormatter.string(from: timeLapsedInterval) ?? "00:00:00"
        return UserText.netPStatusConnected(since: timeLapsed)
    }

    private static func snoozeDurationRemainingMessage(for snoozeEndDate: Date, currentDate: Date = Date()) -> String {
        if snoozeEndDate <= currentDate {
            return UserText.netPCellSnoozing
        }

        let timeRemainingInterval = snoozeEndDate.timeIntervalSince(currentDate)
        let timeRemaining = Self.snoozeRemainingDateFormatter.string(from: timeRemainingInterval) ?? "00:00"

        return UserText.netPStatusSnoozing(until: timeRemaining)
    }

    private func resetConnectionInformation() {
        self.location = nil
        self.ipAddress = nil
        self.uploadTotal = nil
        self.downloadTotal = nil
    }

    // MARK: - UI Events handling

    @available(iOS 18.0, *)
    func snoozeActionHandler(action: Tips.Action) {
        if action.id == VPNSnoozeTip.ActionIdentifiers.learnMore.rawValue {
            let url = URL(string: "https://duckduckgo.com/duckduckgo-help-pages/privacy-pro/vpn/troubleshooting/")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @available(iOS 18.0, *)
    @MainActor
    func widgetActionHandler(action: Tips.Action) {
        if action.id == VPNAddWidgetTip.ActionIdentifiers.addWidget.rawValue {
            showAddWidgetEducationView = true

            tipsModel.handleUserOpenedWidgetLearnMore()
        }
    }

    /// The user opened the VPN locations view
    ///
    func handleUserOpenedVPNLocations() {
        if #available(iOS 18.0, *) {
            Task { @MainActor in
                tipsModel.handleUserOpenedLocations()
            }
        }
    }
}

private extension ConnectionStatus {
    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        default:
            return false
        }
    }

    var isSnoozing: Bool {
        switch self {
        case .snoozing:
            return true
        default:
            return false
        }
    }

    var isLoading: Bool {
        switch self {
        case .connecting, .reasserting, .disconnecting:
            return true
        default:
            return false
        }
    }
}
