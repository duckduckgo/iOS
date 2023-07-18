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

final class NetworkProtectionStatusViewModel: ObservableObject {
    private let tunnelController: NetworkProtectionTunnelControlling
    private var cancellables: Set<AnyCancellable> = []
    @Published public var isNetPEnabled = false
    @Published public var statusMessage: String?
    @Published public var shouldShowLoading: Bool = false

    public init(tunnelController: NetworkProtectionTunnelControlling = NetworkProtectionTunnelController()) {
        self.tunnelController = tunnelController
        tunnelController.statusPublisher.map {
            switch $0 {
            case .connected:
                return true
            default:
                return false
            }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.isNetPEnabled, onWeaklyHeld: self)
        .store(in: &cancellables)

        tunnelController.statusPublisher.map {
            switch $0 {
            case .connecting, .reasserting, .disconnecting:
                return true
            default:
                return false
            }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.shouldShowLoading, onWeaklyHeld: self)
        .store(in: &cancellables)

        tunnelController.statusPublisher.map {
            switch $0 {
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
        do {
            try await tunnelController.setState(to: true)
        } catch {
            statusMessage = error.localizedDescription
            isNetPEnabled = false
        }
    }

    @MainActor
    private func disableNetP() async {
        do {
            try await tunnelController.setState(to: false)
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

#endif
