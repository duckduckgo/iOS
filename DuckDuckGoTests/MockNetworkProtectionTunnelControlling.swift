//
//  MockNetworkProtectionTunnelControlling.swift
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
@testable import DuckDuckGo

final class MockNetworkProtectionTunnelControlling: NetworkProtectionTunnelControlling {
    let statusSubject = PassthroughSubject<NetworkProtection.ConnectionStatus, Never>()

    var status: NetworkProtection.ConnectionStatus = .reasserting

    lazy var statusPublisher: AnyPublisher<NetworkProtection.ConnectionStatus, Never> = statusSubject.eraseToAnyPublisher()

    var stubSetStateError: Error?
    var spySetStateEnabled: Bool?

    func setState(to enabled: Bool) async throws {
        if let stubSetStateError {
            throw stubSetStateError
        }
        spySetStateEnabled = enabled
    }
}
