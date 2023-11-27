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

#if NETWORK_PROTECTION

import Foundation
import Combine
import NetworkProtection
import WidgetKit

final class NetworkProtectionStatusViewModel: ObservableObject {
    private static var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private let tunnelController: TunnelController
    private let statusObserver: ConnectionStatusObserver
    private let serverInfoObserver: ConnectionServerInfoObserver
    private let errorObserver: ConnectionErrorObserver
    private var cancellables: Set<AnyCancellable> = []

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
    @Published public var isNetPEnabled = false
    @Published public var statusMessage: String
    @Published public var shouldDisableToggle: Bool = false

    // MARK: Connection Details
    @Published public var shouldShowConnectionDetails: Bool = false
    @Published public var location: String?
    @Published public var ipAddress: String?

    @Published public var animationsOn: Bool = false

    public init(tunnelController: TunnelController = NetworkProtectionTunnelController(),
                statusObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession(),
                serverInfoObserver: ConnectionServerInfoObserver = ConnectionServerInfoObserverThroughSession(),
                errorObserver: ConnectionErrorObserver = ConnectionErrorObserverThroughSession(),
                locationListRepository: NetworkProtectionLocationListRepository = NetworkProtectionLocationListCompositeRepository()) {
        self.tunnelController = tunnelController
        self.statusObserver = statusObserver
        self.serverInfoObserver = serverInfoObserver
        self.errorObserver = errorObserver
        statusMessage = Self.message(for: statusObserver.recentValue)
        self.headerTitle = Self.titleText(connected: statusObserver.recentValue.isConnected)
        self.statusImageID = Self.statusImageID(connected: statusObserver.recentValue.isConnected)

        setUpIsConnectedStatePublishers()
        setUpToggledStatePublisher()
        setUpStatusMessagePublishers()
        setUpDisableTogglePublisher()
        setUpServerInfoPublishers()

        // Prefetching this now for snappy load times on the locations screens
        Task {
            _ = try? await locationListRepository.fetchLocationList()
        }
    }

    private func setUpIsConnectedStatePublishers() {
        let isConnectedPublisher = statusObserver.publisher
            .map { $0.isConnected }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        isConnectedPublisher
            .map(Self.titleText(connected:))
            .assign(to: \.headerTitle, onWeaklyHeld: self)
            .store(in: &cancellables)
        isConnectedPublisher
            .map(Self.statusImageID(connected:))
            .assign(to: \.statusImageID, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpToggledStatePublisher() {
        statusObserver.publisher
            .map {
                switch $0 {
                case .connected, .connecting:
                    return true
                default:
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .assign(to: \.isNetPEnabled, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpStatusMessagePublishers() {
        statusObserver.publisher
            .flatMap(maxPublishers: .max(1)) { status in
                // As soon as the connection status changes, we should update the status message
                var statusUpdatePublishers = [Just(Self.message(for: status)).eraseToAnyPublisher()]
                switch status {
                case .connected(let connectedDate):
                    // In the case that the status is connected, we should then provide timed updates
                    // If we rely on the timed updates alone, there will be a delay to the initial update
                    statusUpdatePublishers.append(Self.timedConnectedStatusMessagePublisher(forConnectedDate: connectedDate))
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
        statusObserver.publisher
            .map { $0.isLoading }
            .receive(on: DispatchQueue.main)
            .assign(to: \.shouldDisableToggle, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    private func setUpServerInfoPublishers() {
        serverInfoObserver.publisher
            .map(\.serverLocation)
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
            .assign(to: \.shouldShowConnectionDetails, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    @MainActor
    func didToggleNetP(to enabled: Bool) async {
        // This is to prevent weird looking animations on navigating to the screen.
        // It makes sense as animations should mostly only happen when a user has interacted.
        animationsOn = true
        if enabled {
            await enableNetP()
        } else {
            await disableNetP()
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "VPNStatusWidget")
    }

    @MainActor
    private func enableNetP() async {
        await tunnelController.start()
    }

    @MainActor
    private func disableNetP() async {
        await tunnelController.stop()
    }

    private class func titleText(connected isConnected: Bool) -> String {
        isConnected ? UserText.netPStatusHeaderTitleOn : UserText.netPStatusHeaderTitleOff
    }

    private class func statusImageID(connected isConnected: Bool) -> String {
        isConnected ? "VPN" : "VPNDisabled"
    }

    private static func timedConnectedStatusMessagePublisher(forConnectedDate connectedDate: Date) -> AnyPublisher<String, Never> {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .map {
                Self.connectedMessage(for: connectedDate, currentDate: $0)
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
        }
    }

    private static func connectedMessage(for connectedDate: Date, currentDate: Date = Date()) -> String {
        let timeLapsedInterval = currentDate.timeIntervalSince(connectedDate)
        let timeLapsed = Self.dateFormatter.string(from: timeLapsedInterval) ?? "00:00:00"
        return UserText.netPStatusConnected(since: timeLapsed)
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

    var isLoading: Bool {
        switch self {
        case .connecting, .reasserting, .disconnecting:
            return true
        default:
            return false
        }
    }
}

#endif
