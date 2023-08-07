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

final class NetworkProtectionStatusViewModel: ObservableObject {
    private let tunnelController: TunnelController
    private let statusObserver: ConnectionStatusObserver
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Toggle Item
    @Published public var isNetPEnabled = false
    @Published public var statusMessage: String
    @Published public var shouldShowLoading: Bool = false

    private var isConnectedPublisher: AnyPublisher<Bool, Never> {
        statusObserver.publisher
            .map { $0.isConnected }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public init(tunnelController: TunnelController = NetworkProtectionTunnelController(),
                statusObserver: ConnectionStatusObserver = ConnectionStatusObserverThroughSession()) {
        self.tunnelController = tunnelController
        self.statusObserver = statusObserver
        statusMessage = statusObserver.recentValue.message
        isConnectedPublisher
            .assign(to: \.isNetPEnabled, onWeaklyHeld: self)
            .store(in: &cancellables)

        statusObserver.publisher
            .map { $0.isLoading }
            .receive(on: DispatchQueue.main)
            .assign(to: \.shouldShowLoading, onWeaklyHeld: self)
            .store(in: &cancellables)

        statusObserver.publisher
            .map { $0.message }
            .receive(on: DispatchQueue.main)
            .assign(to: \.statusMessage, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    func didToggleNetP(to enabled: Bool) async {
        if enabled {
            await enableNetP()
        } else {
            await disableNetP()
        }
    }

    @MainActor
    private func enableNetP() async {
        await tunnelController.start()
    }

    @MainActor
    private func disableNetP() async {
        await tunnelController.stop()
    }
}

private extension ConnectionStatus {
    var message: String {
        switch self {
        case .notConfigured:
            return "Not Configured"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .connected(connectedDate: let connectedDate):
            return "Connected since \(connectedDate)"
        case .connecting:
            return "Connecting"
        case .reasserting:
            return "Reasserting"
        }
    }

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
